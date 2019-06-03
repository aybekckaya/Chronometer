//
//  DisplayLink.swift
//  CADisplayLinkAnimations
//
//  Created by aybek can kaya on 9.03.2019.
//  Copyright © 2019 aybek can kaya. All rights reserved.
//

import UIKit

class DisplayLink: NSObject {

    private var displayLink:CADisplayLink!
    private var startTime:CFTimeInterval = CACurrentMediaTime()
    
    var displayLinkUpdated:((_ timeElapsed:CFTimeInterval)->())?
    
    override init() {
        super.init()
    }
    
    func startDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        startTime = CACurrentMediaTime()
        displayLink.add(to: .main, forMode: RunLoop.Mode.common)
    }
    
    func releaseDisplayLink() {
        displayLink.remove(from: .main, forMode: RunLoop.Mode.common)
    }
    
    @objc private func update() {
        guard let closure = displayLinkUpdated else { return }
        let elapsedTime:CFTimeInterval = CACurrentMediaTime() - startTime
        closure(elapsedTime)
    }
}
