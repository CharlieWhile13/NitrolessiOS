//
//  BridgingStubs.swift
//  NitrolessiOS
//
//  Created by A W on 11/02/2021.
//

import UIKit

class AmyCell: UITableViewCell {}

enum AmyCellType {
    case Button
    case Switch
    case Social
    case AppIcon
    case Github
}

protocol CellData {}

struct AmyCellData {
    var identifier: AmyCellType!
    var data: CellData?
}

struct SettingsSwitchData: CellData {
    var defaultName: String!
    var title: String!
    var defaultState: Bool!
}

struct SocialCellData: CellData {
    var image: UIImage!
    var title: String!
    var link: URL!
}

struct GithubCellData: CellData {
    
    init(githubProfile: String, author: String, role: String, twitter: URL) {
        self.githubProfile = githubProfile
        self.author = author
        self.role = role
        self.twitter = twitter
    }
    
    var githubProfile: String
    var author: String
    var role: String
    var twitter: URL
}

struct ButtonCellData: CellData {
    var title: String!
    var notificationName: String!
}

struct AppIconCellData: CellData {
    var title: String!
    var isDefault: Bool!
    var image: UIImage!
}
