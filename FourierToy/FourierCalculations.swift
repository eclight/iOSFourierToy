//
//  FourierCalculations.swift
//  FourierToy
//
//  Created by Oleg on 4/23/17.
//  Copyright © 2017 eclight. All rights reserved.
//

import Foundation

enum PredefinedCoefficients {
    case zero
    case square
    case triangle
    case sawtooth
    
    func calculate(_ n: Int) -> [Double] {
        switch (self) {
        case .zero: return [Double](repeating: 0, count: n)
            
        case .square: return (1...n).map { (($0 % 2 == 0) ? 0 : 1) / Double($0) }
          
        case .triangle: return (1...n).map {
            if $0 % 2 == 1 {
                return pow(-1, 0.5 * Double($0 - 1)) / Double($0 * $0);
            }
            
            return 0;
            }
            
            
        case .sawtooth: return (1...n).map { 0.5 / Double($0) }
    
        }
    }
}

struct Sample {
    let argument: Double
    let x: [SeriesMember]
    let y: [SeriesMember]
}

typealias SeriesMember = (partialSum: Double, value: Double)

func calculateFourierSample(_ argument: Double, coefficients: [Double]) -> Sample {
    return Sample(argument: argument,
                        x: calculateFourierSeries(coefficients: coefficients, x: argument, shiftedBy: Double.pi * 0.5),
                        y: calculateFourierSeries(coefficients: coefficients, x: argument, shiftedBy: 0))
}

fileprivate func calculateFourierSeries(coefficients: [Double], x: Double, shiftedBy shift: Double) -> [SeriesMember] {
    var partialSum: Double = 0
    var result = [SeriesMember]()
    for (n, coefficient) in coefficients.enumerated() {
        let value = coefficient * sin(2 * Double.pi * Double(n + 1) * x + shift)
        partialSum += value
        result.append((partialSum: partialSum, value: value))
    }
    
    return result
}
