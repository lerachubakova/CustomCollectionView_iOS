//
//  MyCell.swift
//  CollectionViewCellExample
//
//  Created by User on 21.07.21.
//

import UIKit

class MyCell: UICollectionViewCell {
    @IBOutlet private weak var imageView: UIImageView!
    
    func setImage(_ img: UIImage) {
        imageView.image = img
    }
}
