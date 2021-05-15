//
//  SocialCell.swift
//  SignalReborn
//
//  Created by Amy While on 03/10/2020.
//  Copyright © 2020 Amy While. All rights reserved.
//

import UIKit

class SocialCell: AmyCell {
    
    var data: SocialCellData! {
        didSet {
            self.label.text = data.title
            self.imageViewView.image = data.image
        }
    }
    
    //imageView is already taken by a TableCell, comprimise
    @IBOutlet weak var imageViewView: UIImageView!
    @IBOutlet weak var buttonControl: UIControl!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.meta()
    }
    
    private func meta() {
        self.buttonControl.addTarget(self, action: #selector(openUrl), for: .touchUpInside)
        self.imageViewView.layer.masksToBounds = true
        self.imageViewView.layer.cornerRadius = self.imageViewView.frame.height / 2
    }
    
    @objc private func openUrl() {
        UIApplication.shared.open(data.link)
    }
}
