//
//  TableViewController.swift
//  Call Control
//
//  Created by Kurtis Hill on 1/30/19.
//  Copyright © 2019 Kurtis Hill. All rights reserved.
//

import UIKit
import ChameleonFramework

class RulesViewController: UITableViewController, UITextFieldDelegate {
    
    var rules: [Rule]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        tableView.rowHeight = 65
        tableView.allowsSelection = false
        tableView.allowsSelectionDuringEditing = true
        
        rules = [Rule]()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let primaryColor = UIColor(named: Settings.instance.primaryColor) {
            
            navigationItem.leftBarButtonItem?.tintColor = ContrastColorOf(primaryColor, returnFlat: true)
            
            navigationController?.navigationBar.barStyle = .default
            
            guard let navBar = navigationController?.navigationBar else { fatalError() }
            
            guard let navBarColor = UIColor(named: Settings.instance.primaryColor) else { fatalError() }
            
            let navBarContrastColor = ContrastColorOf(navBarColor, returnFlat: true)
            
            
            navBar.barTintColor = navBarColor
            
            navBar.tintColor = navBarContrastColor
            
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: navBarContrastColor]
            
        }
        
        tableView.reloadData()
    }
    
    // MARK: - IBActions
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add Rule", message: "", preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Add Rule", style: .default) {
            action in
            
            guard let rule = alert.textFields?[0].text,
                let pattern = alert.textFields?[1].text else { return }
            
            let newRule = Rule(withTitle: rule, withPattern: pattern)
            
            self.rules?.append(newRule)
            
            self.tableView.reloadData()
            
        }
        
        alert.addTextField() {
            $0.autocorrectionType = .yes
            $0.autocapitalizationType = .sentences
            $0.spellCheckingType = .default
            $0.placeholder = "Rule name"
            $0.tag = 0
            $0.addTarget(alert, action: #selector(alert.textDidChangeInAddingRuleAlert), for: .editingChanged)
            $0.delegate = self
        }
        
        alert.addTextField() {
            $0.placeholder = "Pattern to block: 3-6 digits"
            $0.tag = 1
            $0.keyboardType = .phonePad
            $0.addTarget(alert, action: #selector(alert.textDidChangeInAddingRuleAlert), for: .editingChanged)
            $0.delegate = self
        }
        
        
        
        addAction.isEnabled = false
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - UITextFieldDelegate methods
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
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
                    if string != "" {
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
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return rules?.count ?? 1
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "blockedNumberCell", for: indexPath)

        // if a rule exists at that index
        if let rule = rules?[indexPath.row] {
            
            cell.textLabel!.text = rule.ruleTitle
            cell.textLabel!.adjustsFontForContentSizeCategory = true
            cell.textLabel!.adjustsFontSizeToFitWidth = true
            
            cell.detailTextLabel!.text = NumberFormattingLogic.displayNumberFormat(number: rule.rulePattern)
            cell.detailTextLabel!.adjustsFontForContentSizeCategory = true
            cell.detailTextLabel!.adjustsFontSizeToFitWidth = true
            cell.detailTextLabel!.textColor = UIColor.lightGray
            
            let switchView = UISwitch(frame: CGRect.zero)
            switchView.setOn(rule.active, animated: false)
            switchView.tag = indexPath.row
            switchView.onTintColor = UIColor(named: Settings.instance.primaryColorDark)
            switchView.addTarget(self,
                                 action: #selector(self.switchChanged),
                                 for: .valueChanged)
            cell.accessoryView = switchView
            
            cell.editingAccessoryType = .detailDisclosureButton
            
        }

        return cell
        
    }
    
    // MARK: - Table view delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView.isEditing {
            performSegue(withIdentifier: "goToEditRule", sender: indexPath)
        }
        
    }
    
    // MARK: - Table view row accessory methods
    
    @objc func switchChanged(_ sender: UISwitch) {
        
        if let rule = rules?[sender.tag] {
            
            rules?[sender.tag].active = !rule.active
            
        }

    }
    
    @objc func infoButtonTapped(_ sender: UIButton) {
        
        print("hello")
        
    }

    
//     Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            if let rule = rules?[indexPath.row] {
                let title = "Delete \(rule.ruleTitle)"
                let message = "Are you sure you want to delete this rule?"
                
                let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                ac.addAction(cancelAction)
                
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {
                    action in
                    
                    // remove rule from list of rules
                    self.rules?.remove(at: indexPath.row)
                    
                    // remove rule from table view
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
                
                ac.addAction(deleteAction)
                
                present(ac, animated: true, completion: nil)
            }
        }
    }
    
    
     // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? EditRuleViewController {
        
            if let indexPath = sender as? IndexPath {
                let rule = rules?[indexPath.row]
                
                destination.rule = rule
            }
            
        }
        
    }

}

extension UIAlertController {
    
    func isValidRule(_ rule: String) -> Bool {
        
        return rule.count > 0
        
    }
    
    func isValidNumber(_ number: String) -> Bool {
        
        return number.count >= 3 && number.count <= 7
        
    }
    
    @objc func textDidChangeInAddingRuleAlert() {
        
        if let rule = textFields?[0].text,
            let pattern = textFields?[1].text,
            let action = actions.last {
            action.isEnabled = isValidRule(rule) && isValidNumber(pattern)
        }
        
    }
    
}
