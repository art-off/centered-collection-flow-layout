//
//  ViewController.swift
//  ios-play
//
//  Created by Artem Rylov on 04.07.2024.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource {
    
    // Views
    private var collectionView: UICollectionView!
    
    // Dependencies
    let flowLayout = CenteredCollectionFlowLayout()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Zoomed & snapped cells"
        addCollectionView()
        addHelpersViews()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.contentView.backgroundColor = indexPath.row % 2 == 0 ? .red : .yellow
        return cell
    }
    
    private func addCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        ])
        collectionView.layer.borderColor = UIColor.black.cgColor
        collectionView.layer.borderWidth = 2
        collectionView.dataSource = self
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
    }
    
    private func addHelpersViews() {
        let view50Width1 = UIView()
        view50Width1.backgroundColor = .green
        view50Width1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(view50Width1)
        NSLayoutConstraint.activate([
            view50Width1.widthAnchor.constraint(equalToConstant: 50),
            view50Width1.heightAnchor.constraint(equalToConstant: 50),
            view50Width1.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            view50Width1.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
        ])
        
        let view50Width2 = UIView()
        view50Width2.backgroundColor = .green
        view50Width2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(view50Width2)
        NSLayoutConstraint.activate([
            view50Width2.widthAnchor.constraint(equalToConstant: 50),
            view50Width2.heightAnchor.constraint(equalToConstant: 50),
            view50Width2.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            view50Width2.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
        ])
        
        let centerLineView = UIView()
        centerLineView.backgroundColor = .green
        centerLineView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(centerLineView)
        NSLayoutConstraint.activate([
            centerLineView.topAnchor.constraint(equalTo: collectionView.topAnchor),
            centerLineView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor),
            centerLineView.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            centerLineView.widthAnchor.constraint(equalToConstant: 3),
        ])
    }
}

class CustomCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    
//    var percent: CGFloat = 0.0
//    var space: CGFloat = 0.0
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? CustomCollectionViewLayoutAttributes else { return false }
        
        return super.isEqual(other)// && self.percent == other.percent && self.space == other.space
    }
}

class CustomCollectionViewCell: UICollectionViewCell {
    
    private let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.numberOfLines = 0
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
//        let layoutAttributes = (layoutAttributes as! CustomCollectionViewLayoutAttributes)
        label.text = layoutAttributes.center.x.description
    }
}

class CenteredCollectionFlowLayout: UICollectionViewLayout {
    
    // MARK: - Properties
    
    override class var layoutAttributesClass: AnyClass {
        CustomCollectionViewLayoutAttributes.self
    }
    
    // Cached layout attributes
    private var layoutAttributes: [CustomCollectionViewLayoutAttributes] = []
    
    private let stubContentSizes: [CGSize] = [
        CGSize(width: 150, height: 480),
        CGSize(width: 120, height: 480),
        CGSize(width: 50, height: 300),
        CGSize(width: 200, height: 300),
    ]
    private let offsetConstant: CGFloat = 50
    
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
        
        let collectionViewWidth = collectionView.bounds.width
        let collectionViewHeight = collectionView.bounds.height
        
        layoutAttributes = []
        
        for item in 0..<stubContentSizes.count {
            let attributes = CustomCollectionViewLayoutAttributes(forCellWith: IndexPath(row: item, section: 0))
            
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
            } else {
                // Это первый аттрибут в списке
                attributes.frame.origin = .init(
                    x: (collectionViewWidth / 2) - (itemSize.width / 2),
                    y: collectionViewHeight - itemSize.height
                )
            }
            
            let xCenter = attributes.center.x
            let xContentOffset = collectionView.contentOffset.x
            let adjustedXCenter = xCenter - xContentOffset
            let percent = adjustedXCenter / collectionViewWidth
//            attributes.percent = percent
            
            if 1 > percent, layoutAttributes.indices.contains(item - 1) {
                let prevAttributes = layoutAttributes[item - 1]
                
                let currSpace = space(by: attributes.size.width)
                let prevSpace = space(by: prevAttributes.size.width)
                
                let targetXTransform = prevSpace - currSpace
                
//                let p = max(-(percent - 0.5) * 2, 0)
                let p = min(-(percent - 1) * 2, 1)
//                prevAttributes.percent = p
                prevAttributes.transform = .init(translationX: targetXTransform * p, y: 1)
            }
//            attributes.space = space(by: attributes.size.width)
            
            layoutAttributes.append(attributes)
        }
    }
    
    private func space(by width: CGFloat) -> CGFloat {
        guard let collectionView else { return .zero }
        
        return (collectionView.bounds.width - width - 2 * offsetConstant) / 2
    }
    
    // MARK: - Layout Attributes
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView else { return nil }
        return layoutAttributes.filter { rect.intersects($0.frame) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        layoutAttributes.filter { $0.indexPath == indexPath }.first
    }
    
    // MARK: - Adjust contentOffset
    
    // это реализовать чуть позже с учетом всех размеров
    
    override func targetContentOffset(
        forProposedContentOffset proposedContentOffset: CGPoint,
        withScrollingVelocity velocity: CGPoint
    ) -> CGPoint {
        guard let collectionView else { return proposedContentOffset }
        
        let targetMidX = proposedContentOffset.x + (collectionView.bounds.width / 2)
        
        let xCenters = layoutAttributes.map(\.center.x)
        let closest = xCenters.enumerated().min { abs($0.1 - targetMidX) < abs($1.1 - targetMidX) }!
        print("TARGET :", targetMidX)
        print("CENTERS:", xCenters)
        print("CLOSEST:", closest)
//        let targetItem = {
//            let xCenters = layoutAttributes.map(\.center.x)
//            let proximitiesToXCenter = xCenters.map { xCenter in
//                abs(xCenter - targetMidX)
//            }
//            
//            print("PROPOS :", proposedContentOffset.x)
//            print("CENTERS:", xCenters)
//            print("PROXIM :", proximitiesToXCenter)
//            
//            var minIndex = 0
//            for index in proximitiesToXCenter.indices where proximitiesToXCenter[index] < proximitiesToXCenter[minIndex] {
//                minIndex = index
//            }
//            
//            print("MIN    :", minIndex)
//
//            return minIndex
//        }()
        
        let targetPoint = CGPoint(
            x: layoutAttributes[closest.offset].center.x,
            y: proposedContentOffset.y
        )
        print("RESULT :", targetPoint.x)
        return targetPoint
    }
    
//    override func targetContentOffset(
//        forProposedContentOffset proposedContentOffset: CGPoint,
//        withScrollingVelocity velocity: CGPoint) -> CGPoint
//    {
//        guard let cv = collectionView else { return proposedContentOffset }
//        
//        // Get target item
//        let targetX = proposedContentOffset.x
//        let targetMidX = targetX + (cv.bounds.width / 2.0)
//        let targetItem = floor(targetMidX / itemAndSpaceWidth)
//        
//        // Calculate adjusted offset
//        let adjustedX = (targetItem * itemAndSpaceWidth) - contentInsets.left
//        return CGPoint(x: adjustedX, y: proposedContentOffset.y)
//    }
    
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
    
//    // MARK: - Transform Calculator
//    
//    private func getTransform3D(for attributes: UICollectionViewLayoutAttributes) -> CATransform3D {
//        
//        var prespective = CATransform3DIdentity
//        prespective.m34 = -1.0 / 400
//        
//        let angle = getAngle(for: attributes)
//        var transform = CATransform3DRotate(prespective, angle, 0, 1, 0)
//        transform = CATransform3DTranslate(transform, angle * 125, 0, 0)
//        
//        return transform
//    }
//    
//    private func getAngle(for attributes: UICollectionViewLayoutAttributes) -> CGFloat {
//        guard let cv = collectionView else { return .zero }
//        
//        let visibleRect = CGRect(origin: cv.contentOffset, size: cv.bounds.size)
//        let center = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
//        
//        let itemDistanceFromCenter = attributes.center.x - center.x
//        let totalSpaceFromCenterToEdge = (visibleRect.maxX - visibleRect.minX) / 2.0
//        
//        // Capping the factor between -1, 1
//        let distanceFactor = max(-1, min(1, itemDistanceFromCenter / totalSpaceFromCenterToEdge))
//        let angle = -1 * distanceFactor * maxRotationAngle
//        
//        print(attributes.indexPath.item, distanceFactor)
//        
//        return angle
//    }
}


//class CenteredCollectionFlowLayout: UICollectionViewLayout {
//    
//    private var layoutAttributes: [UICollectionViewLayoutAttributes] = []
//    
//    // MARK: - Prepare
//    
//    override func prepare() {
//        guard let collectionView else { return }
//        
//        var currentX: CGFloat = 0
//        
//        layoutAttributes = (0...collectionView.numberOfItems(inSection: 0)).map { index in
//            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(row: index, section: 0))
//            
//            attributes.size = .init(width: 100, height: 100)
//            
//            let xCenter = currentX + (attributes.size.width / 2.0) + collectionView.contentOffset.x
//            let yCenter = collectionView.bounds.minY
//            attributes.center = .init(x: xCenter, y: 500) //.init(x: xCenter, y: yCenter)
//            
//            currentX += attributes.size.width
//            
//            return attributes
//        }
//        
//        print(layoutAttributes)
//    }
//    
//    // MARK: -  LayoutAttributes
//    
//    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        guard let cv = collectionView else { return nil }
//        
////        let visibleRect = CGRect(origin: cv.contentOffset, size: cv.bounds.size)
////        for attributes in layoutAttributes where visibleRect.intersects(attributes.frame) {
////            attributes.transform3D = getTransform3D(for: attributes)
////        }
//        
//        return layoutAttributes.filter { rect.intersects($0.frame) }
//    }
//    
//    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//        layoutAttributes.filter { $0.indexPath == indexPath }.first
//    }
//    
//    // MARK: - Layout invalidations
//    
//    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
//        true
//    }
//    
//    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
//        if context.invalidateEverything || context.invalidateDataSourceCounts {
//            layoutAttributes = []
//        }
//        super.invalidateLayout(with: context)
//    }
//}
//
//// MARK: - Ворованное
//
//class ZoomAndSnapFlowLayout: UICollectionViewFlowLayout {
//
//    let activeDistance: CGFloat = 200
//    let zoomFactor: CGFloat = 0.3
//
//    override init() {
//        super.init()
//
//        scrollDirection = .horizontal
//        minimumLineSpacing = 40
//        itemSize = CGSize(width: 150, height: 150)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func prepare() {
//        guard let collectionView = collectionView else { fatalError() }
//        let verticalInsets = (collectionView.frame.height - collectionView.adjustedContentInset.top - collectionView.adjustedContentInset.bottom - itemSize.height) / 2
//        let horizontalInsets = (collectionView.frame.width - collectionView.adjustedContentInset.right - collectionView.adjustedContentInset.left - itemSize.width) / 2
//        sectionInset = UIEdgeInsets(top: verticalInsets, left: horizontalInsets, bottom: verticalInsets, right: horizontalInsets)
//
//        super.prepare()
//    }
//
//    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        guard let collectionView = collectionView else { return nil }
//        let rectAttributes = super.layoutAttributesForElements(in: rect)!.map { $0.copy() as! UICollectionViewLayoutAttributes }
//        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.frame.size)
//
//        // Make the cells be zoomed when they reach the center of the screen
//        for attributes in rectAttributes where attributes.frame.intersects(visibleRect) {
//            let distance = visibleRect.midX - attributes.center.x
//            let normalizedDistance = distance / activeDistance
//
//            if distance.magnitude < activeDistance {
//                let zoom = 1 + zoomFactor * (1 - normalizedDistance.magnitude)
//                attributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1)
//                attributes.zIndex = Int(zoom.rounded())
//            }
//        }
//
//        return rectAttributes
//    }
//
//    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
//        guard let collectionView = collectionView else { return .zero }
//
//        // Add some snapping behaviour so that the zoomed cell is always centered
//        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.frame.width, height: collectionView.frame.height)
//        guard let rectAttributes = super.layoutAttributesForElements(in: targetRect) else { return .zero }
//
//        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
//        let horizontalCenter = proposedContentOffset.x + collectionView.frame.width / 2
//
//        for layoutAttributes in rectAttributes {
//            let itemHorizontalCenter = layoutAttributes.center.x
//            if (itemHorizontalCenter - horizontalCenter).magnitude < offsetAdjustment.magnitude {
//                offsetAdjustment = itemHorizontalCenter - horizontalCenter
//            }
//        }
//
//        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
//    }
//
//    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
//        // Invalidate layout so that every cell get a chance to be zoomed when it reaches the center of the screen
//        return true
//    }
//
//    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
//        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
//        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
//        return context
//    }
//
//}
//
//class CollectionDataSource: NSObject, UICollectionViewDataSource {
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 9
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
//        return cell
//    }
//
//}
//
//class CardPagingLayout: UICollectionViewLayout {
//    
//    // MARK: Book keeping
//    private var itemCount = 0
//    private var itemSize = CGSize.zero
//    private var contentInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
//    private var maxRotationAngle: CGFloat = .pi * 0.1
//    private let interitemSpace: CGFloat = 16
//    private var itemWidth: CGFloat {
//        itemSize.width
//    }
//    private var itemAndSpaceWidth: CGFloat {
//        itemWidth + interitemSpace
//    }
//    private var contentWidth: CGFloat {
//        (CGFloat(itemCount) * itemWidth) +
//            (CGFloat(itemCount - 1) * interitemSpace) +
//            (contentInsets.left + contentInsets.right)
//    }
//    
//    // Cached layout attributes
//    private var layoutAttributes: [UICollectionViewLayoutAttributes] = []
//    
//    // ContentSize
//    override var collectionViewContentSize: CGSize {
//        guard let cv = collectionView else { return .zero }
//        return CGSize(width: contentWidth, height: cv.bounds.height)
//    }
//    
//    // MARK: - Prepare
//    
//    override func prepare() {
//        super.prepare()
//
//        guard let cv = collectionView else { return }
//        
//        cv.decelerationRate = .fast
//        cv.contentInset = contentInsets
//        itemCount = cv.numberOfItems(inSection: 0)
//        itemSize = CGSize(width: cv.bounds.width - (interitemSpace * 2.0),
//                          height: cv.bounds.height - (contentInsets.top + contentInsets.bottom))
//
//        // Pre-variables
//        layoutAttributes = []
//        var currentX: CGFloat = 0
//        
//        // Calculating the attributes for all the items.
//        // For large collection views more a thouthand item
//        // Consider splitting these calculations into chunks
//        for item in 0..<itemCount {
//            
//            // Create attributes for each item
//            let indexPath = IndexPath(item: item, section: 0)
//            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
//            
//            // Set attributes size
//            attributes.size = itemSize
//            
//            // Set attributes center
//            let xCenter = currentX + (itemSize.width / 2.0)
//            let yCenter = cv.bounds.midY
//            attributes.center = CGPoint(x: xCenter, y: yCenter)
//            
//            // Append to cache
//            layoutAttributes.append(attributes)
//            
//            // Shift current x with item width and interitem spacing
//            currentX += itemAndSpaceWidth
//        }
//    }
//    
//    // MARK: - Layout Attributes
//    
//    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        guard let cv = collectionView else { return nil }
//        
//        let visibleRect = CGRect(origin: cv.contentOffset, size: cv.bounds.size)
//        for attributes in layoutAttributes where visibleRect.intersects(attributes.frame) {
//            attributes.transform3D = getTransform3D(for: attributes)
//        }
//        
//        return layoutAttributes.filter { rect.intersects($0.frame) }
//    }
//    
//    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//        layoutAttributes.filter { $0.indexPath == indexPath }.first
//    }
//    
//    // MARK: - Adjust contentOffset
//    
//    override func targetContentOffset(
//        forProposedContentOffset proposedContentOffset: CGPoint,
//        withScrollingVelocity velocity: CGPoint) -> CGPoint
//    {
//        guard let cv = collectionView else { return proposedContentOffset }
//        
//        // Get target item
//        let targetX = proposedContentOffset.x
//        let targetMidX = targetX + (cv.bounds.width / 2.0)
//        let targetItem = floor(targetMidX / itemAndSpaceWidth)
//        
//        // Calculate adjusted offset
//        let adjustedX = (targetItem * itemAndSpaceWidth) - contentInsets.left
//        return CGPoint(x: adjustedX, y: proposedContentOffset.y)
//    }
//    
//    // MARK: - Layout invalidations
//    
//    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
//        true
//    }
//    
//    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
//        if context.invalidateEverything || context.invalidateDataSourceCounts {
//            layoutAttributes = []
//        }
//        super.invalidateLayout(with: context)
//    }
//    
//    // MARK: - Transform Calculator
//    
//    private func getTransform3D(for attributes: UICollectionViewLayoutAttributes) -> CATransform3D {
//        
//        var prespective = CATransform3DIdentity
//        prespective.m34 = -1.0 / 400
//        
//        let angle = getAngle(for: attributes)
//        var transform = CATransform3DRotate(prespective, angle, 0, 1, 0)
//        transform = CATransform3DTranslate(transform, angle * 125, 0, 0)
//        
//        return transform
//    }
//    
//    private func getAngle(for attributes: UICollectionViewLayoutAttributes) -> CGFloat {
//        guard let cv = collectionView else { return .zero }
//        
//        let visibleRect = CGRect(origin: cv.contentOffset, size: cv.bounds.size)
//        let center = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
//        
//        let itemDistanceFromCenter = attributes.center.x - center.x
//        let totalSpaceFromCenterToEdge = (visibleRect.maxX - visibleRect.minX) / 2.0
//        
//        // Capping the factor between -1, 1
//        let distanceFactor = max(-1, min(1, itemDistanceFromCenter / totalSpaceFromCenterToEdge))
//        let angle = -1 * distanceFactor * maxRotationAngle
//        
//        print(attributes.indexPath.item, distanceFactor)
//        
//        return angle
//    }
//}
