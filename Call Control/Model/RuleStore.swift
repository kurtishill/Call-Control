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
    
    func removeRule(at index: Int) {
        delete(at: index)
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
