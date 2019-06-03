//
//  ChronometerVC.swift
//  CADisplayLinkAnimations
//
//  Created by aybek can kaya on 24.05.2019.
//  Copyright © 2019 aybek can kaya. All rights reserved.
//

import UIKit

struct PulseConfiguration {
    // static values
    private var scaleChangeAmount:CGFloat = 0.015
    private var maxScale:CGFloat = 1.5
    private var minScale:CGFloat = 1
    
    // dynamic Values
    private var currentScale:CGFloat = 1
    private var isExpanding:Bool = true
    
    init(scaleChangeAmount:CGFloat =  0.015  , minScale:CGFloat = 1.5 , maxScale:CGFloat = 1) {
        self.scaleChangeAmount = scaleChangeAmount
        self.minScale = minScale
        self.maxScale = maxScale
    }
    
    mutating func scale(_currentScale:CGFloat? = nil)->CGFloat {
        if let sc = _currentScale { currentScale = sc }
        let scaleChangeValue = isExpanding == true ? scaleChangeAmount : (-1) * scaleChangeAmount
        currentScale += scaleChangeValue
        if currentScale >= maxScale { isExpanding = false }
        else if currentScale <= minScale { isExpanding = true }
        return currentScale
    }
}

class ChronometerVC: UIViewController {

    private var displayLink:DisplayLink?
    private var currentPulseConfig:PulseConfiguration = PulseConfiguration()
    
    private let pulsatingLayer:CAShapeLayer = {
        let path = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.strokeColor = UIColor.clear.cgColor
        layer.lineWidth = 10
        layer.fillColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1).withAlphaComponent(1).cgColor
        layer.lineCap = CAShapeLayerLineCap.round
        return layer
    }()
    
    private let lblCounter:UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "Verdana", size: 28)
        lbl.textAlignment = NSTextAlignment.center
        lbl.textColor = UIColor.white.withAlphaComponent(0.8)
        return lbl
    }()
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        displayLink?.releaseDisplayLink()
        self.displayLink = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpDisplayLink()
        setUpUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    private func setUpDisplayLink() {
        guard displayLink == nil else { return }
        displayLink = DisplayLink()
        displayLink?.displayLinkUpdated = { timeInterval in
           self.updateCounter(timeInterval: timeInterval)
           self.updatePulsingLayer(timeInterval: timeInterval)
        }
        displayLink?.startDisplayLink()
        
    }
    
    private func updateCounter(timeInterval:CFTimeInterval) {
        let minutes:Int = Int(timeInterval/60)
        let seconds:Int = Int(timeInterval) - minutes*60
        let miliseconds:Int = Int((timeInterval - Double(minutes)*60 - Double(seconds))*1000)
        self.lblCounter.text = minutes.timeString(digits: 2)+":"+seconds.timeString(digits: 2)+":"+miliseconds.timeString(digits:3)
    }
    
    private func updatePulsingLayer(timeInterval:CFTimeInterval) {
        pulsatingLayer.transform = CATransform3DMakeScale(currentPulseConfig.scale(), currentPulseConfig.scale(), 1)
    }
    
    
    private func setUpUI() {
        self.view.layer.addSublayer(pulsatingLayer)
        self.view.addSubview(lblCounter)
        lblCounter.text = ""
        pulsatingLayer.position = self.view.center
        lblCounter.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        lblCounter.center = self.view.center
    }

}

extension Int {
    func timeString(digits:Int)->String {
        var str:String = String(describing:self)
        if str.count >= digits {
            return str
        }
        for _ in 0..<digits - str.count {
            str = "0"+str
        }
        return str
    }
}
