//
//  KeyboardViewController.swift
//  NitrolessKeyboard
//
//  Created by Amy While on 10/02/2021.
//

import UIKit

class KeyboardViewController: UIInputViewController {
    
    weak var proxy : UITextDocumentProxy?
    private lazy var emotesView: EmoteView = {
        let view = EmoteView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.parentController = self
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .dark
        self.proxy = textDocumentProxy as UITextDocumentProxy
        view.addSubview(emotesView)
        NSLayoutConstraint.activate([
            emotesView.topAnchor.constraint(equalTo: view.topAnchor),
            emotesView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emotesView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 7.5),
            emotesView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -7.5)
        ])
        
        NSLog("[Nitroless] \(view.frame) \(view.bounds)")
        /*
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
        */
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
}
