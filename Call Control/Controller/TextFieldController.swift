//
//  TextFieldController.swift
//  Call Control
//
//  Created by Kurtis Hill on 2/5/19.
//  Copyright © 2019 Kurtis Hill. All rights reserved.
//

import UIKit

class TextFieldController {
    
    static func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 0 {
            if string == "" {
                return true
            }
            return textField.text!.count < 15
        } else {
            if !CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)) {
                return false
            } else {
                if textField.text!.count < 7 {
                    textField.text = NumberFormattingLogic.formattedNumber(number: textField.text!, newCharacter: string)
                    if string != "" || range.location == 4 {
                        textField.text?.remove(at: textField.text!.index(before: (textField.text?.endIndex)!))
                    }
                    return true
                } else if string == "" {
                    return true
                }
                return false
            }
        }
    }
    
}
