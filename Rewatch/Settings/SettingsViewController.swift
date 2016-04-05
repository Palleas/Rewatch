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

    private var shows = [StoredShow]()
    private var showHeaderView: SettingsHeaderView?
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

        showHeaderView = SettingsHeaderView(title: "Shows (\(self.shows.count))", actionTitle: "Select all") { [unowned self] headerView in
            self.shows
                .filter { !$0.includeInRandom }
                .forEach { $0.includeInRandom = true }

            self.tableView.reloadSections(NSIndexSet(index: SettingsSection.TVShows.rawValue), withRowAnimation: .Automatic)
            headerView.actionHidden = true
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        shows = self.persistenceController.allShows(context)

        reloadSelectAllButton()

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(SettingsViewController.didTapCancelButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(SettingsViewController.didTapDoneButton))

        let memberProducer = authenticationController.member.producer.ignoreNil()
        memberProducer.observeOn(UIScheduler()).startWithNext() { member in
            guard let memberCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: SettingsSection.Member.rawValue)) as? MemberTableViewCell else { return }
            memberCell.configureWithMemberInfos(member)
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return SettingsSection.allValues.count
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let settingsSection = SettingsSection(rawValue: section) else { return 0 }

        switch settingsSection {
        case .TVShows, .Support: return 30
        default: return 0
        }

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
            cell.delegate = self

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
        case (.TVShows, let row):
            shows[row].includeInRandom = !shows[row].includeInRandom
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: row, inSection: SettingsSection.TVShows.rawValue)], withRowAnimation: .Automatic)
            reloadSelectAllButton()
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

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = SettingsSection(rawValue: section) else { return nil }

        switch section {
        case .Support:
            return SettingsHeaderView(title: "Support")
        case .TVShows:
            return showHeaderView
        default: return nil
        }
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
            persistenceController.save()
            completion(result: .Success)
        } catch {
            print("Unable to save settings: \(error)")
        }
    }

    func reloadSelectAllButton() {
        let shouldHideButton: Bool  = shows
            .map { $0.includeInRandom }
            .reduce(true, combine: { initial, current in
                return initial && current
            })
        showHeaderView?.actionHidden = shouldHideButton
    }
}

extension SettingsViewController: ShowTableViewCellDelegate {
    func didToggleCell(cell: ShowTableViewCell, on: Bool) {
        guard let showIndex = tableView.indexPathForCell(cell)?.row else { return }

        shows[showIndex].includeInRandom = on

        reloadSelectAllButton()
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension SettingsViewController: MemberTableViewCellDelegate {
    func didTapLogoutButton() {
        // TODO: a nicer UIAlertView would be nice, eh?
        let title = NSLocalizedString("LOGOUT_CONFIRM_TITLE", comment: "Logout confirm title")
        let message = NSLocalizedString("LOGOUT_CONFIRM_MESSAGE", comment: "Logout confirm message")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel button label"), style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("LOGOUT_CONFIRM_LOGOUT", comment: "Logout button label"), style: .Destructive) { [weak self] action in
            self?.authenticationController.logout()
            self?.dismissViewControllerAnimated(true, completion: nil)
        })

        presentViewController(alert, animated: true, completion: nil)
    }
}
