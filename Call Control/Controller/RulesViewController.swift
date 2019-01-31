//
//  TableViewController.swift
//  Call Control
//
//  Created by Kurtis Hill on 1/30/19.
//  Copyright © 2019 Kurtis Hill. All rights reserved.
//

import UIKit

class RulesViewController: UITableViewController {
    
    var rules: [Rule]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
//         self.clearsSelectionOnViewWillAppear = false

//         Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        tableView.rowHeight = 75

        rules = [Rule]()
        rules?.append(Rule())
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return rules?.count ?? 1
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "blockedNumberCell", for: indexPath) as! RuleCell

        // if a rule exists at that index
        if let rule = rules?[indexPath.row] {
            
            cell.ruleLabel?.text = rule.rule
            cell.notesLabel?.text = rule.notes
            
            // configure UISwitch with proper settings
            if let switchView = cell.activeSwitch {
                switchView.setOn(rule.active, animated: true)
                switchView.tag = indexPath.row // to detect which row switch Changed
                switchView.addTarget(self,
                                     action: #selector(self.switchChanged),
                                     for: .valueChanged)
                cell.activeSwitch = switchView
            }

            // configure UIButton with proper settings
            if cell.infoButton != nil {
                cell.infoButton.tag = indexPath.row
                cell.infoButton.addTarget(self,
                                          action: #selector(self.infoButtonTapped),
                                          for: .touchUpInside)
            }
            
        }

        return cell
        
    }
    
    // MARK: - Table view delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
