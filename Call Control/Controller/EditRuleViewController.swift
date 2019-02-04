//
//  EditRuleViewController.swift
//  Call Control
//
//  Created by Kurtis Hill on 1/31/19.
//  Copyright © 2019 Kurtis Hill. All rights reserved.
//

import UIKit

class EditRuleViewController: UIViewController {
    
    var rule: Rule? {
        didSet {
            title = "\(rule!.ruleTitle)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
