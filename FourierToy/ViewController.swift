//
//  ViewController.swift
//  FourierToy
//
//  Created by Oleg on 4/17/17.
//  Copyright © 2017 eclight. All rights reserved.
//

import UIKit

extension FourierView : OptionsViewControllerDelegate {}

class ViewController: UIViewController {
    
    // MARK: - IB outlets
    
    @IBOutlet weak var fourierView: FourierView!
    @IBOutlet weak var optionsViewHiddenConstraint: NSLayoutConstraint!
    @IBOutlet weak var optionsViewVisibleConstraint: NSLayoutConstraint!
    @IBOutlet weak var optionsView: UIView!
    
    // MARK: - Construction/destruction
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - IB actions
        
    @IBAction func togglePaused() {
        fourierView.isPaused = !fourierView.isPaused
    }
    
    @IBAction func toggleOptionsVisible() {
        let shouldHideOptions = !optionsView.isHidden
        
        UIView.animate(withDuration: 0.3, animations: {
            if !shouldHideOptions {
                self.optionsView.isHidden = false
            }
            
            if shouldHideOptions {
                self.optionsViewVisibleConstraint.isActive = false
                self.optionsViewHiddenConstraint.isActive = true
            }
            else {
                self.optionsViewHiddenConstraint.isActive = false
                self.optionsViewVisibleConstraint.isActive = true
            }
            
            self.view.layoutIfNeeded()
        },
                       
        completion: { finished in
            if shouldHideOptions {
                self.optionsView.isHidden = true
            }
        })
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
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        fourierView.addGestureRecognizer(recognizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fourierView.isPaused = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fourierView.isPaused = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        if identifier == "EmbedOptionsViewSegue" {
            (segue.destination as? OptionsViewController)?.delegate = fourierView
        }
    }
    
    //MARK: - Private functions
    
    @objc
    private func tapped() {
        if !optionsView.isHidden {
            toggleOptionsVisible()
        }
    }
    
    @objc
    private func enterBackground() {
        fourierView.isPaused = true
    }
    
    @objc
    private func enterForeground() {
        fourierView.isPaused = false
    }
}

