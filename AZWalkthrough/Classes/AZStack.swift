//
//  AZStack.swift
//  SkyBank
//
//  Created by Azamat Kalmurzayev on 3/6/18.
//  Copyright © 2018 Onsolut LLC. All rights reserved.
//

import Foundation

/// Queue generic implementation
struct AZDataQueue<T> {
    var items = [T]()
    mutating func push(item: T) {
        items.append(item)
    }
    mutating func pop() -> T? {
        return count() > 0 ? items.removeFirst() : nil;
    }
    mutating func count() -> Int {
        return items.count
    }
}
