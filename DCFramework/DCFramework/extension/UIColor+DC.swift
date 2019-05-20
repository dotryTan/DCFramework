//
//  AppDelegate.swift
//  DCFramework
//
//  Created by fighter on 2019/4/29.
//  Copyright © 2019 Dotry. All rights reserved.
//

import UIKit.UIColor

public extension UIColor {
    convenience init(hex: UInt32) {
        var red, green, blue, alpha: UInt32
        if hex > 0xffffff {
            blue = hex & 0x000000ff
            green = (hex & 0x0000ff00) >> 8
            red = (hex & 0x00ff0000) >> 16
            alpha = (hex & 0xff000000) >> 24
        } else {
            blue = hex & 0x0000ff
            green = (hex & 0x00ff00) >> 8
            red = (hex & 0xff0000) >> 16
            alpha = 255
        }
        self.init(red: CGFloat(red) / (255.0), green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: CGFloat(alpha) / 255.0)
    }
    
    convenience init(hexStr: String) {
        var red: UInt32 = 0, green: UInt32 = 0, blue: UInt32 = 0
        var hex = hexStr
        
        if hex.hasPrefix("#") {
            hex = String(hex[hex.index(after: hex.startIndex)...])
        }
        
        Scanner(string: String(hex[hex.startIndex..<hex.index(hex.startIndex, offsetBy: 2)])).scanHexInt32(&red)
        Scanner(string: String(hex[hex.index(hex.startIndex, offsetBy: 2)..<hex.index(hex.startIndex, offsetBy: 4)])).scanHexInt32(&green)
        Scanner(string: String(hex[hex.index(hex.startIndex, offsetBy: 4)...])).scanHexInt32(&blue)
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
}

