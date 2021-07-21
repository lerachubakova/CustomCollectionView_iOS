//
//  ViewController.swift
//  CollectionViewCellExample
//
//  Created by User on 21.07.21.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet private weak var collectionView: UICollectionView!
    
    var photos: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makePhotosArray()
        configureCollectionView()
    }
    
    private func makePhotosArray() {
        for i in 0...10 {
            if let image = UIImage(named: "photo\(i)") {
                photos.append(image)
            }
        }
    }
    
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        if let layout = collectionView?.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }
    }
}

extension MainViewController: UICollectionViewDelegate {}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count * 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath)
        if let myCell = cell as? MyCell {
            myCell.setImage(photos[indexPath.item % photos.count])
            return myCell
        }
        return cell
    }
}

extension MainViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGSize {
        return photos[indexPath.item % photos.count].size
    }
}
