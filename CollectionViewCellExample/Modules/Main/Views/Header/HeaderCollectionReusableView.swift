//
//  HeaderCollectionReusableView.swift
//  CollectionViewCellExample
//
//  Created by User on 22.07.21.
//

import UIKit

class HeaderCollectionReusableView: UICollectionReusableView {

    @IBOutlet private weak var headerButton: UIButton!
    
    static let identifier = "header"
    
    func nib() -> UINib {
        return UINib(nibName: String(describing: Self.self), bundle: Bundle.main)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction private func tap() {
        print("tap")
    }
    
}
