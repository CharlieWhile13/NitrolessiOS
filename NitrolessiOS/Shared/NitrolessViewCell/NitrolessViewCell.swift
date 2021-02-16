//
//  NitrolessViewCell.swift
//  NitrolessiOS
//
//  Created by Amy While on 10/02/2021.
//

import UIKit

class NitrolessViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    var emote: Emote? {
        didSet {
            self.imageView.animationImages = nil
            self.imageView.stopAnimating()
            if let i = emote?.image {
                switch emote?.type {
                    case .png: self.imageView.image = i
                    case .gif: do {
                        if let ag = i as? AmyGif {
                            self.imageView.animationImages = ag.image
                            self.imageView.animationDuration = ag.calculatedDuration
                            self.imageView.startAnimating()
                        }
                    }
                    default: return
                }
                self.imageView.image = i
            }
            if let t = emote?.name { self.label.text = t }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.containerView.backgroundColor = ThemeManager.imageBackground
        self.containerView.layer.cornerRadius = 10
        self.containerView.layer.masksToBounds = true
        self.label.adjustsFontSizeToFitWidth = true
    }
}
