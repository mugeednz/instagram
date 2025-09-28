//
//  GradientRoundedView.swift
//  instagram
//
//  Created by Müge Deniz on 24.11.2024.
//

import UIKit

class GradientRoundedView: UIView {

    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        
        let cornerRadius = bounds.height / 2
        let maskPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = maskPath.cgPath
        gradientLayer.mask = shapeLayer
    }

    private func setupGradient() {
        gradientLayer.colors = [
            UIColor.systemPink.cgColor,
            UIColor.systemOrange.cgColor,
            UIColor.systemRed.cgColor,
            UIColor.systemPurple.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
