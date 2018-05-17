//
//  FeelView.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 17/05/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit

protocol FeelViewDelegate: class {
    func feelView(_ feelView: FeelView, didChangeMoodTo mood: Feelings)
}

class FeelView: UIView {
    @IBOutlet weak var badMoodImage: UIImageView!
    @IBOutlet weak var dissatisfiedMoodImage: UIImageView!
    @IBOutlet weak var neutralMoodImage: UIImageView!
    @IBOutlet weak var satisfiedMoodImage: UIImageView!
    @IBOutlet weak var happyMoodImage: UIImageView!
    
    private let animationDuration = 0.25
    
    weak var delegate: FeelViewDelegate?
    
    var inactiveColor = UIColor.lightGray
    var activeColor = UIColor.black
    
    var currentMood: Feelings? {
//        didSet { delegate?.feelView(self, didChangeMoodTo: currentMood) }
        get {
            guard let image = currentImage else { return nil }
            return moodForImage[image]
        } set {
            guard let mood = newValue, let image = imageForMood[mood] else { return }
            currentImage = image
            
            delegate?.feelView(self, didChangeMoodTo: mood)
        }
    }
    
    private var currentImage: UIImageView? {
        didSet {
            UIView.animate(withDuration: animationDuration) { [weak self] in
                oldValue?.tintColor = self?.inactiveColor
                self?.currentImage?.tintColor = self?.activeColor
            }
        }
    }
    
    private lazy var moodForImage = [
        badMoodImage : Feelings.bad,
        dissatisfiedMoodImage : .dissatisfied,
        neutralMoodImage : .neutral,
        satisfiedMoodImage : .satisfied,
        happyMoodImage : .happy
        ]
    
    private lazy var imageForMood = [
        Feelings.bad : badMoodImage,
        .dissatisfied : dissatisfiedMoodImage,
        .neutral : neutralMoodImage,
        .satisfied : satisfiedMoodImage,
        .happy : happyMoodImage
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        for image in [badMoodImage, dissatisfiedMoodImage, neutralMoodImage, satisfiedMoodImage, happyMoodImage] {
            // why is this configured here? because it can't be done in IB
            image?.image = image?.image?.withRenderingMode(.alwaysTemplate)
            image?.tintColor = inactiveColor
            image?.image = image?.image?.withAlignmentRectInsets(UIEdgeInsets(top: -4, left: -4, bottom: -4, right: -4))
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapMoodImage(_:)))
            image?.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc private func didTapMoodImage(_ sender: UITapGestureRecognizer) {
        if let image = sender.view as? UIImageView {
            currentMood = moodForImage[image]
        }
    }
}
