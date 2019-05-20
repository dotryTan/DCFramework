//
//  DCCountDownTextView.swift
//  DCFramework
//
//  Created by fighter on 2019/5/1.
//  Copyright © 2019 Dotry. All rights reserved.
//

import UIKit.UITextView
import RxCocoa
import NSObject_Rx

class DCCountDownTextView: UIView {
    private let textView = DCTextView()
    private let placeholderLabel = UILabel()
    private let lengthLabel = UILabel()
    @IBInspectable var maxLength: UInt = 0 {
        didSet {
            textView.maxLength = maxLength
            lengthLabel.text = String.init(format: "%lu/%lu字", textView.text.count, maxLength)
        }
    }
    @IBInspectable var isHiddenLength: Bool = false {
        willSet {
            lengthLabel.isHidden = newValue
            textView.snp.updateConstraints { (make) in
                make.bottom.equalTo(newValue ? 0 : -20)
            }
        }
    }
    @IBInspectable var text: String? {
        set {
            textView.text = newValue ?? ""
        }
        get {
            return textView.text
        }
    }
    @IBInspectable var font = UIFont.systemFont(ofSize: 13) {
        didSet {
            textView.font = font
            placeholderLabel.font = font
        }
    }
    @IBInspectable var lengthFont = UIFont.systemFont(ofSize: 12) {
        didSet {
            lengthLabel.font = lengthFont
        }
    }
    @IBInspectable var textColor = UIColor(hex: 0x333333) {
        didSet {
            textView.textColor = textColor
        }
    }
    @IBInspectable var placeholderColor = UIColor.gray {
        didSet {
            placeholderLabel.textColor = placeholderColor
        }
    }
    @IBInspectable var lengthColor = UIColor(hex: 0x666666) {
        didSet {
            lengthLabel.textColor = lengthColor
        }
    }
    @IBInspectable var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
        }
    }
    @IBInspectable var isFilterEmoji: Bool = false
    var textDidChanged: ((String) -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        configSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configSubViews()
    }
    
    private func configSubViews() {
        backgroundColor = UIColor(hex: 0xf8f8f8)
        cornerRadius = 5
        borderWidth = 1
        borderColor = UIColor(hex: 0xadadad)

        textView.delegate = self
        textView.textColor = textColor
        textView.backgroundColor = .clear
        textView.font = font
        addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.bottom.equalTo(-20)
            make.left.equalTo(3.5)
            make.right.equalTo(-3.5)
        }
        textView.rx.text.changed.subscribe(onNext: { [weak self] (text) in
            guard let `self` = self else { return }
            print(text?.count ~= 0)
            self.placeholderLabel.isHidden = !(text?.count ~= 0)
            if let markedTextRange = self.textView.markedTextRange {
                let start = markedTextRange.start
                let end = markedTextRange.end
                let count = self.textView.offset(from: start, to: end)
                self.lengthLabel.text = String(format: "%lu/%lu字", self.textView.text.count - count, self.maxLength)
            } else {
                self.lengthLabel.text = String(format: "%lu/%lu字", self.textView.text.count, self.maxLength)
            }
            self.textDidChanged?(self.textView.text)
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: rx.disposeBag)
        
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.backgroundColor = .clear
        placeholderLabel.numberOfLines = 0
        addSubview(placeholderLabel)
        placeholderLabel.snp.makeConstraints { (make) in
            make.left.equalTo(6)
            make.right.equalTo(-6)
            make.top.equalTo(6)
//            make.height.equalTo(20)
        }

        lengthLabel.backgroundColor = .clear
        lengthLabel.font = lengthFont
        lengthLabel.textColor = lengthColor
        lengthLabel.textAlignment = .right
        addSubview(lengthLabel)
        lengthLabel.snp.makeConstraints { (make) in
            make.right.equalTo(-5)
            make.bottom.equalTo(-5)
            make.width.equalTo(80)
            make.height.equalTo(20)
        }
    }
}

extension DCCountDownTextView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if isFilterEmoji {
            return text.count > 0 ? !text.isContainsEmoji : true
        } else {
            return true
        }
    }
}
