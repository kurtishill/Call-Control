//
//  EditRuleViewController.swift
//  Call Control
//
//  Created by Kurtis Hill on 1/31/19.
//  Copyright © 2019 Kurtis Hill. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol UpdateRuleDelegate {
    func ruleUpdated(oldRule: Rule, newRule: Rule) -> Bool
    func reportSuccess(_ success: Bool)
}

class EditRuleViewController: UIViewController, UITextFieldDelegate {
    
    var delegate: UpdateRuleDelegate?
    var resultOfUpdate: Bool?
    
    @IBOutlet weak var ruleTitleTextField: UITextField!
    @IBOutlet weak var rulePatternTextField: UITextField!
    @IBOutlet weak var patternDescriptionLabel: UILabel!
    @IBOutlet weak var saveButton: RoundedButton!
    
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        let updatedRule = Rule()
        updatedRule.ruleTitle = ruleTitleTextField.text!
        updatedRule.rulePattern = rulePatternTextField.text!
        resultOfUpdate = delegate?.ruleUpdated(oldRule: rule!, newRule: updatedRule)
        
        if resultOfUpdate! {
            self.navigationController?.popViewController(animated: true)
        } else {
            SVProgressHUD.setBackgroundColor(UIColor.red)
            SVProgressHUD.setForegroundColor(UIColor.white)
            SVProgressHUD.setMinimumDismissTimeInterval(TimeInterval(exactly: 1)!)
            SVProgressHUD.showError(withStatus: "Rule Not Updated")
        }
        
    }
    
    
    var rule: Rule? {
        didSet {
            title = "\(rule!.ruleTitle)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ruleTitleTextField.delegate = self
        rulePatternTextField.delegate = self
        
        ruleTitleTextField.addTarget(self, action: #selector(textDidChangeInEditingRule), for: .editingChanged)
        rulePatternTextField.addTarget(self, action: #selector(textDidChangeInEditingRule), for: .editingChanged)
        
        if let r = rule {
            ruleTitleTextField.text = r.ruleTitle
            
            rulePatternTextField.text = r.rulePattern
            patternDescriptionLabel.text = "All calls starting in \(r.rulePattern) will be blocked."
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let result = resultOfUpdate else { return }
        delegate?.reportSuccess(result)
    }
    
    // MARK: - Text Field Delegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        return TextFieldController.textField(textField, shouldChangeCharactersIn: range, replacementString: string)

    }
    
    private func isValidRule(_ rule: String) -> Bool {
        
        return rule.count > 0
        
    }
    
    private func isValidNumber(_ number: String) -> Bool {
        
        return number.count >= 3 && number.count <= 7
        
    }
    
    @objc private func textDidChangeInEditingRule() {
        
        if let rule = ruleTitleTextField.text,
            let pattern = rulePatternTextField.text {
            saveButton.isEnabled = isValidRule(rule) && isValidNumber(pattern)
            if saveButton.isEnabled {
                saveButton.alpha = 1.0
            } else {
                saveButton.alpha = 0.5
            }
        }
        
    }

}
