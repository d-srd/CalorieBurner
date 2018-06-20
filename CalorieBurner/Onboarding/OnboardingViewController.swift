//
//  OnboardingViewController.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 13/06/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit

@objc protocol OnboardingViewControllerDelegate: AnyObject {
    @objc optional func shouldShowPage(after viewController: OnboardingViewController)
    @objc optional func shouldSkipOnboardingFlow(_ sender: OnboardingViewController)
    @objc optional func didCompleteOnboarding(_ sender: OnboardingViewController)
    @objc optional func didCompleteHealthKitIntegration(_ sender: OnboardingViewController, data: UserRepresentable)
}

class OnboardingViewController: UIViewController {
    
    weak var delegate: OnboardingViewControllerDelegate?

    @IBAction func didTapSkipButton(_ sender: UIButton) {
        delegate?.shouldSkipOnboardingFlow?(self)
    }
    
    @IBAction func didTapNextButton(_ sender: UIButton) {
        delegate?.shouldShowPage?(after: self)
    }
    
    @IBAction func didTapDoneButton(_ sender: UIButton) {
        delegate?.didCompleteOnboarding?(self)
    }
    
    @IBAction func didTapHealthButton(_ sender: UIButton) {
        HealthStoreHelper.shared.requestAuthorization { [weak self] (didShowDialogue, error) in
            guard let wself = self else { return }
            guard didShowDialogue, error == nil else {
                print("Error setting up HealthKit: ", error!.localizedDescription)
                return
            }
            
            HealthStoreHelper.shared.enableBackgroundDelivery()
            let user = HealthStoreHelper.shared.fetchUserProfile()
            wself.delegate?.didCompleteHealthKitIntegration?(wself, data: user)
        }
    }
}
