//
//  ViewController.swift
//  CollectionViewCellExample
//
//  Created by User on 21.07.21.
//

import Photos
import UIKit

final class MainViewController: UIViewController {
    // MARK: - @IBOutlets
    @IBOutlet private weak var collectionView: UICollectionView!
    
    // MARK: - Private Properties
    private var photos: [UIImage?] = []
    private var urls: [URL?] = []
    private var photosCount = 30
    private var needToPlay = false
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        let headerKind = UICollectionView.elementKindSectionHeader
        collectionView.register(HeaderCollectionReusableView().nib(),forSupplementaryViewOfKind: headerKind, withReuseIdentifier: HeaderCollectionReusableView.identifier)
        collectionView.register(ProfileCell().nib(), forCellWithReuseIdentifier: ProfileCell.identifier)
        checkAuthorization()
    }
    
    override func viewDidLayoutSubviews() {
        reloadCollectionView()
    }
    
    // MARK: - Setup
    private func checkAuthorization() {
        let status = PHLibraryAuthorizationManager.getPhotoLibraryAuthorizationStatus()
        switch status {
        case .notRequested:
            makeAuthorizationRequest()
        case .granted:
            configureCollectionView()
        case .unauthorized:
            showOpenSettingsAlert(message: "Application needs access to one or more videos in library.")
        }
    }
    
    private func configureCollectionView() {
        // FIXME: 4 video
        makePhotosArray()
        
        if photos.count == 0 {
            showOpenSettingsAlert(message: "There is no video in library or in the available media. \nYou can fix it in settings.")
        }
        
        if let layout = collectionView?.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }
    }
    
    // MARK: - Logic
    private func makeAuthorizationRequest() {
        PHLibraryAuthorizationManager.requestPhotoLibraryAuthorization { [weak self] status in
            switch status {
            case .notRequested:
                break
            case .granted:
                DispatchQueue.main.async {
                    self?.configureCollectionView()
                }
            case .unauthorized:
                DispatchQueue.main.async {
                    self?.showOpenSettingsAlert(message: "Application needs access to one or more videos in library.")
                }
            }
        }
    }
    
    private func showOpenSettingsAlert(message: String) {
        let alert = UIAlertController(title: "Want to continue?", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { [weak self] _ in
            self?.openSettings()
        }))
        self.present(alert, animated: true)
    }
    
    private func openSettings() {
        let settingURLString = UIApplication.openSettingsURLString
        if let url = URL(string: settingURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func reloadCollectionView() {
        DispatchQueue.main.async { [weak self] in
            print(" LOG reload Collection View")
            self?.collectionView.reloadData()
        }
    }
    
    private func makePhotosArray() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        print(" LOG photosCount:", photosCount)
        fetchOptions.fetchLimit = photosCount

        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.video, options: fetchOptions)
        
        print(" LOG fetchResult:", fetchResult.count)
        print()
        
        if fetchResult.count > 0 {
            fetchPhotoAtIndex(0, photosCount, fetchResult)
        }
       
        print("\n LOG photos:", photos.count)
        print(" LOG urls:", urls.count)
        
        self.reloadCollectionView()
        print()
    }
    
    private func fetchPhotoAtIndex(_ index: Int, _ totalImageCountNeeded: Int, _ fetchResult: PHFetchResult<PHAsset>) {
        print("\n LOG fetchPhotoAtIndex \(index) \(totalImageCountNeeded) \(fetchResult.count):")

        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        let object = fetchResult.object(at: index) as PHAsset
        
        object.getURL(completionHandler: { [unowned self] url in
            self.urls.append(url)
            if let url = url {
                print("\t LOG url.count += 1 \(url)")
            } else {
                print("\t LOG url is nil")
            }

            if urls.count == photosCount || urls.count == photos.count {
                reloadCollectionView()
                print("\n LOG photos after all URL:", photos)
                print("\n LOG urls after all URL:", urls)
            }
        })
        
        let mode = PHImageContentMode.aspectFill
        PHImageManager.default().requestImage(for: object, targetSize: view.frame.size, contentMode: mode, options: requestOptions, resultHandler: { [unowned self] (image, some) in

            self.photos.append(image)
            
            if let image = image {
                print("\t LOG image.count += 1 \(image)")
            } else {
                print("\t LOG image is nil \(String(describing: some))")
            }
            
            print(" LOG final fetchPhotoAtIndex:", index, "photos:", self.photos.count, "urls:", self.urls.count)
            
            if index + 1 < fetchResult.count && self.photos.count < totalImageCountNeeded {
                self.fetchPhotoAtIndex(index + 1, totalImageCountNeeded, fetchResult)
            }
        })
    }
}
// MARK: - UICollectionViewDelegate
extension MainViewController: UICollectionViewDelegate {
    
}

// MARK: - UICollectionViewDataSource
extension MainViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return photos.count
        default: break
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let profileCell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCell.identifier, for: indexPath)
            profileCell.layer.cornerRadius = 7
            return profileCell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath)
            if let myCell = cell as? MyCell {
                myCell.setImage(photos[indexPath.item])
                myCell.layer.cornerRadius = 7
                if indexPath.item < urls.count && needToPlay {
                    myCell.setURL(urls[indexPath.item])
                    myCell.configurePlayer()
                }
                return myCell
            }
        default: break
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let myCell = cell as? MyCell, needToPlay {
            myCell.deletePlayer()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let myCell = cell as? MyCell {
            if needToPlay {
                myCell.startPlayer()
            } else {
                myCell.deletePlayer()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderCollectionReusableView.identifier, for: indexPath)
        if let header = sectionHeader as? HeaderCollectionReusableView, indexPath.section == 1 {
            header.delegate = self
            return header
        }
        return sectionHeader
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // no scrolling outside
        if scrollView.contentOffset.y < 0 {
             scrollView.contentOffset.y = 0
        } else if scrollView.contentSize.height - scrollView.contentOffset.y < scrollView.frame.size.height {
            scrollView.contentOffset.y = -scrollView.frame.size.height + scrollView.contentSize.height
        }
    }
}

// MARK: - PinterestLayoutDelegate
extension MainViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGSize {
        // height of cells
        if indexPath.item == 0 && indexPath.section == 0 {
            return CGSize(width: view.frame.width, height: view.frame.height * 0.3)
        } else if indexPath.item < photos.count {
            return photos[indexPath.item]?.size ?? CGSize(width: view.frame.width, height: view.frame.height * 0.3)
        }
        return CGSize(width: 180, height: 180)
    }
}

// MARK: - HeaderCollectionReusableViewDelegate
extension MainViewController: HeaderCollectionReusableViewDelegate {
    func didTappedSectionSegmentedControl(_ segment: Int) {
        self.needToPlay = segment == 0
        self.reloadCollectionView()
    }
}
