//
//  Number.swift
//  Call Control
//
//  Created by Kurtis Hill on 1/30/19.
//  Copyright © 2019 Kurtis Hill. All rights reserved.
//

import Foundation

struct Rule {
    var ruleTitle: String = ""
    var rulePattern: String = ""
    var notes: String?
    var active: Bool = true
    
    init(withTitle title: String, withPattern pattern: String) {
        self.ruleTitle = title
        self.rulePattern = pattern
    }
}
