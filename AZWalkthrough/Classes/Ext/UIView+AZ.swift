//
//  UIView+AZ.swift
//  AZWalkthrough
//
//  Created by Azamat Kalmurzayev on 4/8/18.
//

import Foundation
// MARK: - Subview manipulation
extension UIView {
    public func removeAllSubviews() {
        for subview in subviews {
            subview.removeFromSuperview();
        }
    }
}

extension UIView {
    /// Create snapshot
    /// If `rect` parameter is `nil` (or omitted), return snapshot of the whole view.
    ///
    /// - parameter rect: The `CGRect` of the portion of the view to return.
    ///
    /// - returns: Returns `UIImage` of the specified portion of the view.
    
    func snapshot(of rect: CGRect? = nil) -> UIImage? {
        // snapshot entire view
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let wholeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // if no `rect` provided, return image of whole view
        guard let image = wholeImage,
            let rect = rect else { return wholeImage }
        
        // otherwise, grab specified `rect` of image
        let scale = image.scale
        let scaledRect = CGRect(
            x: rect.origin.x * scale,
            y: rect.origin.y * scale,
            width: rect.size.width * scale,
            height: rect.size.height * scale)
        guard let cgImage = image.cgImage?.cropping(to: scaledRect)
            else { return nil }
        return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
    }
}
