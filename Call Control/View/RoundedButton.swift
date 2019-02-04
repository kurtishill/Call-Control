//
//  RoundedButton.swift
//  Call Control
//
//  Created by Kurtis Hill on 2/1/19.
//  Copyright © 2019 Kurtis Hill. All rights reserved.
//

import UIKit

@IBDesignable class RoundedButton: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateCornerRadius()
    }
    
    @IBInspectable var rounded: Bool = false {
        didSet {
            updateCornerRadius()
        }
    }
    
    func updateCornerRadius() {
        
        layer.cornerRadius = rounded ? frame.size.height / 4 : 0
        
    }

}
