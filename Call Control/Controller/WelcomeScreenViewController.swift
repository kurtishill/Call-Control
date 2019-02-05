//
//  WelcomeScreenViewController.swift
//  Call Control
//
//  Created by Kurtis Hill on 2/4/19.
//  Copyright © 2019 Kurtis Hill. All rights reserved.
//

import UIKit

class WelcomeScreenViewController: UIViewController {
    
    
    @IBAction func continueToAppButtonTapped(_ sender: UIButton) {
        
        UserDefaults.standard.set(true, forKey: "first-time")
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
}
