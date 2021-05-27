//
//  GifManager.swift
//  NitrolessiOS
//
//  Created by A W on 16/02/2021.
//

import UIKit
import ImageIO
import MobileCoreServices

final class Gif: UIImage {
    var calculatedDuration: Double?
    var animatedImages: [UIImage]?
    
    public func gif(data: Data, destination: URL) -> Gif? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
        let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil),
        let delayTime = ((metadata as NSDictionary)["{GIF}"] as? NSMutableDictionary)?["DelayTime"] as? Double else { return nil }
        var images = [UIImage]()
        var cgImageCache = [CGImage]()
        let imageCount = CGImageSourceGetCount(source)
        for i in 0 ..< imageCount {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil),
               let downsampled = ImageProcessing.downsample(image: UIImage(cgImage: image), to: CGSize(width: 48, height: 48)) {
                images.append(UIImage(cgImage: downsampled))
                cgImageCache.append(downsampled)
            }
        }
        let calculatedDuration = Double(imageCount) * delayTime
        self.animatedImages = images
        self.calculatedDuration = calculatedDuration
        ImageProcessing.saveGif(images: cgImageCache, duration: calculatedDuration, to: destination)
        return self
    }
}

final class ImageProcessing {
    
    public class func downsample(image: UIImage, to pointSize: CGSize) -> CGImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let data = image.pngData() as CFData?,
              let imageSource = CGImageSourceCreateWithData(data, imageSourceOptions) else { return nil }
        let maxDimentionInPixels = max(pointSize.width, pointSize.height) * UIScreen.main.scale
        let downsampledOptions = [kCGImageSourceCreateThumbnailFromImageAlways: true,
          kCGImageSourceShouldCacheImmediately: true,
          kCGImageSourceCreateThumbnailWithTransform: true,
          kCGImageSourceThumbnailMaxPixelSize: maxDimentionInPixels] as CFDictionary
        guard let downScaledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampledOptions) else { return nil }
        return downScaledImage
    }
    
    public class func saveDownsample(cgImage: CGImage, to: URL, index: Int? = nil) {
        let url: URL
        if let index = index {
            url = AmyNetworkResolver.shared.cacheDirectory.appendingPathComponent("\(index)_" + (to.absoluteString))
        } else {
            url = AmyNetworkResolver.shared.cacheDirectory.appendingPathComponent(to.absoluteString)
        }
        try? FileManager.default.removeItem(at: url)
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, kUTTypePNG, 1, nil) else { return }
        CGImageDestinationAddImage(destination, cgImage, nil)
        CGImageDestinationFinalize(destination)
    }
    
    public class func retrieveDownsample(from: URL, index: Int? = nil) -> CGImage? {
        let url: URL
        if let index = index {
            guard let tmpGif = URL(string: "\(index)_" + (from.absoluteString)) else {
                return nil
            }
            url = tmpGif
        } else {
            url = from
        }
        guard let data = try? Data(contentsOf: url) as CFData,
              let provider = CGDataProvider(data: data),
              let image = CGImage(pngDataProviderSource: provider, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent) else { return nil }
        return image
    }
    
    public class func saveGif(images: [CGImage], duration: Double, to destination: URL) {
        let defaults = RepoManager.shared.defaults
        var gifCache = defaults.object(forKey: "Nitroless.Amy.GifCache") as? [String: [String: Any]] ?? [String: [String: Any]]()
        let dict: [String: Any] = [
            "Duration": duration,
            "Frames": images.count
        ]
        gifCache[destination.absoluteString] = dict
        defaults.setValue(gifCache, forKey: "Nitroless.Amy.GifCache")
        for (index, image) in (images).enumerated() {
            ImageProcessing.saveDownsample(cgImage: image, to: destination, index: index)
        }
    }
    
    public class func retrieveGif(from: URL) -> Gif? {
        NSLog("[Nitroless] This has been called at least")
        let defaults = RepoManager.shared.defaults
        guard let gifCache = defaults.object(forKey: "Nitroless.Amy.GifCache") as? [String: [String: Any]],
              let gifDict = gifCache[from.absoluteString],
              let duration = gifDict["Duration"] as? Double,
              let frames = gifDict["Frames"] as? Int else { return nil }
        NSLog("[Nitroless] The dict has been set for \(from.absoluteString)")
        var images = [UIImage]()
        for index in (0...frames) {
            guard let downsample = ImageProcessing.retrieveDownsample(from: from, index: index) else { return nil }
            let image = UIImage(cgImage: downsample)
            images.append(image)
        }
        let gif = Gif()
        gif.animatedImages = images
        gif.calculatedDuration = duration
        return gif
    }
}
