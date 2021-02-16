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
    var shownEmotes: [[Emote]] = [[], []]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.meta()
    }
    
    private var irue: Int {
        if self.shownEmotes[0].isEmpty {
            return 1
        } else {
            return 0
        }
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
            let alert = UIAlertController(title: "Add keyboard to settings", message: "Go to Settings > General > Keyboard > Keyboards > Add New Keyboard > Tap NitrolessKeyboard > Tap Allow Full Access", preferredStyle: .alert)
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
        NotificationCenter.default.post(name: .ReloadEmotes, object: nil)
        NitrolessParser.shared.getEmotes(sender: .app)
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var noOfCellsInRow = 0
        if UIDevice.current.orientation.isLandscape || UIDevice.current.userInterfaceIdiom == .pad {
            noOfCellsInRow = 8
        } else {
            noOfCellsInRow = 4
        }
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
        self.shownEmotes = [[], []]
        if self.isbe {
            self.shownEmotes[1] = NitrolessParser.shared.emotes
        } else {
            self.shownEmotes[1] = NitrolessParser.shared.emotes.filter { (emote: Emote) -> Bool in
                emote.name.lowercased().contains(self.searchController.searchBar.text?.lowercased() ?? "")
            }
        }
        self.shownEmotes[1] = self.shownEmotes[1].sorted(by: {$0.name < $1.name} )
        
        let recentlyUsed = NitrolessParser.shared.defaults.dictionary(forKey: "RecentlyUsed") as? [String : Int] ?? [String : Int]()
        for (k, _) in (Array(recentlyUsed).sorted {$0.1 > $1.1}) {
            for (index, emote) in self.shownEmotes[1].enumerated() where emote.name == k {
                self.shownEmotes[1].remove(at: index)
                self.shownEmotes[0].append(emote)
            }
        }
        self.emotesView.reloadData()
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let url = self.shownEmotes[indexPath.section + self.irue][indexPath.row].url {
            UIPasteboard.general.string = url.absoluteString
            let alert = UIAlertController(title: "Copied!", message: "Successfully copied emote link", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            NitrolessParser.shared.add(self.shownEmotes[indexPath.section + self.irue][indexPath.row])
        }
    }
}

extension HomeViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { if self.shownEmotes[0].isEmpty { return 1 } else { return 2 } }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { self.shownEmotes[section + self.irue].count }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NitrolessViewCell", for: indexPath) as! NitrolessViewCell
        cell.emote = self.shownEmotes[indexPath.section + self.irue][indexPath.row]
        return cell
    }
}

