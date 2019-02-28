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
    var realmConfig: Realm.Configuration?
    
    
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
        
        guard let realm = try? Realm(configuration: realmConfig!) else { return }
        
        do {
            try realm.write {
                realm.add(rule)
            }
            NumberDirectoryManager.refreshExtensionState()
        } catch {
            print("Error saving context: \(error)")
        }

    }
    
    @discardableResult func update(oldRule: Rule, newRule: Rule) -> Bool {
        if let ruleIndex = allRules?.index(of: oldRule) {
        
            guard let realm = try? Realm(configuration: realmConfig!) else { return false }
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
        
        guard let realm = try? Realm(configuration: realmConfig!) else { return }
        
        allRules = realm.objects(Rule.self).sorted(byKeyPath: "ruleTitle", ascending: true)
        
    }
    
    func delete(_ rule: Rule) {
        
        if let index = allRules?.index(of: rule)  {
            
            guard let realm = try? Realm(configuration: realmConfig!) else { return }
            
            do {
                try realm.write {
                    realm.delete((allRules?[index])!)
                }
                NumberDirectoryManager.refreshExtensionState()
            } catch {
                print("Error deleting rule: \(error)")
            }
            
        }
        
    }
    
}
