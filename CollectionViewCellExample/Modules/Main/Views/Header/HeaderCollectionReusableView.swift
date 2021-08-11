//
//  HeaderCollectionReusableView.swift
//  CollectionViewCellExample
//
//  Created by User on 22.07.21.
//

import UIKit

protocol HeaderCollectionReusableViewDelegate: AnyObject {
    func didTappedSectionSegmentedControl(_ segment: Int)
}

final class HeaderCollectionReusableView: UICollectionReusableView {
    @IBOutlet private weak var headerButton: UIButton!
    
    weak var delegate: HeaderCollectionReusableViewDelegate?
    
    static let identifier = "header"
    
    func nib() -> UINib {
        return UINib(nibName: String(describing: Self.self), bundle: Bundle.main)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction private func tap(_ sender: UISegmentedControl) {
        delegate?.didTappedSectionSegmentedControl(sender.selectedSegmentIndex)
    }
}
