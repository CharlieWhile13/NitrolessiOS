//
//  ViewController.swift
//  NitrolessiOS
//
//  Created by Amy While on 10/02/2021.
//

import UIKit

class HomeViewController: UIViewController {
    
    weak var emotesView: EmoteView?
    let searchController = UISearchController()
    var repoContext: Repo?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.meta()
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        emotesView?.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func onBoarding() {
        if !UserDefaults.standard.bool(forKey: "Onboarding") {
            let alert = UIAlertController(title: "Add keyboard in settings", message:
            """
            1 • Go to Settings
            2 • Go to General then Keyboard then go to Keyboards then Add New Keyboard
            3 • Tap on NitrolessKeyboard and tap it again then tap Allow Full Access
            """
                                          , preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            UserDefaults.standard.setValue(true, forKey: "Onboarding")
        }
    }
    
    init(repoContext: Repo) {
        self.repoContext = repoContext
        super.init(nibName: nil, bundle: nil)
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func meta() {
        self.view.backgroundColor = ThemeManager.backgroundColour
        self.navigationController?.navigationBar.barTintColor = ThemeManager.backgroundColour
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        let tmp = EmoteView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        self.emotesView = tmp
        view.addSubview(emotesView!)
        emotesView?.translatesAutoresizingMaskIntoConstraints = false
        emotesView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        emotesView?.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        emotesView?.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -7.5).isActive = true
        emotesView?.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 7.5).isActive = true
        emotesView?.parentController = self.navigationController
        if repoContext == nil {
            self.title = "Nitroless"
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemNameOrNil: "info.circle"), style: .done, target: self, action: #selector(settings))
        } else {
            self.title = repoContext?.displayName
            emotesView?.repoContext = repoContext
            emotesView?.updateFilter(nil)
        }
        
        searchController.loadViewIfNeeded()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.searchBar.returnKeyType = UIReturnKeyType.done
        searchController.searchBar.barStyle = .black
        self.searchController.searchBar.placeholder = "Emote Name"
        definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
 
        weak var weakSelf = self
        NotificationCenter.default.addObserver(weakSelf as Any, selector: #selector(updateFilter), name: .EmoteReload, object: nil)
        self.onBoarding()
    }
    
    @objc private func settings() {
        let settingsVC = SettingsViewController()
        let navController = NitrolessNC(rootViewController: settingsVC)
        self.present(navController, animated: true)
    }
    
    @objc private func updateFilter() {
        emotesView?.updateFilter(searchController.searchBar.text)
    }
}

extension HomeViewController: UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        emotesView?.updateFilter(searchController.searchBar.text)
    }
}
