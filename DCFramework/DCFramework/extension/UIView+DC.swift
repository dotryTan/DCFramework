//
//  UIView+DC.swift
//  DCFramework
//
//  Created by fighter on 2019/5/1.
//  Copyright © 2019 Dotry. All rights reserved.
//

import UIKit.UIView
import SnapKit

extension UIView {
    var top: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            frame.origin.y = newValue
        }
    }
    
    var left: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            frame.origin.x = newValue
        }
    }
    
    var bottom: CGFloat {
        get {
            return frame.origin.y + frame.size.height
        }
        set {
            frame.size.height = newValue - frame.origin.y
        }
    }
    
    var right: CGFloat {
        get {
            return frame.origin.x + frame.size.width
        }
        set {
            frame.size.width = newValue - frame.origin.x
        }
    }
    
    var width: CGFloat {
        get {
            return frame.size.width
        }
        set {
            frame.size.width = newValue
        }
    }
    
    var height: CGFloat {
        get {
            return frame.size.height
        }
        set {
            frame.size.height = newValue
        }
    }
    
    var size: CGSize {
        get {
            return frame.size
        }
        set {
            frame.size = newValue
        }
    }
    
    var centerX: CGFloat {
        set {
            center.x = newValue
        }
        
        get{
            return center.x
        }
    }
    
    var centerY:CGFloat {
        set {
            center.y = newValue
        }
        
        get {
            return center.y
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue.cgColor
        }
    }
    
    @IBInspectable var shadowColor: UIColor {
        get {
            return UIColor(cgColor: layer.shadowColor!)
        }
        set {
            layer.shadowColor = newValue.cgColor
        }
    }
    
    @IBInspectable var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable var isClipsToBounds: Bool {
        get {
            return clipsToBounds
        }
        
        set {
            clipsToBounds = newValue
        }
    }
    
    var controller: UIViewController? {
        get {
            var nextResponder: UIResponder?
            nextResponder = next
            repeat {
                if nextResponder?.isKind(of: UIViewController.self) == true {
                    return (nextResponder as! UIViewController)
                }else {
                    nextResponder = nextResponder?.next
                }
            } while nextResponder != nil
            return nil
        }
    }
    
    public func round(corners: UIRectCorner = UIRectCorner.allCorners, cornerRadi: CGFloat = 0) {
        let r = cornerRadi == 0 ? min(self.width, self.height) / 2 : cornerRadi
        self.round(corners: corners, size: CGSize.init(width: r, height: r))
    }
    
    public func round(corners: UIRectCorner = UIRectCorner.allCorners, size: CGSize) {
        if let maskLater = self.layer.mask {
            let rect = self.bounds
            let bezierPath = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: size)
            defer {
                bezierPath.close()
            }
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = bezierPath.cgPath
            self.layer.mask = shapeLayer
            self.layer.masksToBounds = true
        }
    }
    
    public func snapshot(rect: CGRect = CGRect.zero, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
        defer {
            UIGraphicsEndImageContext()
        }
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }
    
    func calculateSnapshotRect() -> CGRect {
        var targetRect = self.bounds
        if let scrollView = self as? UIScrollView {
            let contentInset = scrollView.contentInset
            let contentSize = scrollView.contentSize
            
            targetRect.origin.x = contentInset.left
            targetRect.origin.y = contentInset.top
            targetRect.size.width = targetRect.size.width  - contentInset.left - contentInset.right > contentSize.width ? targetRect.size.width  - contentInset.left - contentInset.right : contentSize.width
            targetRect.size.height = targetRect.size.height - contentInset.top - contentInset.bottom > contentSize.height ? targetRect.size.height  - contentInset.top - contentInset.bottom : contentSize.height
        }
        return targetRect
    }
    
    public func safeArea() -> UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return safeAreaInsets
        } else {
            var insets: UIEdgeInsets = .init(top: 20, left: 0, bottom: 0, right: 0)
            if let _ = controller?.navigationController {
                insets.top = 64
            }
            if let _ = controller?.tabBarController {
                insets.bottom = 49
            }
            return insets
        }
    }
    
    public func rounded(_ radius: CGFloat = 0) {
        if radius != 0 {
            cornerRadius = radius
        } else {
            let r = CGFloat.minimum(frame.size.width, frame.size.height)
            cornerRadius = r / 2
        }
        layer.masksToBounds = true
    }
}

