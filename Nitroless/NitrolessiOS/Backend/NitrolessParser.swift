//
//  NitrolessParser.swift
//  NitrolessiOS
//
//  Created by Amy While on 10/02/2021.
//

import UIKit

class NitrolessParser {
    static let shared = NitrolessParser()
    var emotes = [Emote]() {
        didSet {
            emotes = emotes.sorted(by: {$0.name < $1.name })
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .EmoteReload, object: nil)
            }
        }
    }
    
    init() {
        self.getEmotes()
    }
    
    public func getEmotes() {
        self.emotes.removeAll()
        NetworkManager.request(url: URL(string: "https://raw.githubusercontent.com/TheAlphaStream/nitroless-assets/main/emotes.json")!, completion: { (success, array) -> Void in
            if success {
                for emote in array {
                    var e = Emote()
                    e.name = emote["name"] ?? "Error"
                    switch emote["type"] {
                    case ".png": e.type = .png
                    case ".gif": e.type = .gif
                    default: break
                    }
                    switch e.type {
                    case .png: do {
                        if let url = URL(string: "https://raw.githubusercontent.com/TheAlphaStream/nitroless-assets/main/assets/\(e.name ?? "Error").png") {
                            NetworkManager.getData(url: url, completion: { (success, data) -> Void in
                                if success {
                                    if let image = UIImage(data: data!) {
                                        e.image = image
                                        e.url = url
                                        self.emotes.append(e)
                                    }
                                }
                                
                            })
                        }
                    }
                    case .gif: do {
                        if let url = URL(string: "https://raw.githubusercontent.com/TheAlphaStream/nitroless-assets/main/assets/\(e.name ?? "Error").gif") {
                            NetworkManager.getData(url: url, completion: { (success, data) -> Void in
                                if success {
                                    if let image = UIImage.gifImageWithData(data!) {
                                        e.image = image
                                        e.url = url
                                        self.emotes.append(e)
                                    }
                                }
                                
                            })
                        }
                    }
                    default: return
                    }
                }
            }
        })
    }
}

enum EmoteType {
    case png
    case gif
}

struct Emote {
    var type: EmoteType?
    var name: String!
    var url: URL?
    var image: UIImage?
}
