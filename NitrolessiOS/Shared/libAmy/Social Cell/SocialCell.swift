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
            /*
            self.label.text = data.title
            if let image = UIImage(named: data.imageName) {
                self.imageViewView.image = image
            } else {
                if let url = URL(string: "https://github.com/\(data.imageName ?? "error").png") {
                    if let image = AmyNetworkResolver.shared.image(url, cache: true, type: .png, { (success, image) in
                        if success,
                              let image = image,
                              self.emote?.url == url {
                            self.imageView?.image = image
                        }
                    }) {
                        imageView?.image = image
                    }
                    NetworkManager.getData(url: url, completion: { (success, data) -> Void in
                        if let data = data {
                            if success {
                                if let image = UIImage(data: data) {
                                    DispatchQueue.main.async {
                                        self.imageViewView.image = image
                                    }
                                }
                            }
                        }
                    }
                )}
 */
            //}
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
