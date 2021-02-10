//
//  ViewController.swift
//  NitrolessiOS
//
//  Created by Amy While on 10/02/2021.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate, UISearchResultsUpdating {
    

    @IBOutlet weak var emotesView: UICollectionView!
    
    let searchControlller = UISearchController()
    var filteredEmotes = [Emote]()
    var emoteList = [Emote]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.meta()
        initsearchController()
    }
    
    func initsearchController() {
        searchControlller.loadViewIfNeeded()
        searchControlller.searchResultsUpdater = self
        searchControlller.obscuresBackgroundDuringPresentation = false
        searchControlller.searchBar.enablesReturnKeyAutomatically = false
        searchControlller.searchBar.returnKeyType = UIReturnKeyType.done
        definesPresentationContext = true
        
        navigationItem.searchController = searchControlller
        navigationItem.hidesSearchBarWhenScrolling = false
        searchControlller.searchBar.delegate = self
        
    }
    
    private func meta() {
        self.emotesView.delegate = self
        self.emotesView.dataSource = self
        self.emotesView.showsVerticalScrollIndicator = false
        self.emotesView.showsHorizontalScrollIndicator = false
        self.emotesView.backgroundColor = .none
        self.emotesView.register(UINib(nibName: "NitrolessViewCell", bundle: nil), forCellWithReuseIdentifier: "NitrolessViewCell")
        NotificationCenter.default.addObserver(forName: .EmoteReload, object: nil, queue: nil, using: {_ in
            self.emotesView.reloadData()
        })
    }

}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let noOfCellsInRow = 5
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))

        return CGSize(width: size, height: size)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let searchText = searchBar.text!
        
        filteredSearchText(searchText: searchText)
    }
    
    func filteredSearchText(searchText: String) {
        filteredEmotes = emoteList.filter {
            
            emote in
            if(searchControlller.searchBar.text != "") {
                let searchTextMatch = emote.name.lowercased().contains(searchText.lowercased())
                
                return searchTextMatch // this neeeds fixing as well 
            }
            else {
                return true
            }
        }
        self.emotesView.reloadData()
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Cell at row \(indexPath.row) has been pressed")
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NitrolessParser.shared.emotes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NitrolessViewCell", for: indexPath) as! NitrolessViewCell
        cell.emote = NitrolessParser.shared.emotes[indexPath.row]
        return cell
    }
}
