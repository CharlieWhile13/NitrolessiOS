//
//  RepoManager.swift
//  NitrolessiOS
//
//  Created by Andromeda on 12/05/2021.
//

import Foundation
import Evander
import CoreGraphics

final class RepoManager {
    
    static let shared = RepoManager()
    let queue = DispatchQueue(label: "group.amywhile.nitroless.repoQueue", attributes: .concurrent)
    private let initSemphaore = DispatchSemaphore(value: 0)
    public var isLoaded = false
    
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
    
    public func remove(_ repo: URL) {
        self.repos.removeAll(where: { $0.url == repo })
        self.save()
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .RepoRemove, object: repo)
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
        for repo in repos {
            let index = repo.url.appendingPathComponent("index").appendingPathExtension("json")
            if let localDict = EvanderNetworking.localDict(url: index) {
                if let emotes = localDict["emotes"] as? [[String: String]] {
                    repo.emotes = self.emotes(emotes, repo.url, repo.path ?? "")
                }
            }
        }
        self.batchGroupLoad(repos: repos)
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
        var list = repos ?? self.repos
        DispatchQueue.global(qos: .userInitiated).async {
            let threadCount = ((ProcessInfo.processInfo.processorCount * 2) > list.count) ? list.count : (ProcessInfo.processInfo.processorCount * 2)
            let loadGroup = DispatchGroup()
            let loadLock = NSLock()
            
            for threadID in 0..<(threadCount) {
                loadGroup.enter()
                let emoteQueue = DispatchQueue(label: "repo-refresh-queue-\(threadID)")
                emoteQueue.async {
                    while true {
                        loadLock.lock()
                        guard !list.isEmpty else {
                            loadLock.unlock()
                             break
                        }
                        let repo = list.removeFirst()
                        loadLock.unlock()
                        let semaphore = DispatchSemaphore(value: 0)
                        let index = repo.url.appendingPathComponent("index").appendingPathExtension("json")
                        EvanderNetworking.dict(url: index, cache: !force) { [self] success, dict in
                            if success,
                               let dict = dict,
                               let name = dict["name"] as? String,
                               let emotes = dict["emotes"] as? [[String: String]],
                               let path = dict["path"] as? String {
                                repo.displayName = name
                                repo.path = path
                                let emotes = self.emotes(emotes, repo.url, repo.path ?? "")
                                if emotes != repo.emotes {
                                    repo.emotes = emotes
                                    batchGroupLoad(repos: [repo])
                                } else {
                                    repo.emotes = emotes
                                }
                            }
                            semaphore.signal()
                        }
                        semaphore.wait()
                    }
                    loadGroup.leave()
                }
            }
            loadGroup.notify(queue: .main) {
                NotificationCenter.default.post(name: .RepoReload, object: nil)
            }
        }
    }
    
    public func batchGroupLoad(repos: [Repo]) {
        var emotes = [Emote]()
        repos.forEach { emotes += $0.emotes }
        DispatchQueue.global(qos: .userInitiated).async {
            let threadCount = ((ProcessInfo.processInfo.processorCount * 2) > emotes.count) ? emotes.count : (ProcessInfo.processInfo.processorCount * 2)
            let loadGroup = DispatchGroup()
            let loadLock = NSLock()
            
            for threadID in 0..<(threadCount) {
                loadGroup.enter()
                let emoteQueue = DispatchQueue(label: "emote-init-queue-\(threadID)")
                emoteQueue.async {
                    while true {
                        loadLock.lock()
                        guard !emotes.isEmpty else {
                            loadLock.unlock()
                             break
                        }
                        let emote = emotes.removeFirst()
                        loadLock.unlock()
                        switch emote.type {
                        case .png:
                            _ = EvanderNetworking.shared.image(emote.url, cache: true, size: CGSize(width: 48, height: 48), nil)
                        case .gif:
                            _ = EvanderNetworking.shared.gif(emote.url, cache: true, size: CGSize(width: 48, height: 48), nil)
                        }
                    }
                    loadGroup.leave()
                }
            }
            loadGroup.notify(queue: .main) {
                if !self.isLoaded {
                    self.isLoaded = true
                    while true {
                        if self.initSemphaore.signal() == 0 {
                            break
                        }
                    }
                    self.refresh()
                }
            }
        }
    }
    
    public func initWait() {
        if Thread.isMainThread {
            fatalError("\(Thread.current.threadName) cannot be used to hold backend")
        }
        if isLoaded { return }
        initSemphaore.wait()
    }
}
