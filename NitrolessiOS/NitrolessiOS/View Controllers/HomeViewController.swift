//
//  ViewController.swift
//  NitrolessiOS
//
//  Created by Amy While on 10/02/2021.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var emotesView: UICollectionView!
    
    let searchController = UISearchController()
    var recentlyUsed = [Emote]()
    var repos = [Repo]()
    var toastView: ToastView = .fromNib()
    var amyCount = 0

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
    
    private func meta() {
        self.view.backgroundColor = ThemeManager.backgroundColour
        self.navigationController?.navigationBar.barTintColor = ThemeManager.backgroundColour
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
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
        
        self.emotesView.delegate = self
        self.emotesView.dataSource = self
        self.emotesView.showsVerticalScrollIndicator = false
        self.emotesView.showsHorizontalScrollIndicator = false
        self.emotesView.backgroundColor = .none
        self.emotesView.register(UINib(nibName: "NitrolessViewCell", bundle: nil), forCellWithReuseIdentifier: "NitrolessViewCell")
        NotificationCenter.default.addObserver(forName: .EmoteReload, object: nil, queue: nil, using: {_ in
            self.updateFilter()
        })
        self.onBoarding()
    }
    
    @IBAction func refresh(_ sender: Any) {
        RepoManager.shared.refresh()
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
}

extension HomeViewController: UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.updateFilter()
    }
    
    private func updateFilter() {
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
        self.emotesView.reloadData()
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let emote: Emote = { () -> Emote in
            switch section(indexPath.section) {
            case .recentlyUsed: return recentlyUsed[indexPath.row]
            case .repo: return repos[indexPath.section].emotes[indexPath.row]
            }
        }()
        UIPasteboard.general.string = emote.url.absoluteString
        RepoManager.shared.use(emote)
        if let nc = self.navigationController {
            self.toastView.showText(nc, "Copied \(emote.name)")
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
        case .repo: return repos[section].emotes.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let emote: Emote = { () -> Emote in
            switch section(indexPath.section) {
            case .recentlyUsed: return recentlyUsed[indexPath.row]
            case .repo: return repos[indexPath.section].emotes[indexPath.row]
            }
        }()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NitrolessViewCell", for: indexPath) as! NitrolessViewCell
        cell.emote = emote
        return cell
    }
}
