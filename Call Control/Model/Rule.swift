//
//  Number.swift
//  Call Control
//
//  Created by Kurtis Hill on 1/30/19.
//  Copyright © 2019 Kurtis Hill. All rights reserved.
//

import Foundation

struct Rule {
    var rule: String = ""
    var notes: String?
    var active: Bool = false
    
    init() {
        rule = "This is a really really really really long rule"
        notes = "These are some notes"
        active = false
    }
}
