//
//  CGSize+AZ.swift
//  AZWalkthrough
//
//  Created by Azamat Kalmurzayev on 4/8/18.
//

import Foundation
extension CGSize {
    
    /// Return size where width and height property increased by multiplier times.
    ///
    /// Usage:
    ///
    ///     var size = CGSizeMake(500, 200)
    ///     size.increaseBy(multiplier: 10) // {w 5,000 h 2,000}
    ///
    public func increase(by multiplier: CGFloat) -> CGSize {
        return CGSize(width: width * multiplier, height: height * multiplier)
    }
    
    public func increase(by dx: CGFloat, dy: CGFloat) -> CGSize {
        return CGSize(width: width + dx, height: height + dy)
    }
}
