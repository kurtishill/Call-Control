//
//  SettingsViewController.swift
//  Call Control
//
//  Created by Kurtis Hill on 1/31/19.
//  Copyright © 2019 Kurtis Hill. All rights reserved.
//

import UIKit
import ChameleonFramework

class SettingsViewController: UITableViewController, AppSystemColorSettingsCellDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        setNavBar(withBarColor: "White")
        
    }
    
    func setNavBar(withBarColor barColor: String) {
        
        navigationController?.navigationBar.barStyle = .default

        guard let navBar = navigationController?.navigationBar else { fatalError() }

        guard let navBarColor = UIColor(named: barColor) else { fatalError() }

        let navBarTextColor = ContrastColorOf(navBarColor, returnFlat: true)


        navBar.barTintColor = navBarColor

        navBar.tintColor = navBarTextColor

        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: Settings.instance.primaryColorDark) ?? navBarTextColor]
        
    }
    
    // Note: because this is NOT a subclassed UITableViewController,
    // DataSource and Delegate functions are NOT overridden
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "contactsPermissionCell", for: indexPath)
            
            cell.textLabel!.text = "Contacts permission*"
            
            cell.accessoryType = .disclosureIndicator
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "overrideContactsCell", for: indexPath)
            
            cell.textLabel!.text = "Override contacts"
            
            cell.selectionStyle = .none
            
            let switchView: UISwitch = UISwitch()
            switchView.onTintColor = UIColor(named: Settings.instance.primaryColorDark)
            switchView.setOn(Settings.instance.overrideContacts, animated: false)
            switchView.addTarget(self, action: #selector(overrideContactsToggled), for: .valueChanged)
            
            cell.accessoryView = switchView
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "colorSettingsCell", for: indexPath) as! AppSystemColorSettingsCell
            
            cell.textLabel!.text = "App system color"
            
            cell.selectionStyle = .none
            
            (cell as! AppSystemColorSettingsCell).delegate = self
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "faqCell", for: indexPath)
            
            cell.textLabel!.text = "FAQ"
            
            cell.accessoryType = .disclosureIndicator
        case 4:
            cell = tableView.dequeueReusableCell(withIdentifier: "acknowledgementsCell", for: indexPath)
            
            cell.textLabel!.text = "Acknowledgements"
            
            cell.accessoryType = .disclosureIndicator
        default:
            fatalError()
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "*As far as this app is concerned, your contacts data is completely yours. CallControl never uploads your data to a server or reads it except to simply set the call blocking rules. Everything about your contacts stays on your device."
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    @objc func overrideContactsToggled() {
        
        Settings.instance.toggleOverrideContacts()
        
    }
    
    // MARK: - AppSystemColorSettingsCellDelegate method
    
    func colorChanged() {
        
        tableView.reloadData()
        
        setNavBar(withBarColor: "White")
        
        let fadeTextAnimation = CATransition()
        fadeTextAnimation.duration = 0.2
        fadeTextAnimation.type = CATransitionType.fade
        
        navigationController?.navigationBar.layer.add(fadeTextAnimation, forKey: "fadeText")
        navigationItem.title = "Settings"
        
    }
    
}
