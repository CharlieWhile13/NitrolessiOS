//
//  SettingsViewController.swift
//  NitrolessiOS
//
//  Created by A W on 11/02/2021.
//

import UIKit

class SettingsViewController: UIViewController {

    var tableView: UITableView?
    
    var toShow: [[AmyCellData]] = [
        [
            AmyCellData(identifier: .Social, data: SocialCellData(image: SettingsViewController.staticImage("AppIcon60x60"), title: "Visit the website", link: URL(string: "https://thealphastream.github.io/nitroless/")!)),
            AmyCellData(identifier: .Social, data: SocialCellData(image: UIImage(named: "Discord"), title: "Join the Discord", link: URL(string: "https://discord.gg/4UMZcspzBy")!)),
            AmyCellData(identifier: .Social, data: SocialCellData(image: UIImage(named: "Github"), title: "View on Github", link: URL(string: "https://github.com/CharlieWhile13/NitrolessiOS")!)),
        ],
        [
            AmyCellData(identifier: .Github, data: GithubCellData(githubProfile: "elihwyma", author: "Amy", role: "iOS Developer", twitter: URL(string: "https://twitter.com/elihwyma")!)),
            AmyCellData(identifier: .Github, data: GithubCellData(githubProfile: "althiometer", author: "Evelyn", role: "macOS Developer", twitter: URL(string: "https://twitter.com/a1thio")!)),
            AmyCellData(identifier: .Github, data: GithubCellData(githubProfile: "paraskcd1315", author: "Paras", role: "Website Developer", twitter: URL(string: "https://twitter.com/paraskcd")!)),
            AmyCellData(identifier: .Github, data: GithubCellData(githubProfile: "TheAlphaStream", author: "Alpha", role: "Website Developer", twitter: URL(string: "https://twitter.com/Kutarin_")!)),
        ],
        [
            AmyCellData(identifier: .Button, data: ButtonCellData(title: "How to enable keyboard", notificationName: "KeyboardHelp")),
            AmyCellData(identifier: .Button, data: ButtonCellData(title: "Reset Recently Used", notificationName: "ResetRecentlyUsed"))
        ],
        [
            AmyCellData(identifier: .AppIcon, data: AppIconCellData(title: "Black", isDefault: true, image: SettingsViewController.staticImage("AppIcon60x60"))),
            AmyCellData(identifier: .AppIcon, data: AppIconCellData(title: "White", isDefault: false, image: SettingsViewController.staticImage("White")))
        ]
    ]
    
    public class func staticImage(_ name: String) -> UIImage {
        let path = Bundle.main.bundleURL.appendingPathComponent(name + "@2x.png")
        return UIImage(contentsOfFile: path.path) ?? UIImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.meta()
    }
    
    private func meta() {
        self.view.backgroundColor = ThemeManager.backgroundColour
        self.navigationController?.navigationBar.barTintColor = ThemeManager.imageBackground
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        if #available(iOS 13, *) {
            self.tableView = UITableView(frame: .zero, style: .insetGrouped)
        } else {
            self.tableView = UITableView(frame: .zero, style: .grouped)
        }
        
        view.addSubview(tableView!)
        tableView?.translatesAutoresizingMaskIntoConstraints = false
        tableView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView?.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView?.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView?.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(pop))
        
        tableView?.register(UINib(nibName: "ButtonCell", bundle: nil), forCellReuseIdentifier: "libAmy.ButtonCell")
        tableView?.register(UINib(nibName: "SettingsSwitchCell", bundle: nil), forCellReuseIdentifier: "libAmy.SettingsSwitchCell")
        tableView?.register(UINib(nibName: "SocialCell", bundle: nil), forCellReuseIdentifier: "libAmy.SocialCell")
        tableView?.register(UINib(nibName: "AppIconCell", bundle: nil), forCellReuseIdentifier: "libAmy.AppIconCell")
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.layer.cornerRadius = 10
        tableView?.layer.masksToBounds = true
        tableView?.tableFooterView = UIView()
        tableView?.backgroundColor = .clear
        
        weak var weakSelf = self
        NotificationCenter.default.addObserver(weakSelf as Any, selector: #selector(showAlert), name: .KeyboardHelp, object: nil)
        NotificationCenter.default.addObserver(weakSelf as Any, selector: #selector(reset), name: .ResetRecentlyUsed, object: nil)
    }
    
    @objc private func reset() {
        RepoManager.shared.defaults.removeObject(forKey: "Nitroless.RecentlyUsed")
        NotificationCenter.default.post(name: .EmoteReload, object: nil)
    }

    @objc private func pop() {
        self.dismiss(animated: true)
    }
    
    @objc private func showAlert() {
        let alert = UIAlertController(title: "Add keyboard to settings", message:
                                        """
                                            1 • Go to Settings
                                            2 • Go to General then Keyboard then go to Keyboards then Add New Keyboard
                                            3 • Tap on NitrolessKeyboard and tap it again then tap Allow Full Access
                                            """
                                      , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}
extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int { self.toShow.count }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { self.toShow[section].count }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = self.toShow[indexPath.section][indexPath.row]
        var cell: AmyCell!
        switch id.identifier {
        case .Switch:
            let b = tableView.dequeueReusableCell(withIdentifier: "libAmy.SettingsSwitchCell", for: indexPath) as! SettingsSwitchCell
            b.data = id.data as? SettingsSwitchData
            b.label.textColor = .white
            cell = b
        case .Button:
            let b = tableView.dequeueReusableCell(withIdentifier: "libAmy.ButtonCell", for: indexPath) as! ButtonCell
            b.data = id.data as? ButtonCellData
            b.label.textColor = .white
            cell = b
        case .Social:
            let b = tableView.dequeueReusableCell(withIdentifier: "libAmy.SocialCell", for: indexPath) as! SocialCell
            b.data = id.data as? SocialCellData
            b.label.textColor = .white
            cell = b
        case .AppIcon:
            let b = tableView.dequeueReusableCell(withIdentifier: "libAmy.AppIconCell", for: indexPath) as! AppIconCell
            b.data = id.data as? AppIconCellData
            b.iconName.textColor = .white
            cell = b
        case .Github:
            let b = GithubSocialCell(style: .default, reuseIdentifier: "libAmy.GithubSocialCell")
            let social = id.data as! GithubCellData
            b.social = GithubSocial(githubProfile: social.githubProfile, author: social.author, role: social.role, twitter: social.twitter)
            cell = b
        case .none: fatalError("Quite frankly how the fuck has this happened")
        }
        cell.backgroundColor = ThemeManager.imageBackground
        return cell
    }
}

extension NSNotification.Name {
    static let KeyboardHelp = Notification.Name("KeyboardHelp")
    static let ResetRecentlyUsed = Notification.Name("ResetRecentlyUsed")
}
