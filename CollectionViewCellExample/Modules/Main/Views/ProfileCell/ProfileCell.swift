//
//  CollectionViewCell.swift
//  CollectionViewCellExample
//
//  Created by User on 23.07.21.
//

import UIKit

final class ProfileCell: UICollectionViewCell {

    static let identifier = "profileCell"
    
    func nib() -> UINib {
        return UINib(nibName: String(describing: Self.self), bundle: Bundle.main)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
