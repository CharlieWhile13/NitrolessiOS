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
    var emote: Emote? {
        didSet {
            if let i = emote?.image { self.imageView.image = i }
            if let t = emote?.name { self.label.text = t }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 2.5
    }

}
