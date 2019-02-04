//
//  NumberFormattingLogic.swift
//  Call Control
//
//  Created by Kurtis Hill on 2/2/19.
//  Copyright © 2019 Kurtis Hill. All rights reserved.
//

import Foundation

struct NumberFormattingLogic {
    
    static func formattedNumber(number: String, newCharacter: String) -> String {
        
        var cleanPhoneNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        cleanPhoneNumber += newCharacter
        let mask = "XXX-XXX"
        
        var result = ""
        var index = cleanPhoneNumber.startIndex
        for ch in mask {
            if index == cleanPhoneNumber.endIndex {
                break
            }
            if ch == "X" {
                result.append(cleanPhoneNumber[index])
                index = cleanPhoneNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
    
    static func displayNumberFormat(number: String) -> String {
        
        let format = "***-***-****"
        let index = number.endIndex
        var result = number
        for c in format[index...] {
            result.append(c)
        }
        
        return result
        
    }
    
}
