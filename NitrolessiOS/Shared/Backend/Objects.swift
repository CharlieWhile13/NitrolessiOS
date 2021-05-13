//
//  Emote.swift
//  NitrolessiOS
//
//  Created by Andromeda on 12/05/2021.
//

import UIKit

enum EmoteType: String {
    case png = "png"
    case gif = "gif"
}

enum Sender {
    case app
    case keyboard
}

struct Emote {
    var type: EmoteType
    var name: String
    var url: URL
    
    init?(emote: [String: String], repoURL: URL, repoPath: String) {
        guard let name = emote["name"] else { return nil }
        self.name = name
        switch emote["type"] {
        case ".png":
            self.type = .png
        case ".gif":
            self.type = .gif
        default: return nil
        }
        self.url = repoURL.appendingPathComponent(repoPath).appendingPathComponent(name).appendingPathExtension(type.rawValue)
    }
}

struct Repo {
    var displayName: String?
    var url: URL
    var emotes = [Emote]()
    var path: String?
    
    init(url: URL, displayName: String? = nil, path: String? = nil) {
        self.url = url
        self.displayName = displayName
        self.path = path
    }
}

