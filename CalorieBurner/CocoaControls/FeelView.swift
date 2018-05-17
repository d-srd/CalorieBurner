//
//  FeelView.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 17/05/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit

enum Feelings {
    case bad, dissatisfied, neutral, satisfied, happy
}

class FeelView: UIView {
    @IBOutlet weak var badMoodImage: UIImageView!
    @IBOutlet weak var dissatisfiedMoodImage: UIImageView!
    @IBOutlet weak var neutralMoodImage: UIImageView!
    @IBOutlet weak var satisfiedMoodImage: UIImageView!
    @IBOutlet weak var happyMoodImage: UIImageView!
    
    var currentMood: Feelings?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        for image in [badMoodImage, dissatisfiedMoodImage, neutralMoodImage, satisfiedMoodImage, happyMoodImage] {
            // why is this configured here? because it can't be done in IB
            image?.image = image?.image?.withRenderingMode(.alwaysTemplate)
            image?.tintColor = UIColor.lightGray
            image?.image = image?.image?.withAlignmentRectInsets(UIEdgeInsets(top: -4, left: -4, bottom: -4, right: -4))
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapMoodImage(_:)))
            image?.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc private func didTapMoodImage(_ sender: UITapGestureRecognizer) {
        switch sender.view {
        case badMoodImage:
            currentMood = .bad
        case dissatisfiedMoodImage:
            currentMood = .dissatisfied
        case neutralMoodImage:
            currentMood = .neutral
        case satisfiedMoodImage:
            currentMood = .satisfied
        case happyMoodImage:
            currentMood = .happy
        default: break
        }
        print("current mood: ", currentMood)
    }
}
