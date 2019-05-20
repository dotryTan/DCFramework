//
//  DCEditImageActionView.swift
//  DCFramework
//
//  Created by fighter on 2019/5/6.
//  Copyright © 2019 Dotry. All rights reserved.
//

import UIKit

protocol DCEditImageActionViewDelegate: NSObjectProtocol {
    func actionView(_ view: DCEditImageActionView, didClick button: UIButton, at index: Int) -> Void
}

class DCEditImageActionView: UIView {
    let rotateButton = UIButton()
    let cancelButton = UIButton()
    let originButton = UIButton()
    let finishButton = UIButton()
    weak var delegate: DCEditImageActionViewDelegate?
    private let line = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(white: 0, alpha: 0.85)
        
        rotateButton.setImage(UIImage(contentsOfFile: Bundle.main.path(forResource: "ic_rotate_90_degrees_ccw", ofType: "png")!), for: .normal)
        rotateButton.tag = 0
        rotateButton.imageView?.contentMode = .scaleAspectFit
        rotateButton.imageView?.snp.makeConstraints({ (make) in
            make.width.height.equalTo(25)
            make.center.equalToSuperview()
        })
        rotateButton.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        addSubview(rotateButton)
        rotateButton.snp.makeConstraints { (make) in
            make.top.left.equalTo(0)
            make.width.equalTo(25 + 40)
            make.height.equalTo(49)
        }
        
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        cancelButton.tag = 1
        cancelButton.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        addSubview(cancelButton)
        cancelButton.snp.makeConstraints { (make) in
            make.top.equalTo(49)
            make.left.equalTo(20)
            make.width.equalTo(50)
            make.height.equalTo(49)
        }
        
        originButton.setTitle("还原", for: .normal)
        originButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        originButton.tag = 2
        originButton.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        addSubview(originButton)
        originButton.snp.makeConstraints { (make) in
            make.top.equalTo(49)
            make.centerX.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(49)
        }
        
        finishButton.setTitle("完成", for: .normal)
        finishButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        finishButton.tag = 3
        finishButton.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        addSubview(finishButton)
        finishButton.snp.makeConstraints { (make) in
            make.top.equalTo(49)
            make.right.equalTo(-20)
            make.width.equalTo(50)
            make.height.equalTo(49)
        }
        
        line.backgroundColor = UIColor(white: 1, alpha: 0.3)
        addSubview(line)
        line.snp.makeConstraints { (make) in
            make.top.equalTo(49)
            make.left.right.equalTo(0)
            make.height.equalTo(0.75)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc private func buttonAction(_ button: UIButton) -> Void {
        delegate?.actionView(self, didClick: button, at: button.tag)
    }
}

