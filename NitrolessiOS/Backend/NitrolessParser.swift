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
    
    private func saveEmote(data: Data, fileName: String) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try data.write(to: fileURL)
            } catch {
                fatalError("Well this is dumb")
            }
        }
    }
    
    private func attemptRetrieve(fileName: String) -> Data? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        do {
            return try Data(contentsOf: fileURL)
        } catch {
            return nil
        }
    }
	
    public func getEmotes() {
        self.emotes.removeAll()
        NetworkManager.request(url: URL(string: "https://raw.githubusercontent.com/TheAlphaStream/nitroless-assets/main/emotes.json")!, completion: { (success, array) -> Void in
            if success {
                var arrayICanUse = array
                var localArray = [Emote]()
                var buffer = 0
                for (index, emote) in arrayICanUse.enumerated() {
                    var fullPath = ""
                    var e = Emote()
                    e.name = emote["name"] ?? "Error"
                    switch emote["type"] {
                        case ".png": do {
                            e.type = .png
                            fullPath = e.name + ".png"
                            guard let url = URL(string: "https://raw.githubusercontent.com/TheAlphaStream/nitroless-assets/main/assets/\(e.name ?? "Error").png") else { return }
                            e.url = url
                        }
                        case ".gif": do {
                            e.type = .gif
                            fullPath = e.name + ".gif"
                            guard let url = URL(string: "https://raw.githubusercontent.com/TheAlphaStream/nitroless-assets/main/assets/\(e.name ?? "Error").gif") else { return }
                            e.url = url
                        }
                        default: break
                    }
                    if let data = self.attemptRetrieve(fileName: fullPath) {
                        switch e.type {
                            case.png: do {
                                if let image = UIImage(data: data) {
                                    e.image = image
                                    arrayICanUse.remove(at: index - buffer)
                                    buffer += 1
                                    if !localArray.contains(where: {$0.name == e.name}) {
                                        localArray.append(e)
                                    }
                                }
                            }
                            case .gif: do {
                                if let gif = UIImage.gifImageWithData(data) {
                                    e.image = gif
                                    arrayICanUse.remove(at: index - buffer)
                                    buffer += 1
                                    if !localArray.contains(where: {$0.name == e.name}) {
                                        localArray.append(e)
                                    }
                                }
                            }
                            default: break
                        }
                    }
                }
                self.emotes = localArray
                for emote in arrayICanUse {
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
                                            self.saveEmote(data: data, fileName: e.name + ".png")
                                            self.emotes.append(e)
                                        }
                                    }
                                }
                                case .gif: do {
                                    if let gif = UIImage.gifImageWithData(data) {
                                        e.image = gif
                                        if !self.emotes.contains(where: {$0.name == e.name}) {
                                            self.saveEmote(data: data, fileName: e.name + ".gif")
                                            self.emotes.append(e)
                                        }
                                    }
                                }
                                default: break
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
