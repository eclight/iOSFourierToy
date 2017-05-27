//
//  FourierView.swift
//  FourierToy
//
//  Created by Oleg on 4/17/17.
//  Copyright © 2017 eclight. All rights reserved.
//

import UIKit

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }
}

class FourierView : UIView {
        
    static let circleLineColor = UIColor.blue
    static let circleMarkerColor = UIColor.red
    
    // MARK: - Public properties
    
    var unitsPerFrame: Double = 0.005
    
    var isPaused: Bool {
        set { displayLinker.isPaused = newValue; }
        get { return displayLinker.isPaused; }
    }
    
    var primaryGraphColor = UIColor(red: 0.1725, green: 0.7059, blue: 0.8667, alpha: 1.0)
    var secondaryGraphColor = UIColor(red: 0.1725, green: 0.7059, blue: 0.8667, alpha: 1.0)
    var axesColor = UIColor(red: 0.9176, green: 0.9176, blue: 0.9176, alpha: 1.0)
    var circlesColor = UIColor(red: 0.8176, green: 0.8176, blue: 0.8176, alpha: 1.0)
    var primaryGraphLineWidth: CGFloat = 3
    
    // MARK: - Private properties
    
    private var displayLinker: DisplayLinker!
    private let period = 1.0
    private let domain = 0.0...1.5
    private let range = -1.5...1.5
    private var currentSampleIndex = 0
    private var samplingStep = 0.0
    private var graphFrame = CGRect.zero
    private var coefficients = [Double]()
    private var samples = [Sample]()
    private var graphPath: CGPath!
    

    // MARK: - Constructors
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - UIView overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let splitRatio: CGFloat = 0.3
        let w1 = frame.width * splitRatio
        let w2 = frame.width * (1.0 - splitRatio)
        graphFrame = CGRect(x: frame.minX + w1, y: frame.minY, width: w2, height: frame.height)
        
        recalculateSamples()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            fatalError("UIGraphicsGetCurrentContext returned nil")
        }
        
        let xAxisScale = graphFrame.width / CGFloat(domain.upperBound - domain.lowerBound)
        let yAxisScale = graphFrame.height / CGFloat(range.upperBound - range.lowerBound)
        let origin = CGPoint(x: graphFrame.minX, y: 0.5 * graphFrame.height)
        
        // Axes
        
        context.setStrokeColor(axesColor.cgColor)
        context.setLineWidth(1.0)
        context.strokeLineSegments(between: [
            
            // Horizontal
            CGPoint(x: frame.minX, y: 0.5 * frame.height), CGPoint(x: frame.maxX, y: 0.5 * frame.height),
            
            // Vertical
            CGPoint(x: graphFrame.minX, y: 0), CGPoint(x: graphFrame.minX, y: frame.height)
            
            ])
        
        // Origin
        
        context.strokeCircle(at: CGPoint(x: graphFrame.minX, y: graphFrame.midY), radius: 5)
        
        // Graphs
        
        context.saveGState()
        context.clip(to: graphFrame)
        
        context.saveGState()
        context.translateBy(x: origin.x, y: origin.y)
        context.scaleBy(x: xAxisScale, y: yAxisScale)
        
        var offset = CGFloat(-Double(currentSampleIndex) * samplingStep)
        while offset < CGFloat(domain.upperBound) {
            context.saveGState()
            context.translateBy(x: offset, y: 0)
            context.addPath(graphPath)
            offset += CGFloat(period)
            context.restoreGState()
        }
        context.restoreGState()
        
        context.setStrokeColor(primaryGraphColor.cgColor)
        context.setLineWidth(primaryGraphLineWidth)
        context.strokePath()
        
        context.restoreGState()
        
        context.translateBy(x: origin.x, y: origin.y)
        context.scaleBy(x: yAxisScale, y: yAxisScale)
        
        // Current Y value marker
        
        let currentSample = samples[currentSampleIndex]
        
        let point = CGPoint(x: 0, y: currentSample.y.last!.partialSum)
        context.setFillColor(primaryGraphColor.cgColor)
        context.fillCircle(at: point, radius: 3.0 / yAxisScale)
        
        // Circles
        
        context.setLineWidth(1.0 / yAxisScale)
        var currentCenter = CGPoint.zero
        
        context.setFillColor(UIColor.red.cgColor)
        
        for i in 0..<coefficients.count {
            context.setStrokeColor(circlesColor.cgColor)
            context.strokeCircle(at: currentCenter, radius: CGFloat(coefficients[i]))
            
            let currentPoint = CGPoint(x: currentSample.x[i].partialSum, y: currentSample.y[i].partialSum)
            context.setStrokeColor(UIColor.red.cgColor)
            context.fillCircle(at: currentPoint, radius: 3.0 / yAxisScale)
            context.strokeLineSegments(between: [
                currentCenter,
                currentPoint
            ])
            
            currentCenter = currentPoint
        }
        
        context.setStrokeColor(primaryGraphColor.cgColor)
        context.strokeLineSegments(between: [
            currentCenter,
            CGPoint(x: 0, y: currentCenter.y)
            ])
    }
    
    //MARK: - Private functions
    
    private func setup() {
        displayLinker = DisplayLinker({
            [unowned self] delta in self.update(delta: delta)
        })
        
        backgroundColor = UIColor.white
        coefficients = PredefinedCoefficients.square.calculate(6)
    }
    
    private func update(delta: CFTimeInterval) {
        let samplesPerFrame = Int(floor(unitsPerFrame / samplingStep))
        currentSampleIndex  = (currentSampleIndex + samplesPerFrame) % samples.count
        setNeedsDisplay()
    }
    
    private func recalculateSamples() {
        let domainLength = domain.upperBound - domain.lowerBound
        let screenWidthForPeriod = Double(graphFrame.width) * period / domainLength
        let numberOfSamplesForPeriod = Int(ceil(screenWidthForPeriod)) + 1
        samplingStep = period / Double(numberOfSamplesForPeriod - 1)
    
        samples.removeAll(keepingCapacity: true)
        
        var currentArgument = 0.0
        for _ in 0..<numberOfSamplesForPeriod {
            samples.append(calculateFourierSample(currentArgument, coefficients: coefficients))
            currentArgument += samplingStep
        }
        
        let path = CGMutablePath()
        var firstPoint = true
        
        for sample in samples {
            let x = sample.argument
            let y = sample.y.last!.partialSum
            
            let point = CGPoint(x: x, y: y)
            
            if firstPoint {
                path.move(to: point)
                firstPoint = false
            } else {
                path.addLine(to: point)
            }
        }
        
        graphPath = path
    }
}
