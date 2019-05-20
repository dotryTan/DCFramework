//
//  DCEditImageEditView.swift
//  DCFramework
//
//  Created by fighter on 2019/5/6.
//  Copyright © 2019 Dotry. All rights reserved.
//

import UIKit

protocol DCEditImageEditViewDelegate: NSObjectProtocol {
    func editView(_ editView: DCEditImageEditView, anchorPointIndex: Int, rect: CGRect) -> Void
}

class DCEditImageEditView: UIView {
    weak var delegate: DCEditImageEditViewDelegate?
    var maskAnimated = true
    
    private let maskview = UIView()
    private let preView = UIView()
    private let lineWrap = UIView()
    private let imageWrap = UIView()

    private var isMoving = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let rect = convert(superview!.frame, from: superview)
        maskview.snp.remakeConstraints { (make) in
            make.top.equalTo(rect.origin.y)
            make.left.equalTo(rect.origin.x)
            make.size.equalTo(rect.size)
        }
        
        let path = UIBezierPath(rect: CGRect(origin: .zero, size: rect.size))
        path.append(UIBezierPath(rect: frame).reversing())
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.backgroundColor = UIColor.red.cgColor
        maskview.layer.mask = layer
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        maskview.backgroundColor = UIColor(white: 0, alpha: 0.5)
        addSubview(maskview)
        
        addSubview(preView)
        preView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        preView.addSubview(lineWrap)
        lineWrap.snp.makeConstraints { (make) in
            make.top.left.size.equalToSuperview()
        }
        
        lineWrap.addSubview(imageWrap)
        imageWrap.snp.makeConstraints { (make) in
            make.top.left.equalTo(-1.5)
            make.bottom.right.equalTo(1.5)
        }
        
        let images = ["cycle_top_left", "cycle_top_right", "cycle_bottom_left", "cycle_bottom_right"]
        for i in 0..<4 {
            let line = UIView()
            line.layer.backgroundColor = UIColor.white.cgColor
            line.shadowColor = UIColor(white: 0, alpha: 0.5)
            line.shadowOffset = .zero
            line.shadowOpacity = 1
            line.shadowRadius = 2
            lineWrap.addSubview(line)
            line.snp.makeConstraints { (make) in
                if i == 0 {
                    make.top.left.right.equalTo(0)
                    make.height.equalTo(1.5)
                } else if i == 1 {
                    make.top.left.bottom.equalTo(0)
                    make.width.equalTo(1.5)
                } else if i == 2 {
                    make.top.bottom.right.equalTo(0)
                    make.width.equalTo(1.5)
                } else {
                    make.left.bottom.right.equalTo(0)
                    make.height.equalTo(1.5)
                }
            }
            
            let imageView = UIImageView()
            imageView.tag = i
            imageView.image = UIImage(contentsOfFile: Bundle.main.path(forResource: images[i], ofType: "png")!)
            imageWrap.addSubview(imageView)
            imageView.snp.makeConstraints { (make) in
                if i == 0 {
                    make.left.top.equalTo(0)
                } else if i == 1 {
                    make.right.top.equalTo(0)
                } else if i == 2 {
                    make.left.bottom.equalTo(0)
                } else {
                    make.bottom.right.equalTo(0)
                }
                make.width.height.equalTo(24)
            }
        }
        
        for i in 1..<3 {
            let row = UIView()
            row.backgroundColor = UIColor(white: 1, alpha: 0.8)
            lineWrap.addSubview(row)
            row.snp.makeConstraints { (make) in
                make.height.equalTo(1)
                make.left.right.equalTo(0)
                make.centerY.equalToSuperview().multipliedBy(Double(i * 2) / 3.0)
            }
            
            let column = UIView()
            column.backgroundColor = UIColor(white: 1, alpha: 0.8)
            lineWrap.addSubview(column)
            column.snp.makeConstraints { (make) in
                make.width.equalTo(1)
                make.top.bottom.equalTo(0)
                make.centerX.equalToSuperview().multipliedBy(Double(i * 2) / 3.0)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    internal override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for subview in imageWrap.subviews {
            let convertPoint = convert(point, to: subview)
            if subview.bounds.contains(convertPoint) {
                return subview
            }
        }
        return nil
    }
    
    internal override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        hiddenMaskView(0.33)
    }
    
    internal override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.count > 0 else { return }
        isMoving = true
        
        let current = touches.first!.location(in: self)
        guard bounds.contains(current) else { return }
        
        if touches.first?.view?.tag == 0 {
            // 左上
            var moveFit = sqrt(pow(current.x, 2) + pow(current.y, 2))
//            print("before: \(moveFit)")
            moveFit = moveFit * sin(.pi / 4)
//            print("after: \(moveFit)")
            let x = moveFit > width * 2 / 3.0 ? width * 2 / 3.0 : moveFit
            let y = height / width * x
            lineWrap.snp.remakeConstraints { (make) in
                make.top.equalTo(y)
                make.left.equalTo(x)
                make.bottom.right.equalTo(0)
            }
        } else if touches.first?.view?.tag == 1 {
            // 右上
            var moveFit = sqrt(pow(width - current.x, 2) + pow(current.y, 2))
            moveFit = moveFit * sin(.pi / 4)
            let x = moveFit > width * 2 / 3.0 ? width * 2 / 3.0 : moveFit
            let y = height / width * x
            lineWrap.snp.remakeConstraints { (make) in
                make.top.equalTo(y)
                make.right.equalTo(-x)
                make.left.bottom.equalTo(0)
            }
        } else if touches.first?.view?.tag == 2 {
            //左下
            var moveFit = sqrt(pow(current.x, 2) + pow(height - current.y, 2))
            moveFit = moveFit * sin(.pi / 4)
            let x = moveFit > width * 2 / 3.0 ? width * 2 / 3.0 : moveFit
            let y = height / width * x
            lineWrap.snp.remakeConstraints { (make) in
                make.left.equalTo(x)
                make.bottom.equalTo(-y)
                make.top.right.equalTo(0)
            }
        } else if touches.first?.view?.tag == 3 {
            // 右下
            var moveFit = sqrt(pow(width - current.x, 2) + pow(height - current.y, 2))
            moveFit = moveFit * sin(.pi / 4)
            let x = moveFit > width * 2 / 3.0 ? width * 2 / 3.0 : moveFit
            let y = height / width * x
            lineWrap.snp.remakeConstraints { (make) in
                make.right.equalTo(-x)
                make.bottom.equalTo(-y)
                make.top.left.equalTo(0)
            }
        }
    }
    
    internal override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isMoving else { return }
        
        imageWrap.isHidden = true

        guard let tag = touches.first?.view?.tag else { return }
        let orignalFrame = lineWrap.frame
        let points = [(1, 1), (0, 1), (1, 0), (0, 0)]
        lineWrap.layer.anchorPoint = CGPoint(x: points[tag].0, y: points[tag].1)
        lineWrap.frame = orignalFrame
        
        print(lineWrap.frame)
        delegate?.editView(self, anchorPointIndex: tag, rect: lineWrap.frame)
        
        UIView.animate(withDuration: 0.33, animations: {
            self.lineWrap.transform = CGAffineTransform(scaleX: self.width / self.lineWrap.width, y: self.height / self.lineWrap.height)
        }) { finished in
            self.isMoving = false
            self.imageWrap.isHidden = false
            self.lineWrap.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            self.lineWrap.transform = .identity
            self.lineWrap.snp.remakeConstraints({ (make) in
                make.edges.equalTo(0)
            })
        }
    }
    
    internal override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        lineWrap.snp.remakeConstraints { (make) in
            make.edges.equalTo(0)
        }
    }
    
    func showMaskView(_ duration: TimeInterval) {
        UIView.animate(withDuration: maskAnimated ? duration : 0) {
            self.maskview.alpha = 1
        }
    }
    
    func hiddenMaskView(_ duration: TimeInterval) {
        UIView.animate(withDuration: maskAnimated ? duration : 0) {
            self.maskview.alpha = 0
        }
    }
}
    
