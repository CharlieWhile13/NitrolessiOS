//
//  KeyboardViewController.swift
//  NitrolessKeyboard
//
//  Created by Amy While on 10/02/2021.
//

import UIKit

class KeyboardViewController: UIInputViewController {
    
    var proxy : UITextDocumentProxy!
    var keyboardView: KeyboardView = .fromNib()

    override func viewDidLoad() {
        super.viewDidLoad()
        NitrolessParser.shared.getEmotes()
        self.meta()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    private func meta() {
        self.proxy = textDocumentProxy as UITextDocumentProxy
        self.keyboardView.proxy = self.proxy
        self.keyboardView.nextKeyboard.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        self.view.backgroundColor = ThemeManager.backgroundColour
        self.keyboardView.frame.size = view.frame.size
        self.view.addSubview(keyboardView)
    }
}

