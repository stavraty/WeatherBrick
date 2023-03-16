//
//  InfoViewController.swift
//  WeatherBrick
//
//  Created by AS on 15.03.2023.
//  Copyright © 2023 VAndrJ. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    
    @IBOutlet weak var BackToHomeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func backToHome(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
