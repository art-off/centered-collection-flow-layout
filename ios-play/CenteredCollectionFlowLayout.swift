//
//  CenteredCollectionFlowLayout.swift
//  ios-play
//
//  Created by Artem Rylov on 07.07.2024.
//

import UIKit

protocol CenteredCollectionFlowLayoutDelegate: AnyObject {

    // Size for cell in indexPath
    func centeredCollecitonFlowLayout(sizeFor indexPath: IndexPath) -> CGSize

    // Offset by collecitonView horizontal edges
    func centeredCollectionFlowLayoutOffsetConstant() -> CGFloat
}

class CenteredCollectionFlowLayout: UICollectionViewLayout {
    
    // Dependencies
    public weak var delegate: CenteredCollectionFlowLayoutDelegate?
    
    // MARK: - Properties
    
    // Cached layout attributes
    private var layoutAttributes: [UICollectionViewLayoutAttributes] = []
    
    // MARK: - Content Size
    
    override var collectionViewContentSize: CGSize {
        guard
            let lastElementAttributes = layoutAttributes.last,
            let collectionView
        else {
            return .zero
        }
        
        let lastElementStartX = lastElementAttributes.frame.origin.x
        let lastElementWidth = lastElementAttributes.size.width
        let lastSpaceForCenteringLastElement = (collectionView.bounds.width - lastElementAttributes.size.width) / 2
        
        return CGSize(
            width: lastElementStartX + lastElementWidth + lastSpaceForCenteringLastElement,
            height: collectionView.bounds.height
        )
    }
    
    // MARK: - Prepare
    
    override func prepare() {
        super.prepare()

        guard let collectionView, let delegate else { return }
        
        collectionView.decelerationRate = .fast
        
        let collectionViewWidth = collectionView.bounds.width
        let collectionViewHeight = collectionView.bounds.height
        
        layoutAttributes = []
        
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(row: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            let offset = delegate.centeredCollectionFlowLayoutOffsetConstant()
            
            let itemSize = delegate.centeredCollecitonFlowLayout(sizeFor: indexPath)
            attributes.size = itemSize
            
            if let prevAttributes = layoutAttributes.last {
                // Non-first attribute

                attributes.frame.origin = CGPoint(
                    x: prevAttributes.frame.origin.x
                        + (prevAttributes.size.width / 2)
                        + (collectionViewWidth / 2)
                        - offset,
                    y: collectionViewHeight - itemSize.height
                )
                
                let adjustedXCenter = attributes.center.x - collectionView.contentOffset.x
                // <0 – behind begin of collectionView
                // 0 – begin of collecitonView
                // 0.5 – center of cellectionView
                // 1 – end of collecitonView
                // >1 – behind end of collectionView
                let normalizedXCenter = adjustedXCenter / collectionViewWidth
                
                if normalizedXCenter < 1 {
                    let currSpace = space(by: attributes.size.width)
                    let prevSpace = space(by: prevAttributes.size.width)
                    
                    let targetXTransform = prevSpace - currSpace
                    
                    let transformPercent = min(-(normalizedXCenter - 1) * 2, 1)
                    prevAttributes.transform = CGAffineTransform(translationX: targetXTransform * transformPercent, y: 1)
                }
            } else {
                // First attribute
                attributes.frame.origin = CGPoint(
                    x: (collectionViewWidth / 2) - (itemSize.width / 2),
                    y: collectionViewHeight - itemSize.height
                )
            }
            
            layoutAttributes.append(attributes)
        }
    }
    
    private func space(by width: CGFloat) -> CGFloat {
        guard let collectionView, let delegate else { return .zero }
        
        return (collectionView.bounds.width - width - 2 * delegate.centeredCollectionFlowLayoutOffsetConstant()) / 2
    }
    
    // MARK: - Layout Attributes
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        layoutAttributes.filter { rect.intersects($0.frame) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        layoutAttributes.filter { $0.indexPath == indexPath }.first
    }
    
    // MARK: - Adjust contentOffset
        
    override func targetContentOffset(
        forProposedContentOffset proposedContentOffset: CGPoint,
        withScrollingVelocity velocity: CGPoint
    ) -> CGPoint {
        guard let collectionView else { return proposedContentOffset }
        
        let targetXCenter = proposedContentOffset.x + (collectionView.bounds.width / 2)
        let closestCenter = layoutAttributes.map(\.center.x).min {
            abs($0 - targetXCenter) < abs($1 - targetXCenter)
        }
        
        guard let closestCenter else { return proposedContentOffset }
        
        return CGPoint(x: closestCenter - collectionView.bounds.width / 2, y: proposedContentOffset.y)
    }
    
    // MARK: - Layout invalidations
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        true
    }
    
    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        if context.invalidateEverything || context.invalidateDataSourceCounts {
            layoutAttributes = []
        }
        super.invalidateLayout(with: context)
    }
}
