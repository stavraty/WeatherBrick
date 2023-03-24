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
    @IBOutlet weak var BackToHomeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        infoView.layer.cornerRadius = 10
        infoView.layer.masksToBounds = true

        infoView.layer.shadowColor = UIColor(red: 251/255, green: 95/255, blue: 41/255, alpha: 1).cgColor
        infoView.layer.shadowOpacity = 1
        infoView.layer.shadowOffset = CGSize(width: 2, height: 2)
        infoView.layer.shadowRadius = 5
    }
    
    @IBAction func backToHome(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
