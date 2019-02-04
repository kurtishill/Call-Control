//
//  AppSystemColorSettingsCell.swift
//  Call Control
//
//  Created by Kurtis Hill on 2/1/19.
//  Copyright © 2019 Kurtis Hill. All rights reserved.
//

import UIKit

class AppSystemColorSettingsCell: UITableViewCell {
    
    var delegate: AppSystemColorSettingsCellDelegate?
    
    @IBOutlet weak var greenColorImageView: UIImageView!
    @IBOutlet weak var blueColorImageView: UIImageView!
    @IBOutlet weak var purpleColorImageView: UIImageView!
    @IBOutlet weak var colorsStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        let greenColorTapGesture = UITapGestureRecognizer(target: self, action: #selector(greenColorImageViewTapped))
        let blueColorTapGesture = UITapGestureRecognizer(target: self, action: #selector(blueColorImageViewTapped))
        let purpleColorTapGesture = UITapGestureRecognizer(target: self, action: #selector(purpleColorImageViewTapped))
        
        greenColorImageView.addGestureRecognizer(greenColorTapGesture)
        blueColorImageView.addGestureRecognizer(blueColorTapGesture)
        purpleColorImageView.addGestureRecognizer(purpleColorTapGesture)
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func greenColorImageViewTapped() {
        
        print("green tapped")
        
        Settings.instance.changePrimaryColor(withPrimary: "PrimaryGreen", withPrimaryDark: "PrimaryDarkGreen")
        
        colorImageViewTapped()
        
    }
    
    @objc func blueColorImageViewTapped() {
        
        print("blue tapped")
        
        Settings.instance.changePrimaryColor(withPrimary: "PrimaryBlue", withPrimaryDark: "PrimaryDarkBlue")
        
        colorImageViewTapped()
        
    }
    
    @objc func purpleColorImageViewTapped() {
        
        print("purple tapped")
        
        Settings.instance.changePrimaryColor(withPrimary: "PrimaryPurple", withPrimaryDark: "PrimaryDarkPurple")
        
        colorImageViewTapped()
        
    }
    
    func colorImageViewTapped() {
        delegate?.colorChanged()
        
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

}


protocol AppSystemColorSettingsCellDelegate {
    func colorChanged()
}
