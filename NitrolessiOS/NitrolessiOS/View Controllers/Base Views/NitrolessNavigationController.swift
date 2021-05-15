//
//  NitrolessNavigationController.swift
//  NitrolessiOS
//
//  Created by A W on 16/02/2021.
//

import UIKit

class NitrolessNC: UINavigationController {
    override var preferredStatusBarStyle : UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = ThemeManager.tintColor
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .dark
        }
    }
}

class NitrolessTabBarController: UITabBarController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.tintColor = ThemeManager.tintColor
        
        self.viewControllers = [homeController, sourcesController]
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .dark
        }
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var homeController: NitrolessNC {
        let vc = HomeViewController()
        let navController = NitrolessNC(rootViewController: vc)
        navController.navigationBar.prefersLargeTitles = true
        let tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemNameOrNil: "house.circle"), selectedImage: UIImage(systemNameOrNil: "house.circle.fill"))
        navController.tabBarItem = tabBarItem
        return navController
    }
    
    public var sourcesController: NitrolessNC {
        let vc: SourcesViewController
        if #available(iOS 13.0, *) {
            vc = SourcesViewController(style: .insetGrouped)
        } else {
            vc = SourcesViewController(style: .grouped)
        }
        let navController = NitrolessNC(rootViewController: vc)
        navController.navigationBar.prefersLargeTitles = true
        let tabBarItem = UITabBarItem(title: "Sources", image: UIImage(systemNameOrNil: "magnifyingglass"), selectedImage: UIImage(systemNameOrNil: "magnifyingglass"))
        navController.tabBarItem = tabBarItem
        return navController
    }
}

