//
//  DisplayLinker.swift
//  FourierToy
//
//  Created by Oleg on 4/17/17.
//  Copyright © 2017 eclight. All rights reserved.
//

import UIKit

class DisplayLinker : NSObject {
    var displayLink: CADisplayLink!
    var updateHandler: (CFTimeInterval) -> Void
    var firstUpdate = true
    var previousTime: CFTimeInterval = 0
    
    init(_ updateHandler: @escaping (CFTimeInterval) -> Void) {
        self.updateHandler = updateHandler
        super.init()
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkUpdated))
        displayLink.add(to: RunLoop.main, forMode: .commonModes)
    }
    
    var isPaused: Bool {
        get {
            return displayLink.isPaused
        }
        
        set {
            displayLink.isPaused = newValue
            if !newValue {
                firstUpdate = true
            }
        }
    }
    
    deinit {
        displayLink.invalidate()
    }
    
    @objc
    private func displayLinkUpdated() {
        let time = displayLink.timestamp
        var delta: CFTimeInterval = 0
        
        if firstUpdate {
            firstUpdate = false
            delta = 0
        }
        else {
            delta = time - previousTime
        }
        previousTime = time
        updateHandler(delta)
    }
}
