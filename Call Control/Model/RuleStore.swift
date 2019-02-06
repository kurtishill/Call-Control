//
//  RuleStore.swift
//  Call Control
//
//  Created by Kurtis Hill on 2/4/19.
//  Copyright © 2019 Kurtis Hill. All rights reserved.
//

import Foundation
import RealmSwift

class RuleStore: Object {
    var allRules: Results<Rule>?
    
    @discardableResult func createRule(withTitle title: String, withPattern pattern: String) -> Rule {
        let newRule = Rule()
        newRule.ruleTitle = title
        newRule.rulePattern = pattern
        
        save(rule: newRule)
        
        return newRule
    }
    
    func save(rule: Rule) {
        
        let realm = try! Realm()
        
        do {
            try realm.write {
                realm.add(rule)
            }
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    func update(oldRule: Rule, newRule: Rule) -> Bool {
        if let ruleIndex = allRules?.index(of: oldRule) {
        
            let realm = try! Realm()
            guard let rule = allRules?[ruleIndex] else { return false }
            
            do {
                try realm.write {
                    rule.ruleTitle = newRule.ruleTitle
                    rule.rulePattern = newRule.rulePattern
                    rule.active = newRule.active
                }
            } catch {
                print("Error updating rule \(error)")
                return false
            }
            return true
        }
        return false
    }
    
    func load() {
        
        let realm = try! Realm()
        
        allRules = realm.objects(Rule.self)
        
    }
    
    func delete(at index: Int) {
        
        if let ruleForDeletion = allRules?[index]  {
            
            let realm = try! Realm()
            
            do {
                try realm.write {
                    realm.delete(ruleForDeletion)
                }
            } catch {
                print("Error deleting rule: \(error)")
            }
            
        }
        
    }
}
