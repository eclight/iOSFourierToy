//
//  OptionsViewController.swift
//  FourierToy
//
//  Created by Oleg on 6/4/17.
//  Copyright © 2017 eclight. All rights reserved.
//

import UIKit

protocol OptionsViewControllerDelegate : class {
    var coefficients: [Double] { get set }
}

class OptionsViewController: UIViewController {
    
    weak var delegate: OptionsViewControllerDelegate? {
        didSet {
            if let delegate = delegate {
                coefficients = delegate.coefficients
            }
        }
    }
    
    private var coefficients: [Double]
    private let numberOfCoefficients = 6
    
    @IBOutlet var sliders: [UISlider]!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        coefficients = [Double](repeating: 0, count: numberOfCoefficients)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        coefficients = [Double](repeating: 0, count: numberOfCoefficients)
        super.init(coder: aDecoder)
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateSliders(coefficients: coefficients)
    }
    
    @IBAction func zeroButtonTouched() {
        setPredefinedCoefficients(.zero)
    }
    
    @IBAction func squareButtonTouched() {
        setPredefinedCoefficients(.square)
    }
    
    @IBAction func triangleButtonTouched() {
        setPredefinedCoefficients(.triangle)
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        coefficients[sender.tag] = Double(sender.value)
        delegate?.coefficients = coefficients
    }
    
    private func setPredefinedCoefficients(_ newCoefficients: PredefinedCoefficients) {
        coefficients = newCoefficients.calculate(numberOfCoefficients)
        delegate?.coefficients = coefficients
        updateSliders(coefficients: coefficients)
    }
    
    private func updateSliders(coefficients: [Double]) {
        UIView.animate(withDuration: 0.1, animations: {
            for (i, c) in coefficients.enumerated() {
                self.sliders[i].setValue(Float(c), animated: true)
            }
        })
    }
}
