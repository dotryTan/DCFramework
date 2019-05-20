//
//  DCTextView.swift
//  DCFramework
//
//  Created by fighter on 2019/5/1.
//  Copyright © 2019 Dotry. All rights reserved.
//

import UIKit.UITextView

class DCTextView: UITextView {
    @IBInspectable var maxLength: UInt = 0
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        config()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        config()
    }
    
    private func config() {
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChangeNotification), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    @objc private func textDidChangeNotification(_ notification: Notification) {
        guard let textView = notification.object as? UITextView, textView == self, let text = text, maxLength > 0, text.count >= maxLength else { return }
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
