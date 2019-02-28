//
//  NumberDirectoryManager.swift
//  Call Control
//
//  Created by Kurtis Hill on 2/6/19.
//  Copyright © 2019 Kurtis Hill. All rights reserved.
//

import Foundation
import CallKit

class NumberDirectoryManager {
    
    private var observerArray = [Observer]()
    
    private var _progress = Float(0.0)
    
    private var topNumber: Int = 0
    
    private var intervalToSendUpdate: Int = 1
    
    var progress: Float {
        set {
            _progress = newValue
            notify()
        }
        get {
            return _progress
        }
    }
    
    func attachObserver(observer: Observer) {
        observerArray.append(observer)
    }
    
    private func notify() {
        for observer in observerArray {
            observer.update()
        }
    }
    
    func generateNumbers(forRule rule: Rule) {
        
        // Eliminate the hyphen separator
        var cleanPattern = ""
        
        for ch in rule.rulePattern {
            if ch != "-" {
                cleanPattern += String(ch)
            }
        }
        
        let mask = "**********"
        let numUnknowns = mask.count - cleanPattern.count
        var topNumberString = ""
        
        for _ in 1...numUnknowns {
            topNumberString += "9"
        }
        
        topNumber = Int(topNumberString)!
        intervalToSendUpdate = 1
        
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = numUnknowns
        
        let callingCode = "1"

        let progressFormatter = NumberFormatter()
        progressFormatter.minimumFractionDigits = 1
        progressFormatter.maximumFractionDigits = 2
        progressFormatter.numberStyle = .percent
        
        var list = [CXCallDirectoryPhoneNumber]()
        
        for num in 0...topNumber {
            let toAdd = formatter.string(from: NSNumber(integerLiteral: num))

            guard let n = toAdd else { continue }

            let finalNumber = callingCode + cleanPattern + n

            list.append(CXCallDirectoryPhoneNumber(finalNumber)!)

            if num == intervalToSendUpdate - 1 {
                progress = Float(num + 1) / Float(topNumber)
                intervalToSendUpdate += (topNumber) / 32
            }

        }
        
        rule.blockList.append(objectsIn: list)
        
    }
    
    static func refreshExtensionState() {
        CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: "com.kurt.Call-Control.Call-Block-Extension") { (reloadError) in
            if let error = reloadError as? CXErrorCodeCallDirectoryManagerError {
                print("Error reloading CXCallDirectoryManager extension: \(error.localizedDescription) \"\(error.code)\"")
            } else {
                print("Reloaded CXCallDirectoryManager extension.")
            }
            CXCallDirectoryManager.sharedInstance.getEnabledStatusForExtension(withIdentifier: "com.kurt.Call-Control.Call-Block-Extension") { (status, statusError) in
                if let error = statusError {
                    print("Error getting status for CXCallDirectoryManager extension: \(error.localizedDescription)")
                } else {
                    print("Got status for CXCallDirectoryManager extension: \(status)")
                }
                DispatchQueue.main.async {
                    // show warning if enabled with error
                    if status != .disabled,
                        reloadError != nil || statusError != nil {
                        print("error")
                    } else {
                        print("enabled")
                    }
                }
            }
        }
    }
    
}

extension CXErrorCodeCallDirectoryManagerError.Code: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown:
            return "An unknown error occurred."
        case .noExtensionFound:
            return "The call directory manager could not find a corresponding app extension."
        case .loadingInterrupted:
            return "The call directory manager was interrupted while loading the app extension."
        case .entriesOutOfOrder:
            return "The entries in the call directory are out of order."
        case .duplicateEntries:
            return "There are duplicate entries in the call directory."
        case .maximumEntriesExceeded:
            return "There are too many entries in the call directory."
        case .extensionDisabled:
            return "The call directory extension isn’t enabled by the system."
        case .currentlyLoading:
            return "currentlyLoading"
        case .unexpectedIncrementalRemoval:
            return "expectedIncrementalRemoval"
        }
    }
}
