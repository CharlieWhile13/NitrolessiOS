//
//  SourcesTableViewCell.swift
//  NitrolessiOS
//
//  Created by Andromeda on 13/05/2021.
//

import UIKit

class SourcesTableViewCell: UITableViewCell {
    
    var repo: Repo? {
        didSet {
            guard let repo = repo else { return }
            repoImage.image = nil
            repoName.text = repo.displayName ?? "Untitled Repo"
            repoLink.text = repo.url.absoluteString
            let repoURL = repo.url
            let imageURL = repoURL.appendingPathComponent("RepoImage").appendingPathExtension("png")
            if let image = AmyNetworkResolver.shared.image(imageURL, cache: true, type: .png, { [weak self] (success, image) in
                if success,
                      let image = image,
                      self?.repo?.url == repoURL {
                    DispatchQueue.main.async {
                        self?.repoImage.image = image
                    }
                }
            }) {
                repoImage.image = image
            } else {
                repoImage.image = UIImage(named: "NoSourceIcon")
            }
        }
    }
    
    private var repoImage = UIImageView()
    private var repoName = UILabel()
    private var repoLink = UILabel()
    
    private let height: CGFloat = 50
        
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        let size = super.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
        return CGSize(width: size.width, height: max(size.height, height))
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(repoImage)
        contentView.addSubview(repoName)
        contentView.addSubview(repoLink)
        repoImage.translatesAutoresizingMaskIntoConstraints = false
        repoName.translatesAutoresizingMaskIntoConstraints = false
        repoLink.translatesAutoresizingMaskIntoConstraints = false
        
        repoImage.heightAnchor.constraint(equalToConstant: 40).isActive = true
        repoImage.widthAnchor.constraint(equalToConstant: 40).isActive = true
        repoImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        repoImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5).isActive = true
        repoImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
        contentView.bottomAnchor.constraint(equalTo: repoLink.bottomAnchor, constant: 5).isActive = true
        contentView.trailingAnchor.constraint(equalTo: repoLink.trailingAnchor, constant: 2.5).isActive = true
        repoName.leadingAnchor.constraint(equalTo: repoImage.trailingAnchor, constant: 5).isActive = true
        repoName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2.5).isActive = true
        contentView.trailingAnchor.constraint(equalTo: repoName.trailingAnchor, constant: 2.5).isActive = true
        repoLink.leadingAnchor.constraint(equalTo: repoImage.trailingAnchor, constant: 5).isActive = true
        repoLink.topAnchor.constraint(equalTo: repoName.bottomAnchor, constant: 0.5).isActive = true
        
        repoImage.layer.masksToBounds = true
        repoImage.layer.cornerRadius = 7.5
        repoName.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        repoLink.font = UIFont.systemFont(ofSize: 13, weight: .thin)
        repoName.textColor = .white
        repoLink.textColor = ThemeManager.headerColor
        backgroundColor = ThemeManager.imageBackground
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
