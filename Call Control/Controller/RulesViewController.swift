//
//  TableViewController.swift
//  Call Control
//
//  Created by Kurtis Hill on 1/30/19.
//  Copyright © 2019 Kurtis Hill. All rights reserved.
//

import UIKit
import ChameleonFramework
import RealmSwift
import SVProgressHUD

class RulesViewController: UITableViewController, UITextFieldDelegate, UpdateRuleDelegate, Observer {
    
    var ruleStore: RuleStore!
    
    var numberDirectoryManager: NumberDirectoryManager!
    
    var selectedRule: Rule?
    
    var didSuccessfulUpdate: Bool? {
        didSet {
            if didSuccessfulUpdate! {
                let displayColor = UIColor(named: Settings.instance.primaryColorDark) ?? UIColor.green
                let textColor = ContrastColorOf(displayColor, returnFlat: true)
                SVProgressHUD.setBackgroundColor(displayColor)
                SVProgressHUD.setForegroundColor(textColor)
                SVProgressHUD.setMinimumDismissTimeInterval(TimeInterval(exactly: 1)!)
                SVProgressHUD.showSuccess(withStatus: "Rule Updated")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        UserDefaults.standard.removeObject(forKey: "first-time")
        
        if !UserDefaults.standard.bool(forKey: "first-time") {
            
            performSegue(withIdentifier: "goToSplashScreen", sender: self)
            
        }
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        tableView.rowHeight = 65
        tableView.allowsSelection = false
        tableView.allowsSelectionDuringEditing = true
        
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
            
            guard let title = alert.textFields?[0].text,
                let pattern = alert.textFields?[1].text else { return }
         
            
            // Manually disable UI because ProgressHUD won't display unless the functionality behind it is in the background
            self.view.isUserInteractionEnabled = false
            self.navigationController?.navigationBar.isUserInteractionEnabled = false

            DispatchQueue.global(qos: .background).async {
            
                self.ruleStore.createRule(withTitle: title, withPattern: pattern, withManager: self.numberDirectoryManager, onSaving: {
                    
                    DispatchQueue.main.async {
                        
                        SVProgressHUD.dismiss() {
                            
                            let displayColor = UIColor.darkGray
                            let textColor = ContrastColorOf(displayColor, returnFlat: true)
                            SVProgressHUD.setBackgroundColor(displayColor)
                            SVProgressHUD.setForegroundColor(textColor)
                            SVProgressHUD.show(withStatus: "Block list saving to phone.\nThis may take up to a minute...")
                            
                        }
                        
                    }
                    
                }) {

                    DispatchQueue.main.async {

                        SVProgressHUD.dismiss() {
                            
                            let displayColor = UIColor(named: Settings.instance.primaryColorDark) ?? UIColor.green
                            let textColor = ContrastColorOf(displayColor, returnFlat: true)
                            SVProgressHUD.setBackgroundColor(displayColor)
                            SVProgressHUD.setForegroundColor(textColor)
                            SVProgressHUD.setMinimumDismissTimeInterval(TimeInterval(exactly: 1)!)
                            SVProgressHUD.showSuccess(withStatus: "Rule added")
                            self.tableView.reloadData()
                            self.view.isUserInteractionEnabled = true
                            self.navigationController?.navigationBar.isUserInteractionEnabled = true
                            
                        }

                    }

                }

            }
            
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
        
        return TextFieldController.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
        
    }
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return ruleStore.allRules?.count ?? 0
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "blockedNumberCell", for: indexPath)

        if let rule = ruleStore.allRules?[indexPath.row] {
        
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
            
//            cell.editingAccessoryType = .detailDisclosureButton
            
        }

        return cell
        
    }
    
    // MARK: - Table view delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView.isEditing {
            
//            performSegue(withIdentifier: "goToEditRule", sender: indexPath)
            guard let rule = ruleStore.allRules?[indexPath.row] else { return }
            
            selectedRule = rule
            
            let editingAlertController = UIAlertController(title: "Edit Rule Title", message: nil, preferredStyle: .alert)
            
            editingAlertController.addTextField() {
                $0.autocorrectionType = .yes
                $0.autocapitalizationType = .sentences
                $0.spellCheckingType = .default
                $0.text = rule.ruleTitle
                $0.tag = 0
                $0.addTarget(editingAlertController, action: #selector(editingAlertController.textDidChangeInEditingRuleAlert), for: .editingChanged)
                $0.delegate = self
            }
            
            let saveAction = UIAlertAction(title: "Save", style: .default) {
                action in
                
                if let rule = self.ruleStore.allRules?[indexPath.row],
                    let newTitle = editingAlertController.textFields?[0].text {
                
                    let newRule = Rule()
                    newRule.ruleTitle = newTitle
                    newRule.rulePattern = rule.rulePattern
                    self.ruleStore.update(oldRule: rule, newRule: newRule)
                    self.tableView.reloadData()
                    
                }
                
            }
            
            editingAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            editingAlertController.addAction(saveAction)
            
            present(editingAlertController, animated: true, completion: nil)
            
        }
        
    }
    
    // MARK: - Table view row accessory methods
    
    @objc func switchChanged(_ sender: UISwitch) {
        
        if let rule = ruleStore.allRules?[sender.tag] {
            let realm = try! Realm()
            do {
                try realm.write {
                    rule.active = !rule.active
                }
            } catch {
                print("Error saving active status \(error)")
            }
            
        }
        
    }
    
    @objc func infoButtonTapped(_ sender: UIButton) {
        
        print("hello")
        
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            if let rule = ruleStore.allRules?[indexPath.row] {
            
                let title = "Delete \(rule.ruleTitle)"
                let message = "Are you sure you want to delete this rule?"
                
                let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                ac.addAction(cancelAction)
                
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {
                    action in
                    
                    // remove rule from list of rules
                    self.ruleStore.delete(rule)
                    
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
                if let rule = ruleStore.allRules?[indexPath.row] {
                
                    destination.rule = rule
                    destination.delegate = self
                    
                }
            }
            
        }
        
    }
    
    // MARK: - Update Rule Delegate Method
    func ruleUpdated(oldRule: Rule, newRule: Rule) -> Bool {
        return ruleStore.update(oldRule: oldRule, newRule: newRule)
    }
    
    func reportSuccess(_ success: Bool) {
        didSuccessfulUpdate = success
    }
    
    // MARK: - Observer protocol
    
    var id = Int()
    
    func update() {
        
        DispatchQueue.main.async {
            
            let displayColor = UIColor.darkGray
            let textColor = ContrastColorOf(displayColor, returnFlat: true)
            SVProgressHUD.setBackgroundColor(displayColor)
            SVProgressHUD.setForegroundColor(textColor)
            SVProgressHUD.showProgress(self.numberDirectoryManager.progress, status: "Please wait...\nGenerating block list")
            
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
            
            guard let navController = presentingViewController as? UINavigationController else { return }
            guard let rulesViewController = navController.topViewController as? RulesViewController else { return }
            
            var ruleList = [Rule]()
            ruleList.append(contentsOf: rulesViewController.ruleStore.allRules!)
            
            if (ruleList.contains(where: {$0.ruleTitle == rule || $0.rulePattern == pattern})) {
                
                title = "That Rule Already Exists"
                message = "A rule with this same title or pattern already exists"
                action.isEnabled = false
                
            } else {
                
                title = "Add Rule"
                message = ""
                
            }
        }
        
    }
    
    @objc func textDidChangeInEditingRuleAlert() {
        
        if let rule = textFields?[0].text {
            if let action = actions.last {
                action.isEnabled = isValidRule(rule)
                
                guard let navController = presentingViewController as? UINavigationController else { return }
                guard let rulesViewController = navController.topViewController as? RulesViewController else { return }
                
                var ruleList = [Rule]()
                ruleList.append(contentsOf: rulesViewController.ruleStore.allRules!)
                
                if ruleList.contains(where: {$0.ruleTitle == rule}) && rule != rulesViewController.selectedRule?.ruleTitle {
                    
                    title = "That Rule Name Already Exists"
                    action.isEnabled = false
                    
                } else {
                    
                    title = "Edit Rule Title"
                    message = ""
                    
                }
            }
        }
    }
    
}
