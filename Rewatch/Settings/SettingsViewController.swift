//
//  SettingsViewController.swift
//  Rewatch
//
//  Created by somebody who wasn't Romain Pouclet on 2015-11-05 because it's super ugly.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
// 

import UIKit
import KeychainSwift
import ReactiveCocoa
import MessageUI

class MemberCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

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
    let SupportCellIdentifier = "SupportCell"
    let completion: Completion
    
    let client: Client
    let persistenceController: PersistenceController
    let analyticsController: AnalyticsController
    
    init(client: Client, persistenceController: PersistenceController, analyticsController: AnalyticsController, completion: Completion) {
        self.client = client
        self.persistenceController = persistenceController
        self.completion = completion
        self.analyticsController = analyticsController
        
        super.init(style: .Grouped)
        
        tableView.registerClass(MemberCell.self, forCellReuseIdentifier: MemberCellIdentifier)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: MemberActionCellIdentifier)
        tableView.registerClass(DebugCell.self, forCellReuseIdentifier: DebugCellIdentifier)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: VersionCellIdentifier)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: SupportCellIdentifier)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: Selector("didTapDismissSettingsPanel"))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Member
        if section == 0 {
            return 3
        }

        if section == 1 {
            return 2
        }
        
        // Debug
        if section == 2 {
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
                cell.textLabel?.text = NSLocalizedString("LOADING_MESSAGE", comment: "Loading Message")
                cell.textLabel?.textColor = UIColor.lightGrayColor()
                
                client
                    .fetchMemberInfos()
                    .flatMap(.Latest, transform: { (member) -> SignalProducer<(UIImage?, String), NSError> in
                        guard let url = member.avatar else { return SignalProducer(value: (nil, member.login)) }

                        return NSURLSession
                            .sharedSession()
                            .rac_dataWithRequest(NSURLRequest(URL: url))
                            .map({ return UIImage(data: $0.0) })
                            .zipWith(SignalProducer(value: member.login))
                    })
                    .observeOn(UIScheduler())
                    .on(error: { error in
                        self.tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text = NSLocalizedString("UNAVAILABLE", comment: "Member infos available message")
                    })
                    .startWithNext({ (avatar, login) -> () in
                        guard let cell = self.tableView.cellForRowAtIndexPath(indexPath) else { return }
                        cell.imageView?.image = avatar
                        cell.textLabel?.text = login
                        cell.textLabel?.textColor = .darkTextColor()
                    })
                
                
            } else if indexPath.row == 1 {
                cell = tableView.dequeueReusableCellWithIdentifier(MemberActionCellIdentifier, forIndexPath: indexPath)
                cell.textLabel?.text = NSLocalizedString("SYNC_NOW", comment: "Sync now button label")
                cell.textLabel?.textColor = .blueColor()
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier(MemberActionCellIdentifier, forIndexPath: indexPath)
                cell.textLabel?.text = NSLocalizedString("LOG_OUT", comment: "Log out button label")
                cell.textLabel?.textColor = .redColor()
            }
        // Support
        } else if indexPath.section == 1 {
            cell = tableView.dequeueReusableCellWithIdentifier(SupportCellIdentifier, forIndexPath: indexPath)
            if indexPath.row == 0 {
                cell.imageView?.image = UIImage(named: "twitter")?.imageWithRenderingMode(.AlwaysTemplate)
                cell.imageView?.tintColor = .blackColor()
                cell.textLabel?.text = "@rewatch_app"
            } else if indexPath.row == 1 {
                cell.imageView?.image = UIImage(named: "mail")
                cell.textLabel?.text = "romain@rewatchapp.com"
            }
        // Debug
        } else if indexPath.section == 2 {
            cell = tableView.dequeueReusableCellWithIdentifier(DebugCellIdentifier, forIndexPath: indexPath)
            if indexPath.row == 0 {
                cell.textLabel?.text = NSLocalizedString("SHOWS_COUNT", comment: "Shows count")
                cell.detailTextLabel?.text = String(persistenceController.numberOfShows())
            } else if indexPath.row == 1 {
                cell.textLabel?.text = NSLocalizedString("EPISODES_COUNT", comment: "Episodes count")
                cell.detailTextLabel?.text = String(persistenceController.numberOfEpisodes())
            } else {
                cell.textLabel?.text = NSLocalizedString("LAST_SYNC", comment: "Last sync")
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
            return NSLocalizedString("MEMBER_CENTER_SECTION", comment: "Member section")
        }
        
        if section == 1 {
            return NSLocalizedString("SUPPORT_SECTION", comment: "Support Section")
        }
        
        if section == 2 {
            return NSLocalizedString("DEBUG_CENTER_SECTION", comment: "Member section")
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return indexPath == NSIndexPath(forRow: 1, inSection: 0)
            || indexPath == NSIndexPath(forRow: 2, inSection: 0)
            || indexPath.section == 1 ? indexPath : nil
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 1):
            analyticsController.trackEvent(.ManualSync)
            
            let downloadViewController = DownloadViewController(client: client, downloadController: DownloadController(client: client, persistenceController: persistenceController))
            let navigation = UINavigationController(rootViewController: downloadViewController)
            presentViewController(navigation, animated: true, completion: nil)
        case (0, 2):
            let keychain = KeychainSwift()
            keychain.clear()
            
            client.token = nil
            presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        case (1, 0):
            UIApplication.sharedApplication().openURL(NSURL(string: "https://twitter.com/rewatch_app")!)
            break
        case (1, 1):
            if MFMailComposeViewController.canSendMail() {
                let composer = MFMailComposeViewController()
                composer.mailComposeDelegate = self
                composer.setToRecipients(["romain@rewatchapp.com"])
                presentViewController(composer, animated: true, completion: nil)
            }
            break
        default: break
        }

    }
    
    func didTapDismissSettingsPanel() {
        completion()
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}