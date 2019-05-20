//
//  DCEditImageCaptureView.swift
//  DCFramework
//
//  Created by fighter on 2019/5/6.
//  Copyright © 2019 Dotry. All rights reserved.
//

import UIKit

class DCEditImageCaptureView: UIView {
    weak var imageView: UIImageView!
    weak var contentView: UIScrollView!
    var rotateTimes = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view != nil ? view : contentView
    }
    
    func captureImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
        }
        let viewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return viewImage
    }

    func captureOriginalImage() -> UIImage? {
        guard let orignaImage = imageView.image else { return nil}
        let width = contentView.width / imageView.width * orignaImage.size.width
        let height = contentView.height / contentView.width * width
        let captureSize = CGSize(width: width, height: height)
        var x = contentView.contentOffset.x / imageView.width * orignaImage.size.width
        var y = contentView.contentOffset.y / imageView.height * orignaImage.size.height
        let captureOffset = CGPoint(x: x, y: y)
        // 长宽微调
        if x + width >= imageView.width {
            x = imageView.width - width
        }
        if y + height >= imageView.height {
            y = imageView.height - height
        }
        var captureRect = CGRect.zero
        if rotateTimes % 2 == 0 {
            captureRect = CGRect(x: captureOffset.x, y: captureOffset.y, width: captureSize.width, height: captureSize.height)
        } else {
            captureRect = CGRect(x: captureOffset.x, y: captureOffset.y, width: captureSize.height, height: captureSize.width)
        }
        let temp = orignaImage.cgImage?.cropping(to: captureRect)
        guard temp != nil else { return nil }
        let orientations: [UIImage.Orientation] = [.up, .left, .down, .right]
        return UIImage(cgImage: temp!, scale: 1, orientation: orientations[rotateTimes % 4])
    }
}
