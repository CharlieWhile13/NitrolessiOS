//
//  ErrorView.swift
//  Centralis
//
//  Created by Centralis App on 27/10/2020.
//

import UIKit

class ToastView: UIView {

    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var popup: UIView!
    var heartbeat: Timer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.popup.layer.masksToBounds = true
        self.popup.layer.cornerRadius = 15
        self.popup.clipsToBounds = true
        self.popup.backgroundColor = ThemeManager.imageBackground
        self.text.textColor = .white
    }
    
    public func showText(_ sender: UIViewController, _ text: String) {
        self.heartbeat?.invalidate()
        self.removeFromSuperview()
        self.text.text = text
        self.frame = sender.view.frame
        let mFrame = self.popup.frame
        let deadframe = CGRect(x: 0, y: 0 - mFrame.width, width: mFrame.width, height: mFrame.height)
        self.popup.frame = deadframe
        sender.view.addSubview(self)
        UIView.animate(withDuration: 0.5,
                         delay: 0, usingSpringWithDamping: 1.0,
                         initialSpringVelocity: 1.0,
                         options: .curveEaseInOut, animations: {
                            self.popup.frame = mFrame
                         }, completion: { (value: Bool) in
                            self.heartbeat = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { timer in
                                self.hide()
                            }
                         })
    }
    
    public func hide() {
        let mFrame = self.popup.frame
        let deadframe = CGRect(x: 0, y: 0 - mFrame.width, width: mFrame.width, height: mFrame.height)
        UIView.animate(withDuration: 0.5,
                         delay: 0, usingSpringWithDamping: 1.0,
                         initialSpringVelocity: 1.0,
                         options: .curveEaseInOut, animations: {
                            self.popup.frame = deadframe
                         }, completion: { (value: Bool) in
                            self.removeFromSuperview()
                         })
    }
}
