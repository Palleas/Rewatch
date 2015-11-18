//
//  SettingsViewController.swift
//  Rewatch
//
//  Created by somebody who wasn't Romain Pouclet on 2015-11-05 because it's super ugly.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
// 

import UIKit
import KeychainSwift

class DebugCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Value1, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SettingsViewController: UITableViewController {
    typealias Completion = () -> Void
    
    let MemberCellIdentifier = "MemberCell"
    let MemberActionCellIdentifier = "MemberActionCell"
    let DebugCellIdentifier = "DebugCell"
    let VersionCellIdentifier = "VersionCell"
    let completion: Completion
    
    let client: Client
    let persistenceController: PersistenceController
    
    init(client: Client, persistenceController: PersistenceController, completion: Completion) {
        self.client = client
        self.persistenceController = persistenceController
        self.completion = completion
        
        super.init(style: .Grouped)
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: MemberCellIdentifier)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: MemberActionCellIdentifier)
        tableView.registerClass(DebugCell.self, forCellReuseIdentifier: DebugCellIdentifier)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: VersionCellIdentifier)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: Selector("didTapDismissSettingsPanel"))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Member
        if section == 0 {
            return 3
        }

        // Debug
        if section == 1 {
            return 3
        }
        
        // Current version
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        // Member
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier(MemberCellIdentifier, forIndexPath: indexPath)
                cell.textLabel?.text = "Current user (SOON)"
            } else if indexPath.row == 1 {
                cell = tableView.dequeueReusableCellWithIdentifier(MemberActionCellIdentifier, forIndexPath: indexPath)
                cell.textLabel?.text = "Sync now"
                cell.textLabel?.textColor = .blueColor()
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier(MemberActionCellIdentifier, forIndexPath: indexPath)
                cell.textLabel?.text = "Log Out"
                cell.textLabel?.textColor = .redColor()
            }
        // Debug
        } else if indexPath.section == 1 {
            cell = tableView.dequeueReusableCellWithIdentifier(DebugCellIdentifier, forIndexPath: indexPath)
            if indexPath.row == 0 {
                cell.textLabel?.text = "Number of shows"
                cell.detailTextLabel?.text = String(persistenceController.numberOfShows())
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "Number of episodes"
                cell.detailTextLabel?.text = String(persistenceController.numberOfEpisodes())
            } else {
                cell.textLabel?.text = "Last sync"
                cell.detailTextLabel?.text = lastSyncDate()
            }
        // Current Version
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier(VersionCellIdentifier, forIndexPath: indexPath)
            let buildVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]!
            let buildNumber = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"]!
            cell.textLabel?.text = "Version \(buildVersion) (\(buildNumber))"
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Member"
        }
        
        if section == 1 {
            return "Debug"
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return indexPath == NSIndexPath(forRow: 1, inSection: 0) || indexPath == NSIndexPath(forRow: 2, inSection: 0) ? indexPath : nil
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 1 {
            let downloadViewController = DownloadViewController(client: client, downloadController: DownloadController(client: client, persistenceController: persistenceController))
            let navigation = UINavigationController(rootViewController: downloadViewController)
            presentViewController(navigation, animated: true, completion: nil)
        } else {
            let keychain = KeychainSwift()
            keychain.clear()
            
            client.token = nil
            presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func didTapDismissSettingsPanel() {
        completion()
    }
}
