//
//  CenteredCollectionFlowLayout.swift
//  ios-play
//
//  Created by Artem Rylov on 07.07.2024.
//

import UIKit

class CenteredCollectionFlowLayout: UICollectionViewLayout {
    
    // MARK: - Properties
    
    // Cached layout attributes
    private var layoutAttributes: [UICollectionViewLayoutAttributes] = []
    
    private let stubContentSizes: [CGSize] = [
        CGSize(width: 150, height: 480),
        CGSize(width: 120, height: 480),
        CGSize(width: 50, height: 300),
        CGSize(width: 200, height: 300),
    ]
    private let offsetConstant: CGFloat = 50
    
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

        guard let collectionView else { return }
        
        collectionView.decelerationRate = .fast
        
        let collectionViewWidth = collectionView.bounds.width
        let collectionViewHeight = collectionView.bounds.height
        
        layoutAttributes = []
        
        for item in 0..<stubContentSizes.count {
            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(row: item, section: 0))
            
            let itemSize = stubContentSizes[item]
            attributes.size = itemSize
            
            if let prevAttributes = layoutAttributes.last {
                // Это уже не первый, до него есть предыдущий
                
                attributes.frame.origin = .init(
                    x: prevAttributes.frame.origin.x
                        + (prevAttributes.size.width / 2)
                        + (collectionViewWidth / 2)
                        - offsetConstant,
                    y: collectionViewHeight - itemSize.height
                )
                
                let adjustedXCenter = attributes.center.x - collectionView.contentOffset.x
                // 0 – в начале коллекции; 1 – в конце коллекции
                let normalizedXCenter = adjustedXCenter / collectionViewWidth
                
                if normalizedXCenter < 1 {
                    let currSpace = space(by: attributes.size.width)
                    let prevSpace = space(by: prevAttributes.size.width)
                    
                    let targetXTransform = prevSpace - currSpace
                    
                    let transformPercent = min(-(normalizedXCenter - 1) * 2, 1)
                    prevAttributes.transform = .init(translationX: targetXTransform * transformPercent, y: 1)
                }
            } else {
                // Это первый аттрибут в списке
                attributes.frame.origin = .init(
                    x: (collectionViewWidth / 2) - (itemSize.width / 2),
                    y: collectionViewHeight - itemSize.height
                )
            }
            
            layoutAttributes.append(attributes)
        }
    }
    
    private func space(by width: CGFloat) -> CGFloat {
        guard let collectionView else { return .zero }
        
        return (collectionView.bounds.width - width - 2 * offsetConstant) / 2
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
        
        return closestCenter.map { CGPoint(x: $0 - collectionView.bounds.width / 2, y: proposedContentOffset.y) }
            ?? proposedContentOffset
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
