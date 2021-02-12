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
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .EmoteReload, object: nil)
            }
        }
    }

    public func getEmotes() {
        self.emotes.removeAll()
        NetworkManager.request(url: URL(string: "https://raw.githubusercontent.com/TheAlphaStream/nitroless-assets/main/emotes.json")!, completion: { (success, array) -> Void in
            if success {
                for emote in array {
                    var e = Emote()
                    e.name = emote["name"] ?? "Error"
                    switch emote["type"] {
                    case ".png": do {
                        e.type = .png
                        guard let url = URL(string: "https://raw.githubusercontent.com/TheAlphaStream/nitroless-assets/main/assets/\(e.name ?? "Error").png") else { return }
                        e.url = url
                    }
                    case ".gif": do {
                        e.type = .gif
                        guard let url = URL(string: "https://raw.githubusercontent.com/TheAlphaStream/nitroless-assets/main/assets/\(e.name ?? "Error").gif") else { return }
                        e.url = url
                    }
                    default: return
                    }
                    NetworkManager.getData(url: e.url, completion: { (success, data) -> Void in
                        if let data = data {
                            if success {
                                switch e.type {
                                case.png: do {
                                    if let image = UIImage(data: data) {
                                        e.image = image
                                        if !self.emotes.contains(where: {$0.name == e.name}) {
                                            self.emotes.append(e)
                                        }
                                    }
                                }
                                case .gif: do {
                                    if let gif = UIImage.gifImageWithData(data) {
                                        e.image = gif
                                        if !self.emotes.contains(where: {$0.name == e.name}) {
                                            self.emotes.append(e)
                                        }
                                    }
                                }
                                default: return
                                }
                            }
                        }
                    })
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
    var type: EmoteType!
    var name: String!
    var url: URL!
    var image: UIImage?
}
