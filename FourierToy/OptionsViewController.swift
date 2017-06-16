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

    private let coefficientDescriptions = ["C₁", "C₂", "C₃", "C₄", "C₅", "C₆"]
    
    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    private var coefficients: [Double] {
        didSet {
            delegate?.coefficients = coefficients
        }
    }
    
    private let numberOfCoefficients = 6
    
    @IBOutlet var sliders: [UISlider]!
    
    @IBOutlet var coefficientLabels: [UILabel]!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        coefficients = [Double](repeating: 0, count: numberOfCoefficients)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        coefficients = [Double](repeating: 0, count: numberOfCoefficients)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sliders.sort(by: { $0.tag < $1.tag })
        coefficientLabels.sort(by: {$0.tag < $1.tag })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateSliders()
        updateLabels()
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
        updateLabels()
    }
    
    private func setPredefinedCoefficients(_ newCoefficients: PredefinedCoefficients){
        coefficients = newCoefficients.calculate(numberOfCoefficients)
        updateSliders()
        updateLabels()
    }
    
    private func updateSliders() {
        guard self.isViewLoaded else {
            return
        }
        
        UIView.animate(withDuration: 0.1, animations: {
            for (i, c) in self.coefficients.enumerated() {
                self.sliders[i].setValue(Float(c), animated: true)
            }
        })
    }
    
    private func updateLabels() {
        guard self.isViewLoaded else {
            return
        }
        
        for i in 0..<numberOfCoefficients {
            let s = formatter.string(for: coefficients[i])!
            coefficientLabels[i].text = "\(coefficientDescriptions[i]) = \(s)"
        }
    }
}
