//
//  SettingsViewController.swift
//  NitrolessiOS
//
//  Created by A W on 11/02/2021.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var toShow: [[AmyCellData]] = [
        [
            AmyCellData(identifier: .Social, data: SocialCellData(imageName: "Nitroless", title: "Visit the website", link: URL(string: "https://thealphastream.github.io/nitroless/")!)),
            AmyCellData(identifier: .Social, data: SocialCellData(imageName: "Discord", title: "Join the Discord", link: URL(string: "https://discord.gg/4UMZcspzBy")!)),
            AmyCellData(identifier: .Social, data: SocialCellData(imageName: "Github", title: "View on Github", link: URL(string: "https://github.com/CharlieWhile13/NitrolessiOS")!)),
        ],
        [
            AmyCellData(identifier: .Social, data: SocialCellData(imageName: "Alpha", title: "Alpha_Stream ~ Site and Assets", link: URL(string: "https://twitter.com/Kutarin_")!)),
            AmyCellData(identifier: .Social, data: SocialCellData(imageName: "Paras", title: "ParasKCD ~ Site and Assets", link: URL(string: "https://twitter.com/paraskcd")!)),
            AmyCellData(identifier: .Social, data: SocialCellData(imageName: "Amy", title: "Amy ~ iOS App", link: URL(string: "https://twitter.com/elihweilrahc13")!)),
            AmyCellData(identifier: .Social, data: SocialCellData(imageName: "Althio", title: "Althio ~ Mac App", link: URL(string: "https://twitter.com/a1thio")!)),
        ],
        [
            AmyCellData(identifier: .Button, data: ButtonCellData(title: "How to enable keyboard", notificationName: "KeyboardHelp"))
        ],
        [
            AmyCellData(identifier: .AppIcon, data: AppIconCellData(title: "Black", isDefault: true, image: "Nitroless")),
            AmyCellData(identifier: .AppIcon, data: AppIconCellData(title: "White", isDefault: false, image: "White"))
        ]
    ]
    
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

        self.tableView.register(UINib(nibName: "ButtonCell", bundle: nil), forCellReuseIdentifier: "libAmy.ButtonCell")
        self.tableView.register(UINib(nibName: "SettingsSwitchCell", bundle: nil), forCellReuseIdentifier: "libAmy.SettingsSwitchCell")
        self.tableView.register(UINib(nibName: "SocialCell", bundle: nil), forCellReuseIdentifier: "libAmy.SocialCell")
        self.tableView.register(UINib(nibName: "AppIconCell", bundle: nil), forCellReuseIdentifier: "libAmy.AppIconCell")
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.layer.cornerRadius = 10
        self.tableView.layer.masksToBounds = true
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = .clear
        
        NotificationCenter.default.addObserver(self, selector: #selector(showAlert), name: .KeyboardHelp, object: nil)
    }

    @IBAction func pop(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @objc private func showAlert() {
        let alert = UIAlertController(title: "Add keyboard to settings", message: "Go to Settings > General > Keyboard > Keyboards > Add New Keyboard > Tap NitrolessKeyboard > Tap Allow Full Access", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    
}
extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int { self.toShow.count }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { self.toShow[section].count }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 30 }
        
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cornerRadius = 10
        var corners: UIRectCorner = []

        if indexPath.row == 0 {
            corners.update(with: .topLeft)
            corners.update(with: .topRight)
        }

        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            corners.update(with: .bottomLeft)
            corners.update(with: .bottomRight)
        }

        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: cell.bounds,
                                      byRoundingCorners: corners,
                                      cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        cell.layer.mask = maskLayer
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = self.toShow[indexPath.section][indexPath.row]
        var cell: AmyCell!
        switch id.identifier {
            case .Switch: do {
                let b = tableView.dequeueReusableCell(withIdentifier: "libAmy.SettingsSwitchCell", for: indexPath) as! SettingsSwitchCell
                b.data = id.data as? SettingsSwitchData
                b.label.textColor = .white
                cell = b
            }
            case .Button: do {
                let b = tableView.dequeueReusableCell(withIdentifier: "libAmy.ButtonCell", for: indexPath) as! ButtonCell
                b.data = id.data as? ButtonCellData
                b.label.textColor = .white
                cell = b
            }
            case .Social: do {
                let b = tableView.dequeueReusableCell(withIdentifier: "libAmy.SocialCell", for: indexPath) as! SocialCell
                b.data = id.data as? SocialCellData
                b.label.textColor = .white
                cell = b
            }
            case .AppIcon: do {
                let b = tableView.dequeueReusableCell(withIdentifier: "libAmy.AppIconCell", for: indexPath) as! AppIconCell
                b.data = id.data as? AppIconCellData
                b.iconName.textColor = .white
                cell = b
            }
            case .none: fatalError("Quite frankly how the fuck has this happened")
        }
        cell.backgroundColor = ThemeManager.imageBackground
        return cell
    }
}

extension NSNotification.Name {
    static let KeyboardHelp = Notification.Name("KeyboardHelp")
}
