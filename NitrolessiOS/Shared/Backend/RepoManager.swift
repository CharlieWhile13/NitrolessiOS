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
    var repos = [Repo]() {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .EmoteReload, object: nil)
            }
        }
    }
    
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
    
    public func append(_ repo: Repo) {
        if repos.contains(where: { $0.url != repo.url }) {
            queue.async(flags: .barrier) {
                self.repos.append(repo)
            }
        }
    }
    
    private func update(_ old: Repo, _ new: Repo) {
        guard let index = repos.firstIndex(where: { $0.url == old.url }) else { return append(new) }
        queue.async(flags: .barrier) {
            self.repos.remove(at: index)
            self.repos.append(new)
        }
    }
    
    public func remove(_ repo: Repo) {
        queue.async(flags: .barrier) {
            self.repos.removeAll(where: { $0.url == repo.url })
        }
    }
    
    public func use(_ emote: Emote) {
        guard var recentlyUsed = defaults.dictionary(forKey: "Nitroless.RecentlyUsed") as? [String: Int] else { return }
        recentlyUsed[emote.url.absoluteString] = (recentlyUsed[emote.url.absoluteString] ?? 0) + 1
        defaults.setValue(recentlyUsed, forKey: "Nitroless.RecentlyUsed")
    }
    
    init() {
        guard let customRepos = defaults.dictionary(forKey: "NitrolessRepos") as? [String: String] else { return }
        for name in customRepos.keys {
            guard let tmpUrl = customRepos[name],
                  let url = URL(string: tmpUrl) else { continue }
            let repo = Repo(url: url, displayName: name)
            self.append(repo)
        }
        self.update()
    }
    
    private func emotes(_ tmp: [[String: String]], _ repoURL: URL) -> [Emote] {
        var emotes = [Emote]()
        for emote in tmp {
            if let emote = Emote(emote: emote, repoURL: repoURL) {
                emotes.append(emote)
            }
        }
        return emotes
    }
        
    public func update() {
        if Thread.isMainThread {
            DispatchQueue.global(qos: .userInitiated).async {
                return self.update()
            }
        }
    
        for tmp in repos {
            let index = tmp.url.appendingPathComponent("index").appendingPathExtension("json")
            var new = tmp
            AmyNetworkResolver.dict(url: index, cache: true) { success, dict in
                if success,
                   let dict = dict,
                   let name = dict["name"] as? String,
                   let emotes = dict["emotes"] as? [[String: String]] {
                    new.displayName = name
                    new.emotes = self.emotes(emotes, new.url)
                    self.update(tmp, new)
                }
            }
        }
    }
}
