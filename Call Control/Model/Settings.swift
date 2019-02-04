//
//  Settings.swift
//  Call Control
//
//  Created by Kurtis Hill on 2/1/19.
//  Copyright © 2019 Kurtis Hill. All rights reserved.
//

import Foundation

class Settings {
    
    static let instance: Settings = Settings()

    var overrideContacts: Bool = false
    var primaryColor: String = "PrimaryGreen"
    var primaryColorDark: String = "PrimaryDarkGreen"
    
    private init(){}
    
    func changePrimaryColor(withPrimary primary: String, withPrimaryDark primaryDark: String) {
        self.primaryColor = primary
        self.primaryColorDark = primaryDark
    }
    
    func toggleOverrideContacts() {
        self.overrideContacts = !self.overrideContacts
    }
    
}
