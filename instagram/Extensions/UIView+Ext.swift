//
//  UIView+Ext.swift
//  instagram
//
//  Created by Müge Deniz on 3.11.2024.
//

import Foundation
import UIKit

extension UIView {
    func setCornerRadius(radius: CGFloat? = nil) {
        layer.masksToBounds = true
        if let radius = radius {
            layer.cornerRadius = radius
        } else {
            layer.cornerRadius = self.frame.height / 2
        }
    }
    func rotate360(duration: CFTimeInterval = 2.0, repeatCount: Float = Float.infinity) {
         let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
         rotation.toValue = NSNumber(value: Double.pi * 2) // 360 derece
         rotation.duration = duration
         rotation.isCumulative = true // Her döngü önceki dönüşe eklenir
         rotation.repeatCount = repeatCount
         self.layer.add(rotation, forKey: "rotate360")
     }
     
     func stopRotation() {
         self.layer.removeAnimation(forKey: "rotate360")
     }
}

