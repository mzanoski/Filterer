import Foundation
import UIKit

class ImageProcessor{
    private var rgbaImage: RGBAImage
    private var origianalImage: UIImage
    
    lazy var averageRed: Int = self.getAverageChannelValue("red", image: self.rgbaImage)
    lazy var averageGreen: Int = self.getAverageChannelValue("green", image: self.rgbaImage)
    lazy var averageBlue: Int = self.getAverageChannelValue("blue", image: self.rgbaImage)
    lazy var averageAlpha: Int = self.getAverageChannelValue("alpha", image: self.rgbaImage)
    
    // MARK: Inits
    init(image: UIImage){
        self.origianalImage = image
        rgbaImage = RGBAImage(image: image)!
    }
    
    func applyFilters(filters: [Filter]) -> UIImage {
        // apply the filter to each pixel in the image
        self.rgbaImage = RGBAImage(image: origianalImage)!
        
        for index in 0..<self.rgbaImage.pixels.count{
            var newPixel = self.rgbaImage.pixels[index]
            for filter in filters {
               newPixel = filter.apply(newPixel)
            }
            self.rgbaImage.pixels[index] = newPixel
        }
        return rgbaImage.toUIImage()!
    }
    
    func getImageAverageBrightness() -> Int{
        var average = 0
        for pixel in self.rgbaImage.pixels{
            let pixelAverage = (Int(pixel.red) + Int(pixel.green) + Int(pixel.blue)) / 3
            average += pixelAverage
        }
        average = average / self.rgbaImage.pixels.count
        return average
    }
    
    func getAverageChannelValue(let channel: String, let image: RGBAImage) -> Int{
        var channelAverage = 0
        
        if channel == "red" {
            for pixel in image.pixels{
                channelAverage += Int(pixel.red)
            }
        }
        
        if channel == "green" {
            for pixel in image.pixels{
                channelAverage += Int(pixel.green)
            }
        }
        
        if channel == "blue" {
            for pixel in image.pixels{
                channelAverage += Int(pixel.blue)
            }
        }
        
        if channel == "alpha" {
            for pixel in image.pixels{
                channelAverage += Int(pixel.alpha)
            }
        }
        channelAverage = channelAverage / image.pixels.count
        return channelAverage
    }
    
}