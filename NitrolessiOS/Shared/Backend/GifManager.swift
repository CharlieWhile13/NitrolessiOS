//
//  GifManager.swift
//  NitrolessiOS
//
//  Created by A W on 16/02/2021.
//

import UIKit

final class Gif: UIImage {
    var calculatedDuration: Double?
    var image: [UIImage]?
    
    override convenience init?(data: Data) {
        self.init()
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
        let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil),
        let delayTime = ((metadata as NSDictionary)["{GIF}"] as? NSMutableDictionary)?["DelayTime"] as? Double else { return nil }
        var images = [UIImage]()
        let imageCount = CGImageSourceGetCount(source)
        for i in 0 ..< imageCount {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(cgImage: image))
            }
        }
        let calculatedDuration = Double(imageCount) * delayTime
        self.image = images
        self.calculatedDuration = calculatedDuration
    }
}
