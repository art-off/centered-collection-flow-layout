import UIKit

public protocol CenteredCollectionFlowLayoutDelegate: AnyObject {

    // Size for cell in indexPath
    func centeredCollecitonFlowLayout(sizeFor indexPath: IndexPath) -> CGSize

    // Offset by collecitonView horizontal edges
    func centeredCollectionFlowLayoutOffsetConstant() -> CGFloat
}
