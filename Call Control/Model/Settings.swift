//
//  Settings.swift
//  Call Control
//
//  Created by Kurtis Hill on 2/1/19.
//  Copyright © 2019 Kurtis Hill. All rights reserved.
//

import Foundation
import RealmSwift

class Settings: Object {
    
    static let instance: Settings = Settings()
    var realmConfig: Realm.Configuration?

    @objc dynamic var overrideContacts: Bool = false
    @objc dynamic var primaryColor: String = "PrimaryGreen"
    @objc dynamic var primaryColorDark: String = "PrimaryDarkGreen"
    
    func changePrimaryColor(withPrimary primary: String, withPrimaryDark primaryDark: String) {
        let realm = try! Realm(configuration: realmConfig!)
            
        do {
            try realm.write {
                self.primaryColor = primary
                self.primaryColorDark = primaryDark
            }
        } catch {
            print("Error when updating primary color \(error)")
        }
        
    }
    
    func toggleOverrideContacts() -> Bool {
        let realm = try! Realm(configuration: realmConfig!)
        
        do {
            try realm.write {
                self.overrideContacts = !self.overrideContacts
            }
            return true
        } catch {
            print("Error when updating override contacts \(error)")
            return false
        }
    }
    
    func save() {
        
        let realm = try! Realm(configuration: realmConfig!)
        
        if let settings = realm.objects(Settings.self).first {
            
            do {
                try realm.write {
                    settings.overrideContacts = self.overrideContacts
                    settings.primaryColor = self.primaryColor
                    settings.primaryColorDark = self.primaryColorDark
                }
            } catch {
                print("Error updating settings \(error)")
            }
            
            
        } else {
            
            do {
                try realm.write {
                    realm.add(self)
                }
            } catch {
                print("Error saving settings \(error)")
            }
            
        }
            
    }
    
    func load() {
        
        let realm = try! Realm(configuration: realmConfig!)
        
        if let settings = realm.objects(Settings.self).first {
            
            self.overrideContacts = settings.overrideContacts
            self.primaryColor = settings.primaryColor
            self.primaryColorDark = settings.primaryColorDark
            
        }
        
    }
    
}
