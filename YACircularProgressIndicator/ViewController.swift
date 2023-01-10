//
//  ViewController.swift
//  YACircularProgressIndicator
//
//  Created by Yasir Ali on 10/01/2023.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var indicator: YACircularProgressIndicator!
    @IBOutlet weak var startStopToggleButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureProgressIndicator()
        configureStartStopToggleButton()
    }
}

extension ViewController {
    private func configureProgressIndicator() {
        indicator.spinDuration = 5
        indicator.setupTrackLayer(strokeColor: UIColor.lightGray,
                                  shadowOptions: ShadowOptions(color: UIColor(white: 0, alpha: 0.25), offset: CGSize(width: 0, height: 0), radius: 2, opacity: 1))
        indicator.setupShapeLayer(strokeColors: [.red, .green, .blue, .brown, .magenta], shadowOptions: ShadowOptions(color: UIColor(white: 0, alpha: 0.25), offset: CGSize(width: 0, height: 0), radius: 2, opacity: 1))
        
        indicator.lineWidth = 6
    }
    
    private func configureStartStopToggleButton() {
        startStopToggleButton.setTitle("Start", for: .normal)
        startStopToggleButton.setTitle("Stop", for: .selected)
        
    }
}

extension ViewController {
    @IBAction func startStopToggleButtonTapped() {
        startStopToggleButton.isSelected = !startStopToggleButton.isSelected
        
        if startStopToggleButton.isSelected {
            indicator.startAnimating()
        } else {
            indicator.stopAnimating()
        }
    }
}
