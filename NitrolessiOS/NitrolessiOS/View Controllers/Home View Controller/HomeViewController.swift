//
//  ViewController.swift
//  NitrolessiOS
//
//  Created by Amy While on 10/02/2021.
//

import UIKit

class HomeViewController: UIViewController {
    
    var emotesView: UICollectionView?
    let searchController = UISearchController()
    
    var recentlyUsed = [Emote]()
    var repos = [Repo]()
    var toastView: ToastView = .fromNib()
    var repoContext: Repo?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.meta()
    }
    
    private var isbe: Bool {
        self.searchController.searchBar.text?.isEmpty ?? true
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
        
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.emotesView = collectionView
        view.addSubview(emotesView!)
        emotesView?.translatesAutoresizingMaskIntoConstraints = false
        emotesView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        emotesView?.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        emotesView?.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -7.5).isActive = true
        emotesView?.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 7.5).isActive = true
        emotesView?.isPrefetchingEnabled = false
    
        if repoContext == nil {
            self.title = "Nitroless"
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemNameOrNil: "info.circle"), style: .done, target: self, action: #selector(settings))
        } else {
            self.title = repoContext?.displayName
            self.updateFilter()
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
        
        emotesView?.delegate = self
        emotesView?.dataSource = self
        emotesView?.showsVerticalScrollIndicator = false
        emotesView?.showsHorizontalScrollIndicator = false
        emotesView?.backgroundColor = .none
        emotesView?.register(UINib(nibName: "NitrolessViewCell", bundle: nil), forCellWithReuseIdentifier: "NitrolessViewCell")
        emotesView?.register(UINib(nibName: "RepoHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Nitroless.RepoHeader")
        
        weak var weakSelf = self
        NotificationCenter.default.addObserver(weakSelf as Any, selector: #selector(updateFilter), name: .EmoteReload, object: nil)
        self.onBoarding()
    }
    
    @objc private func settings() {
        let settingsVC = SettingsViewController()
        let navController = NitrolessNC(rootViewController: settingsVC)
        self.present(navController, animated: true)
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let noOfCellsInRow = Int(self.view.frame.width / 50)
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 20)
    }
}

extension HomeViewController: UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.updateFilter()
    }
    
    @objc private func updateFilter() {
        if let repoContext = self.repoContext {
            self.repos = [repoContext]
            return
        }
        self.recentlyUsed.removeAll()
        var repos = RepoManager.shared.repos.sorted(by: { $0.displayName ?? "" < $1.displayName ?? "" })
         
        if let recentlyUsed = RepoManager.shared.defaults.dictionary(forKey: "Nitroless.RecentlyUsed") as? [String: Int] {
            let allEmotes = RepoManager.shared.allEmotes
            for (k, _) in (Array(recentlyUsed).sorted {$0.1 > $1.1}) {
                for emote in allEmotes where emote.url.absoluteString == k {
                    self.recentlyUsed.append(emote)
                }
            }
        }
        
        if let search = self.searchController.searchBar.text?.lowercased(),
           !search.isEmpty {
            var buffer = 0
            for (index, repo) in repos.enumerated() {
                let emotes = repo.emotes.filter({ $0.name.lowercased().contains(search) })
                if emotes.isEmpty {
                    repos.remove(at: index - buffer)
                    buffer += 1
                } else {
                    repos[index - buffer].emotes = emotes
                }
            }
        }
        self.repos = repos
        self.emotesView?.reloadData()
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let emote: Emote = { () -> Emote in
            switch section(indexPath.section) {
            case .recentlyUsed: return recentlyUsed[indexPath.row]
            case .repo: return repos[indexPath.section - (recentlyUsed.isEmpty ? 0 : 1)].emotes[indexPath.row]
            }
        }()
        UIPasteboard.general.string = emote.url.absoluteString
        RepoManager.shared.use(emote)
        if let nc = self.navigationController {
            self.toastView.showText(nc, "Copied \(emote.name)")
        }
        collectionView.deselectItem(at: indexPath, animated: true)
        if emote.type == .gif {
            collectionView.reloadItems(at: [indexPath])
        }
    }
}

extension HomeViewController: UICollectionViewDataSource {
    
    enum Section {
        case recentlyUsed
        case repo
    }
    
    func section(_ section: Int) -> Section {
        if recentlyUsed.isEmpty {
            return .repo
        } else if section == 0 {
            return .recentlyUsed
        } else {
            return .repo
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        repos.count + (recentlyUsed.isEmpty ? 0 : 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.section(section) {
        case .recentlyUsed: return recentlyUsed.count
        case .repo: return repos[section - (recentlyUsed.isEmpty ? 0 : 1)].emotes.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let emote: Emote = { () -> Emote in
            switch section(indexPath.section) {
            case .recentlyUsed: return recentlyUsed[indexPath.row]
            case .repo: return repos[indexPath.section - (recentlyUsed.isEmpty ? 0 : 1)].emotes[indexPath.row]
            }
        }()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NitrolessViewCell", for: indexPath) as! NitrolessViewCell
        cell.emote = emote
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Nitroless.RepoHeader", for: indexPath) as! RepoHeader
            switch section(indexPath.section) {
            case .repo:
                let repo = repos[indexPath.section - (recentlyUsed.isEmpty ? 0 : 1)]
                header.sectionLabel.text = repo.displayName
                header.repoLink = repo.url
            case .recentlyUsed:
                header.sectionLabel.text = "Recently Used"
                header.sectionImage.image = UIImage(systemNameOrNil: "test")
            }
            return header
        default:  fatalError("Unexpected element kind")
        }
    }
}
