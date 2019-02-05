//
//  Number.swift
//  Call Control
//
//  Created by Kurtis Hill on 1/30/19.
//  Copyright © 2019 Kurtis Hill. All rights reserved.
//

import Foundation
import RealmSwift

class Rule: Object {
    
    @objc dynamic var ruleTitle: String = ""
    @objc dynamic var rulePattern: String = ""
    @objc dynamic var active: Bool = true
    
}
