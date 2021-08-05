//
//  ViewController.swift
//  CollectionViewCellExample
//
//  Created by User on 21.07.21.
//

import Photos
import UIKit

class MainViewController: UIViewController {
    // MARK: - @IBOutlets
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var photos: [UIImage] = []
    private var urls: [URL?] = []
    private var photosCount = 30
    private var needToPlay = false
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkAuthorization()
    }
    
    override func viewDidLayoutSubviews() {
        reloadCollectionView()
    }
    
    // MARK: - Setup
    private func configureCollectionView() {
        makePhotosArray()
        
        if photos.count == 0 {
            showOpenSettingsAlert(message: "There is no video in library or in the available media. \nYou can fix it in settings.")
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let headerKind = UICollectionView.elementKindSectionHeader
        collectionView.register(HeaderCollectionReusableView().nib(),forSupplementaryViewOfKind: headerKind, withReuseIdentifier: HeaderCollectionReusableView.identifier)
        collectionView.register(ProfileCell().nib(), forCellWithReuseIdentifier: ProfileCell.identifier)
        
        if let layout = collectionView?.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }
    }
    
    // MARK: - Logic
    func reloadCollectionView() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
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
                print(".unauthorized")
                DispatchQueue.main.async {
                    self?.showOpenSettingsAlert(message: "Application needs access to one or more videos in library.")
                }
            }
        }
    }
 
    private func makePhotosArray() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        fetchOptions.fetchLimit = photosCount

        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.video, options: fetchOptions)

        if fetchResult.count > 0 {
            fetchPhotoAtIndex(0, fetchOptions.fetchLimit, fetchResult)
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
    
    private func fetchPhotoAtIndex(_ index:Int, _ totalImageCountNeeded: Int, _ fetchResult: PHFetchResult<PHAsset>) {
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        let object = fetchResult.object(at: index) as PHAsset
        
        object.getURL(completionHandler: { [weak self] url in
            self?.urls.append(url)
            if self?.urls.count == self?.photosCount {
                self?.reloadCollectionView()
            }
        })
        
        let mode = PHImageContentMode.aspectFill
        PHImageManager.default().requestImage(for: object, targetSize: view.frame.size, contentMode: mode, options: requestOptions, resultHandler: { [weak self] (image, _) in
            guard let self = self else { return }
            if let image = image {
                self.photos += [image]
            }
            if index + 1 < fetchResult.count && self.photos.count < totalImageCountNeeded {
                self.fetchPhotoAtIndex(index + 1, totalImageCountNeeded, fetchResult)
            }
        })
    }
}
// MARK: - UICollectionViewDelegate
extension MainViewController: UICollectionViewDelegate {}

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
            return profileCell
//            print(profileCell)
//            print("myBlack: \(indexPath)")
//            print("my: black myCell: \(indexPath)")
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath)
            if let myCell = cell as? MyCell {
               // print("cell: \(indexPath)")
              //  myCell.layer.cornerRadius = 10
                myCell.setImage(photos[indexPath.item])
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
       // print("was here \(sectionHeader as? HeaderCollectionReusableView)")
        if let header = sectionHeader as? HeaderCollectionReusableView, indexPath.section == 1 {
            header.delegate = self
        // print("my: header \(indexPath)")
            return header
        }
        return sectionHeader
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
        if indexPath.item == 0 && indexPath.section == 0 {
            return CGSize(width: view.frame.width, height: view.frame.height * 0.3)
        } else if indexPath.item < photos.count {
            return photos[indexPath.item].size
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
