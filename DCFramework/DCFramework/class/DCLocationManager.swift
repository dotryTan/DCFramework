//
//  DCLocationManager.swift
//  DCFramework
//
//  Created by fighter on 2019/5/5.
//  Copyright © 2019 Dotry. All rights reserved.
//

import CoreLocation.CLLocationManager
import UIKit.UIAlertController

public class DCLocationManager: NSObject {
    
    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()
    public var cancelWhenDidUpdateLocations = true
    public var didUpdateLocations: ((CLPlacemark) -> Void)?
    
    override init() {
        super.init()
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.allowsBackgroundLocationUpdates = true
        manager.requestAlwaysAuthorization()
        manager.requestWhenInUseAuthorization()
    }
    
    func startUpdateLocation() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .restricted, .denied:
            let alert = UIAlertController(title: nil, message: "该App没有访问位置的权限，请到手机设置中心更改。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "设置", style: .default, handler: { (_) in
                let url = URL(string: UIApplication.openSettingsURLString)!
                guard UIApplication.shared.canOpenURL(url) else { return }
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }))
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            let rootVC = UIApplication.shared.keyWindow?.rootViewController
            rootVC?.present(alert, animated: true, completion: nil)
        case .authorizedAlways:
            manager.startUpdatingLocation()
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
        @unknown default: break
        }
    }
}

extension DCLocationManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        geocoder.reverseGeocodeLocation(locations.last!) { [weak self] (places, error) in
            guard let `self` = self, let places = places else { return }
            if self.cancelWhenDidUpdateLocations {
                self.geocoder.cancelGeocode()
                self.manager.stopUpdatingLocation()
            }
            self.didUpdateLocations?(places[0])
        }
    }
}
