//
//  String+AZ.swift
//  AZWalkthrough
//
//  Created by Azamat Kalmurzayev on 4/8/18.
//

import Foundation
extension String {
    /// Calculates minimum required label size for given string
    ///
    /// - Parameters:
    ///   - size: bounding size
    ///   - font: font properties
    /// - Returns: Label rect size
    func labelSize(maxSize size: CGSize, font: UIFont) -> CGSize {
        if self.isEmpty {
            return CGSize.zero;
        }
        let strRect = NSString(string: self).boundingRect(
            with: size, options: .usesLineFragmentOrigin,
            attributes: [NSAttributedStringKey.font: font],
            context: nil);
        return strRect.size;
    }
}
