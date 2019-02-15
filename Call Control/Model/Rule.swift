//
//  Number.swift
//  Call Control
//
//  Created by Kurtis Hill on 1/30/19.
//  Copyright © 2019 Kurtis Hill. All rights reserved.
//

import Foundation
import RealmSwift
import CallKit

class Rule: Object {
    
    @objc dynamic var ruleTitle: String = ""
    @objc dynamic var rulePattern: String = ""
    @objc dynamic var active: Bool = true
    let blockList = List<CXCallDirectoryPhoneNumber>()
    
    static func ==(lhs: Rule, rhs: Rule) -> Bool {
        
        return lhs.ruleTitle == rhs.ruleTitle || lhs.rulePattern == rhs.rulePattern
        
    }
    
}
