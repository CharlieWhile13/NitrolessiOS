//
//  EmoteView.swift
//  NitrolessiOS
//
//  Created by Andromeda on 15/05/2021.
//

import UIKit

class EmoteView: UICollectionView {

    var recentlyUsed = [Emote]()
    var repos = [Repo]()
    var toastView: ToastView = .fromNib()
    var repoContext: Repo?
    weak var parentController: UINavigationController?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        isPrefetchingEnabled = false
        delegate = self
        dataSource = self
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        backgroundColor = .none
        register(UINib(nibName: "NitrolessViewCell", bundle: nil), forCellWithReuseIdentifier: "NitrolessViewCell")
        register(UINib(nibName: "RepoHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Nitroless.RepoHeader")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc public func updateFilter(_ string: String? = nil) {
        if let repoContext = self.repoContext {
            self.repos = [repoContext]
            return
        }
        self.recentlyUsed.removeAll()
        var repos = RepoManager.shared.repos.sorted(by: { $0.displayName?.lowercased() ?? "" < $1.displayName?.lowercased() ?? "" })
         
        if let recentlyUsed = RepoManager.shared.defaults.dictionary(forKey: "Nitroless.RecentlyUsed") as? [String: Int] {
            let allEmotes = RepoManager.shared.allEmotes
            for (k, _) in (Array(recentlyUsed).sorted {$0.1 > $1.1}) {
                for emote in allEmotes where emote.url.absoluteString == k {
                    self.recentlyUsed.append(emote)
                }
            }
        }
        
        if let search = string?.lowercased(),
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
        self.reloadData()
    }
}

extension EmoteView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let noOfCellsInRow = Int(self.frame.width / 50)
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if repoContext != nil {
            return .zero
        } else {
            return CGSize(width: collectionView.frame.width, height: 20)
        }
    }
}

extension EmoteView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let emote: Emote = { () -> Emote in
            switch section(indexPath.section) {
            case .recentlyUsed: return recentlyUsed[indexPath.row]
            case .repo: return repos[indexPath.section - (recentlyUsed.isEmpty ? 0 : 1)].emotes[indexPath.row]
            }
        }()
        UIPasteboard.general.string = emote.url.absoluteString
        RepoManager.shared.use(emote)
        if let nc = parentController {
            self.toastView.showText(nc, "Copied \(emote.name)")
        }
        collectionView.deselectItem(at: indexPath, animated: true)
        if emote.type == .gif {
            collectionView.reloadItems(at: [indexPath])
        }
    }
}

extension EmoteView: UICollectionViewDataSource {
    
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
                header.sectionImage.image = UIImage(named: "RecentlyUsed")
            }
            return header
        default:  fatalError("Unexpected element kind")
        }
    }
}
