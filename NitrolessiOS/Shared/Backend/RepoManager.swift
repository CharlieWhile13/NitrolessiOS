//
//  RepoManager.swift
//  NitrolessiOS
//
//  Created by Andromeda on 12/05/2021.
//

import Foundation

final class RepoManager {
    
    static let shared = RepoManager()
    let queue = DispatchQueue(label: "group.amywhile.nitroless.repoQueue", attributes: .concurrent)
    
    var repos = [Repo]() 
    
    var defaults: UserDefaults {
        UserDefaults.init(suiteName: "group.amywhile.nitroless") ?? UserDefaults.standard
    }
    
    var allEmotes: [Emote] {
        var emotes = [Emote]()
        for repo in repos {
            emotes += repo.emotes
        }
        return emotes
    }
    
    @discardableResult public func append(_ repo: Repo) -> Bool {
        if !repos.contains(where: { $0.url == repo.url }) {
            self.repos.append(repo)
            self.save()
            return true
        }
        return false
    }
    
    private func update(_ old: Repo, _ new: Repo) {
        queue.async(flags: .barrier) {
            guard let index = self.repos.firstIndex(where: { $0.url == old.url }) else { self.append(new); return }
            self.repos[index] = new
            self.save()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .RepoLoad, object: new)
            }
        }
    }
    
    public func remove(_ repo: URL, completion: (() -> ())? = nil) {
        queue.async(flags: .barrier) {
            self.repos.removeAll(where: { $0.url == repo })
            self.save()
            completion?()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .RepoRemove, object: repo)
            }
        }
    }
    
    public func use(_ emote: Emote) {
        var recentlyUsed = defaults.dictionary(forKey: "Nitroless.RecentlyUsed") as? [String: Int] ?? [String: Int]()
        recentlyUsed[emote.url.absoluteString] = (recentlyUsed[emote.url.absoluteString] ?? 0) + 1
        defaults.setValue(recentlyUsed, forKey: "Nitroless.RecentlyUsed")
    }
    
    public func save() {
        var array = [[String: String]]()
        for repo in repos {
            let dict: [String: String] = [
                "name": repo.displayName ?? "",
                "url": repo.url.absoluteString,
                "path": repo.path ?? ""
            ]
            array.append(dict)
        }
        defaults.setValue(array, forKey: "NitrolessRepos")
    }
    
    init() {
        if let customRepos = defaults.array(forKey: "NitrolessRepos") as? [[String: String]] {
            for repo in customRepos {
                guard let name = repo["name"],
                      let tmpUrl = repo["url"],
                      let url = URL(string: tmpUrl),
                      let path = repo["path"] else { continue }
                self.append(Repo(url: url, displayName: name, path: path))
            }
        }
        let repo = Repo(url: URL(string: "https://nitroless.github.io/ExampleNitrolessRepo/")!)
        self.append(repo)
        self.refresh()
    }
    
    private func emotes(_ tmp: [[String: String]], _ repoURL: URL, _ path: String) -> [Emote] {
        var emotes = [Emote]()
        for emote in tmp {
            if let emote = Emote(emote: emote, repoURL: repoURL, repoPath: path) {
                emotes.append(emote)
            }
        }
        return emotes
    }
        
    public func refresh(repos: [Repo]? = nil, force: Bool = false) {
        #if DEBUG
        NSLog("[Nitroless] Started Refresh")
        #endif
        let list = repos ?? self.repos
        for tmp in list {
            let index = tmp.url.appendingPathComponent("index").appendingPathExtension("json")
            var new = tmp
            AmyNetworkResolver.dict(url: index, cache: !force) { [weak self] success, dict in
                if success,
                   let strong = self,
                   let dict = dict,
                   let name = dict["name"] as? String,
                   let emotes = dict["emotes"] as? [[String: String]],
                   let path = dict["path"] as? String {
                    new.displayName = name
                    new.path = path
                    new.emotes = strong.emotes(emotes, new.url, new.path ?? "")
                    strong.update(tmp, new)
                    #if DEBUG
                    NSLog("[Nitroless] Finished Refreshing \(new.url)")
                    #endif
                }
            }
        }
    }
}
