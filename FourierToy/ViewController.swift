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
    
    @IBAction func showOptions() {
        setOptionVisibility(true)
    }
    
    @IBAction func hideOptions() {
        setOptionVisibility(false)
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
    private func enterBackground() {
        fourierView.isPaused = true
    }
    
    @objc
    private func enterForeground() {
        fourierView.isPaused = false
    }
    
    private func setOptionVisibility(_ isVisible: Bool) {
        guard isVisible == optionsView.isHidden else {
            return
        }
        
        UIView.animate(withDuration: 0.3,
            animations: {
                if isVisible {
                    self.optionsView.isHidden = false
                }
                
                if !isVisible {
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
                if !isVisible {
                    self.optionsView.isHidden = true
                }
            })
    }
}

