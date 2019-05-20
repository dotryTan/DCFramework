//
//  NSRegularExpression+DC.swift
//  DCFramework
//
//  Created by fighter on 2019/5/5.
//  Copyright © 2019 Dotry. All rights reserved.
//

import Foundation.NSRegularExpression

extension NSRegularExpression {
    static func ~=(lhs: NSRegularExpression, rhs: String) -> Bool {
        return lhs.matches(in: rhs, options: [], range: NSRange(location: 0, length: rhs.utf16.count)).count > 0
    }
}

prefix operator ~/
prefix func ~/(pattern: String) -> NSRegularExpression {
    var regularExpression: NSRegularExpression?
    do {
        try regularExpression = NSRegularExpression(pattern: pattern, options: [])
    } catch let error {
        fatalError(error.localizedDescription)
    }
    return regularExpression!
}
