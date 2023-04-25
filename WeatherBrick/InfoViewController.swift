//
//  InfoViewController.swift
//  WeatherBrick
//
//  Created by AS on 15.03.2023.
//  Copyright © 2023 VAndrJ. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoBackgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    @IBAction func backToHome(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupViews() {
        infoView.layer.cornerRadius = 10
        infoView.layer.masksToBounds = false
        infoBackgroundView.layer.cornerRadius = 10
        infoBackgroundView.layer.shadowColor = UIColor.darkGray.cgColor
        infoBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 5)
        infoBackgroundView.layer.shadowOpacity = 0.5
        infoBackgroundView.layer.shadowRadius = 3
        infoBackgroundView.layer.masksToBounds = false
    }
}
