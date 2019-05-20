//
//  ViewController.swift
//  DCFramework
//
//  Created by fighter on 2019/4/29.
//  Copyright © 2019 Dotry. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let vc = DCEditImageController()
        vc.originImage = UIImage(contentsOfFile: Bundle(for: ViewController.self).path(forResource: "xcode", ofType: "jpeg")!)
        vc.delegate = self
        vc.editSize = CGSize(width: 300, height: 200)
        present(vc, animated: true, completion: nil)
    }
}

extension ViewController: DCEditImageControllerDelegate {
    func editController(_ vc: DCEditImageController, finishEdit shotImage: UIImage?, for originImage: UIImage?) {
        imageView.image = shotImage
        print(shotImage ~= originImage)
        vc.dismiss(animated: true, completion: nil)
    }
    
    func editControllerDidClickCancel(_ vc: DCEditImageController) {
        vc.dismiss(animated: true, completion: nil)
    }
}
