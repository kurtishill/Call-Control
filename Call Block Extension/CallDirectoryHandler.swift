//
//  CallDirectoryHandler.swift
//  Call Block Extension
//
//  Created by Kurtis Hill on 2/6/19.
//  Copyright © 2019 Kurtis Hill. All rights reserved.
//

import Foundation
import CallKit
import RealmSwift
import Realm
import CocoaLumberjack
import Contacts

class CallDirectoryHandler: CXCallDirectoryProvider {
    
    deinit {
        DDLog.remove(DDOSLogger.sharedInstance)
    }
    
    override init() {
        DDLog.add(DDOSLogger.sharedInstance)
    }
    
    lazy var contacts: [CNContact] = {
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactEmailAddressesKey,
            CNContactPhoneNumbersKey,
            CNContactImageDataAvailableKey,
            CNContactThumbnailImageDataKey] as [Any]
        
        // Get all the containers
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results: [CNContact] = []
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }
        
        return results
    }()
    
    func addRulesWithoutOverridingContacts(rules: Results<Rule>, contacts: [Int:String], context: CXCallDirectoryExtensionContext) {
        var numbersBlocked = 0
        for rule in rules {
            for number in rule.blockList.sorted(by: <) {
                let numberString = number.description
                if !contacts.keys.contains(numberString.hashValue) {
                    context.addBlockingEntry(withNextSequentialPhoneNumber: number)
                    numbersBlocked += 1
                }
            }
            
            DDLogInfo("Blocked \(numbersBlocked) numbers")
        }
    }
    
    func addRulesWithOverridingContacts(rules: Results<Rule>, context: CXCallDirectoryExtensionContext) {
        for rule in rules {
            for number in rule.blockList.sorted(by: <) {
                context.addBlockingEntry(withNextSequentialPhoneNumber: number)
            }
            
            DDLogInfo("Blocked \(rule.blockList.count) numbers")
        }
    }

    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self
        
        let directory: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.kurt.Call-Control")!
        let realmPath = directory.appendingPathComponent("default.realm")
        let realmConfig = Realm.Configuration(fileURL: realmPath)
        
        guard let realm = try? Realm(configuration: realmConfig) else {
            DDLogWarn("CallDirectoryHandler: Failure initializing Realm")
            context.completeRequest()
            return
        }

        // Check whether this is an "incremental" data request. If so, only provide the set of phone number blocking
        // and identification entries which have been added or removed since the last time this extension's data was loaded.
        // But the extension must still be prepared to provide the full set of data at any time, so add all blocking
        // and identification phone numbers if the request is not incremental.
        if #available(iOSApplicationExtension 11.0, *) {
            if context.isIncremental {
                context.removeAllBlockingEntries()
            }
        }

        DDLogInfo("WE ARE HERE")
        
        let rules = realm.objects(Rule.self).filter("active == true")
        
        let settings = realm.objects(Settings.self).first
        
        var contactsNumbers = [Int:String]()
        
        let overrideContacts = settings!.overrideContacts
        
        if rules.count > 0 && !overrideContacts {
            for contact in contacts {
                for phoneNumber in contact.phoneNumbers {
                    let numberObject = phoneNumber.value
                    var number = numberObject.stringValue.filter("01234567890".contains)
                    if number[number.startIndex] != "1" && number.count == 10 {
                        number = "1" + number
                    }
                    contactsNumbers[number.hashValue] = number
                    print(number)
                }
            }
        }
        
        if rules.count > 0 {
            if overrideContacts {
                addRulesWithOverridingContacts(rules: rules, context: context)
            } else {
                addRulesWithoutOverridingContacts(rules: rules, contacts: contactsNumbers, context: context)
            }
        }

        context.completeRequest()
    }

}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {

    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
        // An error occurred while adding blocking or identification entries, check the NSError for details.
        // For Call Directory error codes, see the CXErrorCodeCallDirectoryManagerError enum in <CallKit/CXError.h>.
        //
        // This may be used to store the error details in a location accessible by the extension's containing app, so that the
        // app may be notified about errors which occured while loading data even if the request to load data was initiated by
        // the user in Settings instead of via the app itself.
    }

}
