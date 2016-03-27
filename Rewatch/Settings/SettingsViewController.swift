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

enum SettingsSection: Int {
    case Member = 0
    case TVShows = 1
    case Support = 2
    case Debug = 3

    static var allValues: [SettingsSection] {
        return [.Member, .TVShows, .Support, .Debug]
    }
}

class SettingsViewController: UITableViewController {
    typealias Completion = () -> Void
    
    let MemberCellIdentifier = "MemberCell"
    let TVShowCellIdentifier = "TVShowCell"
    let DebugCellIdentifier = "DebugCell"
    let VersionCellIdentifier = "VersionCell"
    let SupportCellIdentifier = "SupportCell"
    let completion: Completion

    let contentController: ContentController
    let persistenceController: PersistenceController
    let analyticsController: AnalyticsController

    private lazy var shows: [StoredShow] = self.persistenceController.allShows()

    init(contentController: ContentController, persistenceController: PersistenceController, analyticsController: AnalyticsController, completion: Completion) {
        self.contentController = contentController
        self.persistenceController = persistenceController
        self.completion = completion
        self.analyticsController = analyticsController

        super.init(style: .Grouped)
        
        tableView.registerClass(MemberCell.self, forCellReuseIdentifier: MemberCellIdentifier)
        tableView.registerClass(ShowTableViewCell.self, forCellReuseIdentifier: TVShowCellIdentifier)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: DebugCellIdentifier)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: VersionCellIdentifier)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: SupportCellIdentifier)

        tableView.separatorStyle = .None
        
        title = NSLocalizedString("SETTINGS_SECTION", comment: "Settings section title")
        tableView.backgroundColor = Stylesheet.appBackgroundColor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        case .Support: return 2
        case .Debug: return 1
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let sectionSetting = SettingsSection(rawValue: indexPath.section)!

        switch sectionSetting {
        case .Member:
            return tableView.dequeueReusableCellWithIdentifier(MemberCellIdentifier, forIndexPath: indexPath)
        case .TVShows:
            let cell = tableView.dequeueReusableCellWithIdentifier(TVShowCellIdentifier, forIndexPath: indexPath) as! ShowTableViewCell
            cell.configureWithTitle(shows[indexPath.row].title ?? "", includeInRandom: true)

            return cell
        case .Support:
            return tableView.dequeueReusableCellWithIdentifier(SupportCellIdentifier, forIndexPath: indexPath)
        case .Debug:
            return tableView.dequeueReusableCellWithIdentifier(DebugCellIdentifier, forIndexPath: indexPath)
        }
    }

    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == SettingsSection.TVShows.rawValue {
            guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? ShowTableViewCell else { return nil }

            cell.toogle()
        }

        return nil
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = .clearColor()
    }

}