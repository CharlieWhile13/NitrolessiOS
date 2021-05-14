//
//  NitrolessViewCell.swift
//  NitrolessiOS
//
//  Created by Amy While on 10/02/2021.
//

import UIKit

class NitrolessViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    var emote: Emote? {
        didSet {
            self.imageView.image = nil
            self.imageView.animationImages = nil
            self.imageView.stopAnimating()
            guard let emote = emote else { return }
            let url = emote.url
            switch emote.type {
            case .png:
                if let image = AmyNetworkResolver.shared.image(url, cache: true, type: .png, { (refresh, image) in
                    if refresh,
                          let image = image,
                          self.emote?.url == url {
                        DispatchQueue.main.async {
                            self.imageView?.image = image
                        }
                    }
                }) {
                    imageView?.image = image
                }
            case .gif:
                if let gif = AmyNetworkResolver.shared.image(url, cache: true, type: .gif, { (refresh, image) in
                    if refresh,
                          let image = image,
                          let amyGif = image as? Gif,
                          self.emote?.url == url {
                        DispatchQueue.main.async {
                            self.imageView?.animationImages = amyGif.animatedImages ?? [UIImage]()
                            self.imageView.animationRepeatCount = .max
                            self.imageView.animationDuration = amyGif.calculatedDuration ?? 0
                            self.imageView.startAnimating()
                        }
                    }
                }) {
                    if let amyGif = gif as? Gif {
                        DispatchQueue.main.async {
                            self.imageView?.animationImages = amyGif.animatedImages ?? [UIImage]()
                            self.imageView.animationRepeatCount = .max
                            self.imageView.animationDuration = amyGif.calculatedDuration ?? 0
                            self.imageView.startAnimating()
                        }
                    }
                }
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.containerView.backgroundColor = ThemeManager.imageBackground
        self.containerView.layer.cornerRadius = 10
        self.containerView.layer.masksToBounds = true
    }
}
