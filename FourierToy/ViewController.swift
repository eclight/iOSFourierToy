//
//  ViewController.swift
//  FourierToy
//
//  Created by Oleg on 4/17/17.
//  Copyright © 2017 eclight. All rights reserved.
//

import UIKit

class ViewController: UIViewController, OptionsViewControllerDelegate {
    
    // MARK: - IB outlets
    
    @IBOutlet weak var fourierView: FourierView!
    @IBOutlet weak var optionsViewHiddenConstraint: NSLayoutConstraint!
    @IBOutlet weak var optionsViewVisibleConstraint: NSLayoutConstraint!
    @IBOutlet weak var optionsView: UIView!
	
	private var hideOptionsTimer: Timer? = nil
    
    // MARK: - Construction/destruction
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
	
	// MARK: - OptionsViewControllerDelegate
	
	var coefficients: [Double] {
		get { return fourierView.coefficients}
		
		set {
			fourierView.coefficients = newValue
			startAutoHideTimer()
		}
	}
    
    // MARK: - IB actions
    
    @IBAction func toggleOptionPanel() {
        let needToShow = optionsView.isHidden
        if needToShow {
            optionsView.isHidden = false
        }
        
        if !needToShow {
            optionsViewVisibleConstraint.isActive = false
            optionsViewHiddenConstraint.isActive = true
        }
        else {
            optionsViewHiddenConstraint.isActive = false
            optionsViewVisibleConstraint.isActive = true
        }
		
        UIView.animate(
            withDuration: 0.3,
            animations: { self.view.layoutIfNeeded() },
            completion: { _ in
                if !needToShow {
                    self.optionsView.isHidden = true
					self.stopAutoHideTimer()
                }
				else {
					self.startAutoHideTimer()
				}
            }
        )
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
            (segue.destination as? OptionsViewController)?.delegate = self
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
	
	private func startAutoHideTimer() {
		self.hideOptionsTimer?.invalidate()
		self.hideOptionsTimer = Timer.scheduledTimer(timeInterval: TimeInterval(3),
													 target: self,
													 selector: #selector(ViewController.toggleOptionPanel),
													 userInfo: nil,
													 repeats: false)
	}
	
	private func stopAutoHideTimer() {
		self.hideOptionsTimer?.invalidate()
		self.hideOptionsTimer = nil
	}
}

