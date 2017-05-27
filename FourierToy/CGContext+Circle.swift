//
//  CGContext+Extensions.swift
//  FourierToy
//
//  Created by Oleg on 4/18/17.
//  Copyright © 2017 eclight. All rights reserved.
//

import CoreGraphics

fileprivate func rectForCircle(_ center: CGPoint, radius: CGFloat) -> CGRect{
    return CGRect(x: center.x - radius,
                  y: center.y - radius,
                  width: 2 * radius,
                  height: 2 * radius)
}

extension CGContext {
    func strokeCircle(at center: CGPoint, radius: CGFloat) {
        strokeEllipse(in: rectForCircle(center, radius: radius))
    }
    
    func fillCircle(at center: CGPoint, radius: CGFloat) {
        fillEllipse(in: rectForCircle(center, radius: radius))
    }
    
    func addCircle(at center: CGPoint, radius: CGFloat) {
        addEllipse(in: rectForCircle(center, radius: radius))
    }
}
