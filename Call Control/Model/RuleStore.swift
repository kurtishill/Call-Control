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
    
    @discardableResult func createRule(withTitle title: String, withPattern pattern: String, withManager manager: NumberDirectoryManager, onSaving: () -> Void, onCompletion: () -> Void) -> Rule {
        let newRule = Rule()
        newRule.ruleTitle = title
        newRule.rulePattern = pattern
        
        manager.generateNumbers(forRule: newRule)
        
        // special case
        // additional loading HUD for saving to phone not necessary in this case
        // race condition can occur between onSaving and onCompletion
        if pattern.count < 7 {
            onSaving()
        }
        
        save(rule: newRule)
        
        onCompletion()
        
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
    
    @discardableResult func update(oldRule: Rule, newRule: Rule) -> Bool {
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
        
        allRules = realm.objects(Rule.self).sorted(byKeyPath: "ruleTitle", ascending: true)
        
    }
    
    func delete(_ rule: Rule) {
        
        if let index = allRules?.index(of: rule)  {
            
            let realm = try! Realm()
            
            do {
                try realm.write {
                    realm.delete((allRules?[index])!)
                }
            } catch {
                print("Error deleting rule: \(error)")
            }
            
        }
        
    }
}
