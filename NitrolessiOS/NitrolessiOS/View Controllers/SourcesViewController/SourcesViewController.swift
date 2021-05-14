//
//  SourcesViewController.swift
//  NitrolessiOS
//
//  Created by Andromeda on 12/05/2021.
//

import UIKit

class SourcesViewController: BaseTableViewController {
    
    var repos = [Repo]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = ThemeManager.backgroundColour
        self.navigationController?.navigationBar.barTintColor = ThemeManager.backgroundColour
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = ThemeManager.backgroundColour
        NotificationCenter.default.addObserver(self, selector: #selector(updateRepo(_:)), name: .RepoLoad, object: nil)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRepo))
        self.title = "Sources"
        self.update()
    }
    
    @objc private func refresh() {
        RepoManager.shared.refresh(force: true)
    }
    
    @objc private func addRepo() {
        func blankAddRepoPrompt() {
            let controller = UIAlertController(title: "Add Repo", message: "Add Nitroless URL", preferredStyle: .alert)
            controller.addTextField { textField in
                textField.text = "https://"
            }
            controller.addAction(UIAlertAction(title: "Confirm", style: .default) { _ in
                let field = controller.textFields![0]
                guard let text = field.text else { return }
                let repo = handleString(text)
                if let url = URL(string: repo) {
                    add(url)
                }
            })
            controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(controller, animated: true)
        }
        
        func withLink(_ url: URL) {
            let controller = UIAlertController(title: "Add Repo", message: "Do you want to add:\n\n \(url.absoluteString)", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
                add(url)
            })
            controller.addAction(UIAlertAction(title: "No", style: .cancel) { _ in
                blankAddRepoPrompt()
            })
            self.present(controller, animated: true)
        }
        
        func add(_ url: URL) {
            let repo = Repo(url: url)
            if RepoManager.shared.append(repo) {
                RepoManager.shared.refresh(repos: [repo])
                self.update()
            }
        }
        
        func handleString(_ string: String) -> String {
            var tmp = string
            if tmp.last != "/" {
                tmp += "/"
            }
            return tmp
        }

        if #available(iOS 14.0, *) {
            UIPasteboard.general.detectPatterns(for: [.probableWebURL]) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let pattern) where pattern.contains(.probableWebURL):
                        guard let string = UIPasteboard.general.string,
                              !string.isEmpty else { return blankAddRepoPrompt() }
                        let text = handleString(string)
                        if let repo = URL(string: text) {
                            withLink(repo)
                        } else {
                            blankAddRepoPrompt()
                        }
                    case .success, .failure:
                        blankAddRepoPrompt()
                    }
                }
            }
        } else {
            guard let string = UIPasteboard.general.string,
                  !string.isEmpty else { return blankAddRepoPrompt() }
            let text = handleString(string)
            if let repo = URL(string: text) {
                withLink(repo)
            } else {
                blankAddRepoPrompt()
            }
        }
    }
    
    @objc private func updateRepo(_ notification: Notification) {
        guard let repo = notification.object as? Repo else { return }
        if let index = repos.firstIndex(where: { $0.url == repo.url }) {
            repos[index] = repo
        }
        if let cells = tableView.visibleCells as? [SourcesTableViewCell],
           let cell = cells.first(where: { $0.repo?.url == repo.url }) {
            cell.repo = repo
        }
    }
    
    public func update() {
        self.repos = RepoManager.shared.repos.sorted(by: { $0.displayName ?? "" < $1.displayName ?? "" })
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        repos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SourcesTableViewCell(style: .default, reuseIdentifier: "Nitroless.SourceCell")
        cell.repo = repos[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let trash = UIContextualAction(style: .destructive, title: "Remove") { [weak self] (action, view, completionHandler) in
            guard let strong = self else { return }
            let repo = strong.repos[indexPath.row]
            RepoManager.shared.remove(repo.url) {
                DispatchQueue.main.async {
                    strong.repos = RepoManager.shared.repos.sorted(by: { $0.displayName ?? "" < $1.displayName ?? "" })
                    strong.tableView.deleteRows(at: [indexPath], with: .automatic)
                    completionHandler(true)
                }
            }
        }
        trash.backgroundColor = .systemRed
        let configuration = UISwipeActionsConfiguration(actions: [trash])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = HomeViewController(repoContext: repos[indexPath.row])
        self.navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
