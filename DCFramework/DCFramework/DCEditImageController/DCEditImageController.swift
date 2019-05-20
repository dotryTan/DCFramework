//
//  DCEditImageController.swift
//  DCFramework
//
//  Created by fighter on 2019/5/6.
//  Copyright © 2019 Dotry. All rights reserved.
//

import UIKit

protocol DCEditImageControllerDelegate: NSObjectProtocol {
    func editController(_ vc: DCEditImageController, finishEdit shotImage: UIImage?, for originImage: UIImage?) -> Void
    func editControllerDidClickCancel(_ vc: DCEditImageController) -> Void
}

class DCEditImageController: UIViewController {
    var originImage: UIImage!
    var editSize = CGSize(width: UIScreen.main.bounds.width - 20 * 2, height: UIScreen.main.bounds.width - 20 * 2)
    var maskAnimated = true
    weak var delegate: DCEditImageControllerDelegate?
    
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    private let editView = DCEditImageEditView()
    private let actionView = DCEditImageActionView()
    private let captureView = DCEditImageCaptureView()
    
    private var showNavigationBarWhenPop = false
    private var rotationTime: Int {
        get {
            return captureView.rotateTimes
        }
        set {
            captureView.rotateTimes = newValue
        }
    }
    private var originSize: CGSize {
        let widthRadio = editSize.width / originImage.size.width
        let heightRadio = editSize.height / originImage.size.height
        return widthRadio > heightRadio ? CGSize(width: editSize.width, height: originImage.size.height * widthRadio) : CGSize(width: originImage.size.width * heightRadio, height: editSize.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        
        scrollView.delegate = self
        scrollView.clipsToBounds = false
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
        scrollView.zoomScale = 1.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.decelerationRate = .fast
        scrollView.contentInset = .zero
        scrollView.contentSize = originSize
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        captureView.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.top.left.equalTo(0)
            make.size.equalTo(editSize)
        }
        
        imageView.image = originImage
        imageView.contentMode = .scaleAspectFill
        scrollView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.left.equalTo(0)
            make.size.equalTo(originSize)
        }
        
        captureView.contentView = scrollView
        captureView.imageView = imageView
        view.addSubview(captureView)
        
        editView.delegate = self
        editView.maskAnimated = maskAnimated
        view.addSubview(editView)
        
        actionView.delegate = self
        view.addSubview(actionView)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        captureView.snp.makeConstraints { (make) in
            let top = (view.height - view.layoutMargins.top - view.layoutMargins.bottom - editSize.height) / 2
            make.top.equalTo(top)
            make.centerX.equalToSuperview()
            make.size.equalTo(editSize)
        }
        
        actionView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(view.layoutMargins.bottom + 49 * 2)
        }
        
        editView.snp.makeConstraints { (make) in
            make.center.size.equalTo(captureView)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let point = self.scrollView.convert(self.imageView.center, from: self.imageView)
            let center = CGPoint(x: abs(self.scrollView.center.x - point.x), y: abs(self.scrollView.center.y - point.y))
            self.scrollView.setContentOffset(center, animated: false)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if navigationController?.isNavigationBarHidden ~= false {
            navigationController?.setNavigationBarHidden(true, animated: true)
            showNavigationBarWhenPop = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        showNavigationBarWhenPop ? navigationController?.setNavigationBarHidden(false, animated: true) : ()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func rotateScrollView(_ times: Int) -> Void {
        UIView.animate(withDuration: 0.33, animations: {
            self.scrollView.transform = self.scrollView.transform.rotated(by: -.pi / 2)
            guard self.editSize.width != self.editSize.height else { return }
            guard times % 2 == 1 else {
                self.scrollView.transform = CGAffineTransform(rotationAngle: -CGFloat(times) * (.pi / 2))
                self.scrollView.contentInset = .zero
                return
            }
            print(self.scrollView.contentOffset)
            if self.editSize.width * self.scrollView.zoomScale < self.editSize.height {
                let scale = self.editSize.height / self.editSize.width / self.scrollView.zoomScale
                self.scrollView.transform = self.scrollView.transform.scaledBy(x: scale, y: scale)
                let rect = self.view.convert(self.scrollView.bounds, from: self.scrollView)
                self.scrollView.contentInset = UIEdgeInsets(top: (self.captureView.left - rect.origin.x) / scale, left: 0, bottom: (self.captureView.left - rect.origin.x) / scale, right: 0)
            } else if self.editSize.width * self.scrollView.zoomScale > self.editSize.height {
                let scale = self.editSize.width / self.editSize.height / self.scrollView.zoomScale
                self.scrollView.transform = self.scrollView.transform.scaledBy(x: scale, y: scale)
                let rect = self.view.convert(self.scrollView.bounds, from: self.scrollView)
                self.scrollView.contentInset = UIEdgeInsets(top: 0, left: (self.captureView.top - rect.origin.y) / scale, bottom: 0, right: (self.captureView.top - rect.origin.y) / scale)
            }
        }) { (finished) in
            print(self.scrollView.contentOffset)
        }
    }
    
    func restoreDefault() {
        rotationTime = 0
        captureView.rotateTimes = 0
        imageView.snp.makeConstraints { (make) in
            make.top.left.equalTo(0)
            make.size.equalTo(originSize)
        }
        scrollView.contentSize = imageView.size
        scrollView.transform = .identity
        scrollView.zoomScale = 1
        scrollView.snp.remakeConstraints { (make) in
            make.edges.equalTo(0)
        }
        let point = scrollView.convert(imageView.center, from: imageView)
        let center = CGPoint(x: abs(scrollView.center.x - point.x), y: abs(scrollView.center.y - point.y))
        scrollView.setContentOffset(center, animated: false)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension DCEditImageController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("offset:", scrollView.contentOffset)
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        editView.hiddenMaskView(0.33)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            editView.showMaskView(0.33)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        editView.showMaskView(0.33)
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        editView.hiddenMaskView(0.33)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollView.setZoomScale(scale, animated: false)
        
        editView.showMaskView(0.33)
    }
}

extension DCEditImageController: DCEditImageEditViewDelegate {
    func editView(_ editView: DCEditImageEditView, anchorPointIndex: Int, rect: CGRect) {
        let imageEditRect = captureView.convert(rect, to: imageView)
        scrollView.zoom(to: imageEditRect, animated: true)
    }
}

extension DCEditImageController: DCEditImageActionViewDelegate {
    func actionView(_ view: DCEditImageActionView, didClick button: UIButton, at index: Int) {
        if index == 0 {
            rotationTime += 1
            rotateScrollView(rotationTime)
        } else if index == 1 {
            delegate?.editControllerDidClickCancel(self)
        } else if index == 2 {
            restoreDefault()
        } else if index == 3 {
            let image = captureView.captureImage()
            let originImage = captureView.captureOriginalImage()
            delegate?.editController(self, finishEdit: image, for: originImage)
        }
    }
}
