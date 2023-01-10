//
//  YACircularProgressIndicator.swift
//  YACircularProgressIndicator
//
//  Created by Yasir Ali on 10/01/2023.
//

import UIKit

typealias ShadowOptions = (color: UIColor, offset: CGSize, radius: CGFloat, opacity: Float)
class YACircularProgressIndicator: UIView {
    
    
    private let animationGroupKey = "AnimationGroupKey"
    private let rotateAnimationKey = "RotatingAnimationKey"
    private let strokeColorAnimationKey = "StrokeColorAnimationKey"
    
    private var trackLayer = CAShapeLayer()
    private var shapeLayer = CAShapeLayer()
    
    private var centerPoint: CGPoint {
        let shorterSize = min(self.bounds.width, self.bounds.height)
        return CGPoint(x: shorterSize/2, y: shorterSize/2)
    }
    
    private var radius: CGFloat {
        let shorterSize = min(self.bounds.width, self.bounds.height)
        return shorterSize / 2 - self.lineWidth / 2 - padding
    }
    
    private var isAnimating = false
    
    var strokeStartDuration = CGFloat(1)
    var strokeEndDuration = CGFloat(2)
    var spinDuration = CGFloat(10)
    
    var padding = CGFloat(5)
    
    var shouldHideWhenStop = true
    var shouldShowWhenStart = true
    
    private var strokeColors = [UIColor.gray]
    private var strokeCGColors: [CGColor] {
        var cgcolors = [CGColor]()
        for color in strokeColors {
            cgcolors.append(color.cgColor)
        }
        return cgcolors
    }
    
    var lineWidth = CGFloat(1) {
        didSet {
            trackLayer.lineWidth = lineWidth
            shapeLayer.lineWidth = lineWidth
            updateLayerPaths()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 30, height: 30)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayerPaths()
        self.layer.addSublayer(trackLayer)
        self.layer.addSublayer(shapeLayer)
    }
}

extension YACircularProgressIndicator {
    
    func setupTrackLayer(strokeColor: UIColor, shadowOptions: ShadowOptions? = nil) {
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = strokeColor.cgColor
        trackLayer.lineWidth = lineWidth
        trackLayer.frame = self.bounds
        
        if let options = shadowOptions {
            trackLayer.shadowColor = options.color.cgColor
            trackLayer.shadowOffset = options.offset
            trackLayer.shadowOpacity = options.opacity
            trackLayer.shadowRadius = options.radius
        }
    }
    
    func setupShapeLayer(strokeColors: [UIColor], shadowOptions: ShadowOptions? = nil) {
        guard !strokeColors.isEmpty else { return }
        self.strokeColors = strokeColors
        shapeLayer.frame = self.bounds
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = self.strokeColors[0].cgColor
        shapeLayer.lineWidth = lineWidth
        
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = 0
        
        if let options = shadowOptions {
            shapeLayer.shadowColor = options.color.cgColor
            shapeLayer.shadowOffset = options.offset
            shapeLayer.shadowOpacity = options.opacity
            shapeLayer.shadowRadius = options.radius
        }
    }
    
    func startAnimating()
    {
        if self.isAnimating { return }
        if shouldShowWhenStart
        {
            self.isHidden = false
        }
        
        self.isAnimating = true
        shapeLayer.removeAllAnimations()
        
        let strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
        strokeStartAnimation.toValue = 1.0
        strokeStartAnimation.duration = strokeStartDuration
        strokeStartAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        strokeStartAnimation.beginTime = strokeEndDuration
        strokeStartAnimation.fillMode = .both
        strokeStartAnimation.isRemovedOnCompletion = false
        
        let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.toValue = 1.0
        strokeEndAnimation.duration = strokeEndDuration
        strokeEndAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        strokeEndAnimation.beginTime = 0
        strokeEndAnimation.fillMode = .both
        strokeEndAnimation.isRemovedOnCompletion = false
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.fromValue = 0.0;
        rotationAnimation.toValue = Double.pi * 2
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        rotationAnimation.duration = spinDuration
        rotationAnimation.beginTime = CACurrentMediaTime()
        rotationAnimation.fillMode = .both
        rotationAnimation.repeatCount = Float.greatestFiniteMagnitude
        rotationAnimation.isRemovedOnCompletion = false
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [strokeEndAnimation, strokeStartAnimation]
        animationGroup.fillMode = .both
        animationGroup.isRemovedOnCompletion = false
        animationGroup.duration = self.strokeStartDuration + self.strokeEndDuration
        animationGroup.repeatCount = Float.greatestFiniteMagnitude
        
        let strokeColorAnimation = CAKeyframeAnimation(keyPath: "strokeColor")
        strokeColorAnimation.duration = (strokeEndDuration + strokeStartDuration) * Double(strokeColors.count);
        strokeColorAnimation.fillMode = .forwards
        strokeColorAnimation.keyTimes = strokeColorAnimationKeyTimes()
        strokeColorAnimation.repeatCount = Float.greatestFiniteMagnitude;
        strokeColorAnimation.isRemovedOnCompletion = false
        strokeColorAnimation.values = strokeCGColors
        
        shapeLayer.add(animationGroup, forKey: animationGroupKey)
        shapeLayer.add(rotationAnimation, forKey: rotateAnimationKey)
        shapeLayer.add(strokeColorAnimation, forKey: strokeColorAnimationKey)
    }
    
    func stopAnimating() {
        if !isAnimating { return }
        if shouldHideWhenStop { self.isHidden = true }
        isAnimating = false
        
        shapeLayer.removeAllAnimations()
    }
}

extension YACircularProgressIndicator {
    
    private func setupView() {
        self.clipsToBounds = true
        self.backgroundColor = .clear
    }
    
    private func updateLayerPaths() {
        shapeLayer.frame = self.bounds
        trackLayer.frame = self.bounds
        
        let circularPath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: 3 * CGFloat.pi / 2, clockwise: true)
        shapeLayer.lineCap = .round
        shapeLayer.path = circularPath.cgPath
        trackLayer.lineCap = .round
        trackLayer.path = circularPath.cgPath
    }
    
    private func strokeColorAnimationKeyTimes() -> [NSNumber] {
        let colorsCount = strokeColors.count;
        if colorsCount == 0 {
            return []
        }
        
        if colorsCount == 1 {
            return [0]
        }
        
        var keyTimes = [NSNumber]()
        let step = 1 / colorsCount - 1
        
        for i in 0 ..< colorsCount {
            keyTimes.append(NSNumber(value: step * i))
        }
        
        return keyTimes
    }
}

