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
import CoreData

class SettingsViewController: UITableViewController {
    enum CompletionResult {
        case Cancelled
        case Success
        case Logout
    }

    enum SupportAccount: String {
        case TwitterAccount = "rewatch_app"
        case Email = "romain@rewatchapp.com"

        static var supportAccounts: [SupportAccount] {
            return [.TwitterAccount, .Email]
        }

        var icon: UIImage {
            switch self {
            case .TwitterAccount: return UIImage(named: "twitter")!.imageWithRenderingMode(.AlwaysTemplate)
            case .Email: return UIImage(named: "mail")!.imageWithRenderingMode(.AlwaysTemplate)
            }
        }
    }

    typealias Completion = (result: CompletionResult) -> Void

    enum SettingsSection: Int {
        case Member = 0
        case TVShows = 1
        case Support = 2
        case Version = 3

        static var allValues: [SettingsSection] {
            return [.Member, .TVShows, .Support, .Version]
        }
    }

    let MemberCellIdentifier = "MemberCell"
    let TVShowCellIdentifier = "TVShowCell"
    let VersionCellIdentifier = "VersionCell"
    let SupportCellIdentifier = "SupportCell"
    let completion: Completion

    let persistenceController: PersistenceController
    let analyticsController: AnalyticsController
    let authenticationController: AuthenticationController
    let context: NSManagedObjectContext

    private lazy var shows: [StoredShow] = self.persistenceController.allShows()

    init(persistenceController: PersistenceController, analyticsController: AnalyticsController, authenticationController: AuthenticationController, completion: Completion) {
        self.persistenceController = persistenceController
        self.context = persistenceController.spawnManagedObjectContext()

        self.analyticsController = analyticsController
        self.authenticationController = authenticationController
        self.completion = completion


        super.init(style: .Grouped)
        
        tableView.registerClass(MemberTableViewCell.self, forCellReuseIdentifier: MemberCellIdentifier)
        tableView.registerClass(ShowTableViewCell.self, forCellReuseIdentifier: TVShowCellIdentifier)
        tableView.registerClass(VersionTableViewCell.self, forCellReuseIdentifier: VersionCellIdentifier)
        tableView.registerClass(SupportTableViewCell.self, forCellReuseIdentifier: SupportCellIdentifier)

        tableView.separatorStyle = .None
        
        title = NSLocalizedString("SETTINGS_SECTION", comment: "Settings section title")
        tableView.backgroundColor = Stylesheet.appBackgroundColor

        clearsSelectionOnViewWillAppear = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(SettingsViewController.didTapCancelButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(SettingsViewController.didTapDoneButton))
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return SettingsSection.allValues.count
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == SettingsSection.Member.rawValue {
            return 0
        }

        return 30
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionSetting = SettingsSection(rawValue: section) else { return 0 }

        switch sectionSetting {
        case .Member: return 1
        case .TVShows: return shows.count
        case .Support: return SupportAccount.supportAccounts.count
        case .Version: return 1
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let sectionSetting = SettingsSection(rawValue: indexPath.section)!

        switch (sectionSetting, indexPath.row) {
        case (.Member, _):
            let cell =  tableView.dequeueReusableCellWithIdentifier(MemberCellIdentifier, forIndexPath: indexPath) as! MemberTableViewCell
            if let member = self.authenticationController.member {
                cell.configureWithMemberInfos(member)
            }
            return cell
        case (.TVShows, let index):
            let cell = tableView.dequeueReusableCellWithIdentifier(TVShowCellIdentifier, forIndexPath: indexPath) as! ShowTableViewCell
            cell.configureWithTitle(shows[index].title ?? "", includeInRandom: shows[index].includeInRandom)
            cell.delegate = self

            return cell
        case (.Support, let index):
            let cell = tableView.dequeueReusableCellWithIdentifier(SupportCellIdentifier, forIndexPath: indexPath) as! SupportTableViewCell
            cell.icon = SupportAccount.supportAccounts[index].icon
            cell.textLabel?.text = SupportAccount.supportAccounts[index].rawValue

            return cell
        case (.Version, _):
            let cell = tableView.dequeueReusableCellWithIdentifier(VersionCellIdentifier, forIndexPath: indexPath)

            guard let info = NSBundle.mainBundle().infoDictionary else { return cell }
            guard let version = info["CFBundleShortVersionString"], let buildNumber = info["CFBundleVersion"] else { return cell }

            cell.textLabel?.text = "Version \(version) (\(buildNumber))"
            return cell
        }
    }

    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        guard let section = SettingsSection(rawValue: indexPath.section) else { return indexPath }

        switch section {
        case .TVShows, .Support: return indexPath

        default:
            return nil
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let section = SettingsSection(rawValue: indexPath.section) else { return }

        switch (section, indexPath.row) {
        case (.TVShows, _):
            (tableView.cellForRowAtIndexPath(indexPath) as? ShowTableViewCell)?.toggle()
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        case (.Support, let index):
            handleSupportSelection(SupportAccount.supportAccounts[index])
        default: break
        }

    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = .clearColor()
    }

    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.section == SettingsSection.Member.rawValue ? 70 : 44
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.section == SettingsSection.Member.rawValue ? UITableViewAutomaticDimension : 44
    }

    func handleSupportSelection(support: SupportAccount) {
        switch support {
        case .TwitterAccount:
            guard let url = NSURL(string: "https://twitter.com/\(support.rawValue)") else { break }
            analyticsController.trackEvent(.SupportTwitter)

            UIApplication.sharedApplication().openURL(url)
        case .Email:
            guard MFMailComposeViewController.canSendMail() else { break }

            analyticsController.trackEvent(.SupportMail)

            let composer = MFMailComposeViewController()
            composer.mailComposeDelegate = self
            composer.setToRecipients([support.rawValue])
            presentViewController(composer, animated: true, completion: nil)
        }
    }

    func didTapCancelButton() {
        completion(result: .Cancelled)
    }

    func didTapDoneButton() {
        do {
            try context.save()
            completion(result: .Success)
        } catch {
            print("Unable to save settings: \(error)")
        }
    }
}

extension SettingsViewController: ShowTableViewCellDelegate {
    func didToggleCell(cell: ShowTableViewCell, on: Bool) {
        guard let showIndex = tableView.indexPathForCell(cell)?.row else { return }
        guard let show = persistenceController.switchShowWithId(Int(shows[showIndex].id), on: on, inContext: context) else { return }

        shows[showIndex] = show
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}