//
//  NitrolessViewCell.swift
//  NitrolessiOS
//
//  Created by Amy While on 10/02/2021.
//

import UIKit
import Evander

class NitrolessViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    var emote: Emote? {
        didSet {
            self.imageView.image = nil
            self.imageView.animationImages = nil
            guard let emote = emote else { return }
            let url = emote.url
            switch emote.type {
            case .png:
                if let image = EvanderNetworking.shared.image(url, cache: true, size: CGSize(width: 48, height: 48), { [weak self] refresh, image in
                    if refresh,
                          let image = image,
                          self?.emote?.url == url {
                        DispatchQueue.main.async {
                            self?.imageView?.image = image
                        }
                    }
                }) {
                    imageView?.image = image
                }
            case .gif:
                func block(_ gif: EvanderGIF) {
                    DispatchQueue.main.async {
                        self.imageView?.animationImages = gif.animatedImages ?? [UIImage]()
                        self.imageView.animationRepeatCount = .max
                        self.imageView.animationDuration = gif.calculatedDuration ?? 0
                        self.imageView.startAnimating()
                    }
                }
                if let gif = EvanderNetworking.shared.gif(url, cache: true, size: CGSize(width: 48, height: 48), { [weak self] refresh, image in
                    if refresh,
                          let image = image,
                          let gif = image as? EvanderGIF,
                          self?.emote?.url == url {
                        block(gif)
                    }
                }) {
                    if let gif = gif as? EvanderGIF {
                        block(gif)
                    }
                }
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.backgroundColor = ThemeManager.imageBackground
        containerView.layer.cornerRadius = 7.5
        containerView.layer.masksToBounds = true
    }
}
