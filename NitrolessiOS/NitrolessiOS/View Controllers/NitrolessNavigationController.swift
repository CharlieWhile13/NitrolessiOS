//
//  NitrolessNavigationController.swift
//  NitrolessiOS
//
//  Created by A W on 16/02/2021.
//

import UIKit

class NitrolessNC: UINavigationController {
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.tintColor = ThemeManager.tintColor
    }
}

class NitrolessTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.tintColor = ThemeManager.tintColor
    }
}

