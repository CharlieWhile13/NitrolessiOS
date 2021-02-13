//
//  KeyboardView.swift
//  NitrolessKeyboard
//
//  Created by A W on 12/02/2021.
//

import UIKit

class KeyboardView: UIView {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var nextKeyboard: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    var shownEmotes: [[Emote]] = [[], []]
    var proxy: UITextDocumentProxy!
    
    private var irue: Int {
        if self.shownEmotes[0].isEmpty {
            return 1
        } else {
            return 0
        }
    }

    private var isbe: Bool {
        self.searchBar.text?.isEmpty ?? true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.meta()
    }
    
    private func meta() {
        self.backgroundColor = .clear
        self.searchBar.barStyle = .black
        self.nextKeyboard.tintColor = ThemeManager.tintColor
        //self.searchBar.tintColor = ThemeManager.tintColor
        //self.searchBar.backgroundColor = ThemeManager.backgroundColour
        self.collectionView.backgroundColor = .clear
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.register(UINib(nibName: "NitrolessViewCell", bundle: nil), forCellWithReuseIdentifier: "NitrolessViewCell")
        NotificationCenter.default.addObserver(forName: .EmoteReload, object: nil, queue: nil, using: {_ in
            self.updateFilter()
        })
    }
}

extension KeyboardView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var noOfCellsInRow = 0
        if UIDevice.current.orientation.isLandscape {
            noOfCellsInRow = 10
        } else {
            noOfCellsInRow = 5
        }
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        return CGSize(width: size, height: size)
    }
}

extension KeyboardView: UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.updateFilter()
    }
    
    private func updateFilter() {
        self.shownEmotes = [[], []]
        if self.isbe {
            self.shownEmotes[1] = NitrolessParser.shared.emotes
        } else {
            self.shownEmotes[1] = NitrolessParser.shared.emotes.filter { (emote: Emote) -> Bool in
                emote.name.lowercased().contains(self.searchBar.text?.lowercased() ?? "")
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
        self.collectionView.reloadData()
    }
}

extension KeyboardView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let url = self.shownEmotes[indexPath.section + self.irue][indexPath.row].url {
            self.proxy.insertText(url.absoluteString)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            NitrolessParser.shared.add(self.shownEmotes[indexPath.section + self.irue][indexPath.row])
        }
    }
}

extension KeyboardView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if self.shownEmotes[0].isEmpty { return 1 } else { return 2 }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.shownEmotes[section].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NitrolessViewCell", for: indexPath) as! NitrolessViewCell
        cell.emote = self.shownEmotes[indexPath.section + self.irue][indexPath.row]
        return cell
    }
}
