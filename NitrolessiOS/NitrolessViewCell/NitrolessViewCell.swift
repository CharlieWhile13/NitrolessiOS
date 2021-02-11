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
            if let i = emote?.image { self.imageView.image = i }
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
