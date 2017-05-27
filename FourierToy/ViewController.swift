//
//  ViewController.swift
//  FourierToy
//
//  Created by Oleg on 4/17/17.
//  Copyright © 2017 eclight. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var fourierView: FourierView!
    
    //MARK: - Construction/destruction
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - IB actions
    
    @IBAction func tapped() {
        fourierView.isPaused = !fourierView.isPaused
    }
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(enterBackground),
                                               name: .UIApplicationWillResignActive,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterForeground),
                                               name: .UIApplicationDidBecomeActive,
                                               object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fourierView.isPaused = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fourierView.isPaused = true
    }
    
    //MARK: - Private functions
    
    @objc
    private func enterBackground() {
        fourierView.isPaused = true
    }
    
    @objc
    private func enterForeground() {
        fourierView.isPaused = false
    }
}

