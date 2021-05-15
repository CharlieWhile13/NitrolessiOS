//
//  KeyboardViewController.swift
//  NitrolessKeyboard
//
//  Created by Amy While on 10/02/2021.
//

import UIKit

class KeyboardViewController: UIInputViewController {
    
    weak var proxy : UITextDocumentProxy?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .dark
        self.proxy = textDocumentProxy as UITextDocumentProxy
        
        
        if self.proxy.keyboardAppearance == .dark {
            self.keyboardView.searchBar.keyboardAppearance = .dark
            self.keyboardView.searchBar.barStyle = .black
        } else {
            self.keyboardView.searchBar.keyboardAppearance = .light
            self.keyboardView.searchBar.barStyle = .default
        }
        self.keyboardView.proxy = self.proxy
        self.keyboardView.nextKeyboard.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        //self.view.backgroundColor = ThemeManager.backgroundColour
        self.keyboardView.frame.size = view.frame.size
        self.view.addSubview(keyboardView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
}
