//
//  RuleStore.swift
//  Call Control
//
//  Created by Kurtis Hill on 2/4/19.
//  Copyright © 2019 Kurtis Hill. All rights reserved.
//

import Foundation

class RuleStore {
    var allRules = [Rule]()
    
    @discardableResult func createRule(withTitle title: String, withPattern pattern: String) -> Rule {
        let newRule = Rule(withTitle: title, withPattern: pattern)
        
        allRules.append(newRule)
        
        return newRule
    }
    
    func removeRule(at index: Int) {
        allRules.remove(at: index)
    }
}
