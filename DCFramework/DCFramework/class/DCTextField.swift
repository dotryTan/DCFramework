//
//  AppDelegate.swift
//  DCFramework
//
//  Created by fighter on 2019/4/29.
//  Copyright © 2019 Dotry. All rights reserved.
//

import UIKit.UITextField

class DCTextField: UITextField {
    @IBInspectable var maxLength: UInt = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        config()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        config()
    }
    
    private func config() {
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChangeAction(_:)), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    @objc private func textDidChangeAction(_ notification: Notification) {
        guard let textField = notification.object as? UITextField, textField == self, let text = text, maxLength > 0, text.count >= maxLength else { return }
        if let markedTextRange = markedTextRange {
            let markedLength = offset(from: markedTextRange.start, to: markedTextRange.end)
            if text.count - markedLength > maxLength {
                let markedStart = offset(from: beginningOfDocument, to: markedTextRange.start)
                var utf16 = [UInt16](text.utf16)
                utf16.removeSubrange(markedStart..<markedStart + markedLength)
                let newText = String(utf16CodeUnits: &utf16, count: utf16.count)
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.text = newText
                    self.selectedTextRange = self.textRange(from: markedTextRange.start, to: markedTextRange.start)
                }
            }
        } else {
            let selectedTextRange = self.selectedTextRange
            self.text = String(text[text.startIndex..<text.index(text.startIndex, offsetBy: Int(maxLength))])
            self.selectedTextRange = selectedTextRange
        }
    }
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.leftViewRect(forBounds: bounds)
        rect.origin.x += 15
        return rect
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.leftViewRect(forBounds: bounds)
        rect.origin.x -= 15
        return rect
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.textRect(forBounds: bounds)
        if leftView != nil && rightView != nil {
            rect.origin.x += 10
            rect.size.width -= 20
        } else if leftView != nil && rightView == nil {
            rect.origin.x += 10
            rect.size.width -= 10
        } else if leftView == nil && rightView != nil {
            rect.size.width -= 10
        }
        return rect
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.editingRect(forBounds: bounds)
        if leftView != nil && rightView != nil {
            rect.origin.x += 10
            rect.size.width -= 20
        } else if leftView != nil && rightView == nil {
            rect.origin.x += 10
            rect.size.width -= 10
        } else if leftView == nil && rightView != nil {
            rect.size.width -= 10
        }
        return rect
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
