/*
* Copyright (c) 2019 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
* distribute, sublicense, create a derivative work, and/or sell copies of the
* Software in any work that is designed, intended, or marketed for pedagogical or
* instructional purposes related to programming, coding, application development,
* or information technology.  Permission for such use, copying, modification,
* merger, publication, distribution, sublicensing, creation of derivative works,
* or sale is expressly withheld.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

protocol PinterestLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGSize
}

class PinterestLayout: UICollectionViewFlowLayout {
    // MARK: - @IBOutlets
    weak var delegate: PinterestLayoutDelegate?

    private let numberOfColumns = 2
    private let cellPadding: CGFloat = 5
    
    // TODO: height of section with bug (need 50)
    private let headerHeight: CGFloat = 10

    private var cache: [UICollectionViewLayoutAttributes] = []
    private var headerLayoutAttributes: [UICollectionViewLayoutAttributes] = []

    private var contentHeight: CGFloat = 0
    private var firstCellHeight: CGFloat = 0
    
    private var contentWidth: CGFloat {
        get {
            guard let collectionView = collectionView else { return 0 }
            let insets = collectionView.contentInset
            return collectionView.bounds.width - (insets.left + insets.right)
        } set {
            _ = newValue
        }
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if let collectionView = collectionView, newBounds.width != collectionView.bounds.width {
            cache.removeAll()
            headerLayoutAttributes.removeAll()
        }
        return true
    }
    
    // MARK: - LifeCycle
    override func prepare() {
       // print("prepare")
        if let collectionView = collectionView {
            let insets = collectionView.contentInset
            contentWidth = collectionView.bounds.width - (insets.left + insets.right)
        }
        
        guard cache.isEmpty, headerLayoutAttributes.isEmpty, let collectionView = collectionView else { return }
        
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset: [CGFloat] = []
            
        for column in 0..<numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
            
        var column = 0
        var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
        
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            
            let photoSize = delegate?.collectionView( collectionView, heightForPhotoAtIndexPath: indexPath) ?? CGSize(width: 180, height: 180)
            let photoHeight = photoSize.height
            let newHeight = (columnWidth - cellPadding * 2) / photoSize.width * photoHeight
            
            let height = cellPadding * 2 + newHeight
            
            if item == 0 {
                firstCellHeight = height
            }
            // columnWidth
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: contentWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)

            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
           // print(attributes)
            cache.append(attributes)
        }
       
        for section in 0...collectionView.numberOfSections - 1 {
            let frame = CGRect(x: xOffset[column], y: yOffset[column] + firstCellHeight, width: contentWidth, height: headerHeight)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: IndexPath(row: 0, section: section))
            attributes.frame = insetFrame
            headerLayoutAttributes.append(attributes)
        }
        
        for item in 0..<collectionView.numberOfItems(inSection: 1) {
            let indexPath = IndexPath(item: item, section: 1)
            
            let photoSize = delegate?.collectionView( collectionView, heightForPhotoAtIndexPath: indexPath) ?? CGSize(width: 180, height: 180)
            let photoHeight = photoSize.height
            let newHeight = (columnWidth - cellPadding * 2) / photoSize.width * photoHeight
            
            let height = cellPadding * 2 + newHeight
            var frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            
            if indexPath.row == 0 || indexPath.row == 1 {
                yOffset[column] += firstCellHeight + headerHeight
                frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            }
            
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)

            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)

            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height

            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        //    print(attributes)
        }
    }
    // MARK: - layoutAttributes
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
     
       // guard let layoutAttributes = super.layoutAttributesForElements(in: rect) else { return nil }
        let array1 = cache.filter { $0.frame.intersects(rect) }
    //    let array2 = headerLayoutAttributes.filter { $0.frame.intersects(rect) }
      
        let sectionsToAdd = NSMutableIndexSet()
        var newLayoutAttributes = [UICollectionViewLayoutAttributes]()

        for layoutAttributesSet in array1 {
            if layoutAttributesSet.representedElementCategory == .supplementaryView {
                sectionsToAdd.add(layoutAttributesSet.indexPath.section)
            } else if layoutAttributesSet.representedElementCategory == .cell {
                newLayoutAttributes.append(layoutAttributesSet)
                sectionsToAdd.add(layoutAttributesSet.indexPath.section)
            }
        }
        // TODO: uncomment for add section (with some bug, I don't know how to fix)
//        for section in sectionsToAdd {
//            let indexPath = IndexPath(item: 0, section: section)
//            if let sectionAttributes = self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath) {
//                newLayoutAttributes.append(sectionAttributes)
//            }
//        }
        
        //        print("###")
        //        print(array1 + array2)
        //        print("-------------------------")
        //        print(newLayoutAttributes)
        //        print("###")
        return newLayoutAttributes
    }
  
//    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//       let array1 = cache.filter { $0.frame.intersects(rect) }
//       let array2 = headerLayoutAttributes.filter { $0.frame.intersects(rect) }
//        return array1 + array2
//    }
    
//    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//        print("layoutAttributesForSupplementaryView")
//        return headerLayoutAttributes[indexPath.section]
//    }
    
    func boundaries(forSection section: Int) -> (minimum: CGFloat, maximum: CGFloat)? {
        var result = (minimum: CGFloat(0.0), maximum: CGFloat(0.0))

       // guard let collectionView = collectionView else { return result }
      
        let firstItem = cache[1]
        let lastItem = cache.last ?? cache[0]
        
        result.minimum = firstItem.frame.minY
        result.maximum = lastItem.frame.maxY

        result.minimum -= (headerReferenceSize.height + cellPadding * 2)
        result.maximum -= (headerReferenceSize.height + cellPadding * 2)

        result.minimum -= sectionInset.top
        result.maximum += (sectionInset.top + sectionInset.bottom)
        
        return result
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
       // guard let layoutAttributes = super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath) else { return nil }
        let layoutAttributes = headerLayoutAttributes[indexPath.section]
        guard let collectionView = collectionView else { return layoutAttributes }
        guard let boundaries = boundaries(forSection: indexPath.section) else { return layoutAttributes }
        
        // Helpers
        let contentOffsetY = collectionView.contentOffset.y
        var frameForSupplementaryView = layoutAttributes.frame

        let minimum = boundaries.minimum - frameForSupplementaryView.height
        let maximum = boundaries.maximum - frameForSupplementaryView.height

        if contentOffsetY < minimum {
            frameForSupplementaryView.origin.y = minimum
        } else if contentOffsetY > maximum {
            frameForSupplementaryView.origin.y = maximum
        } else {
            frameForSupplementaryView.origin.y = contentOffsetY
        }

        layoutAttributes.frame = frameForSupplementaryView
        
        return layoutAttributes
    }
    
}
