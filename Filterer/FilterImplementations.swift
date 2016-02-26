//
//  FilterImplementations.swift
//  Filterer
//
//  Created by Marko Zanoski on 2015-12-14.
//  Copyright © 2015 UofT. All rights reserved.
//

import Foundation

var grayscaleFilter: (Pixel, [String: FilterParameter]?, Int -> UInt8) -> Pixel = {
    (var pixel: Pixel, parameters: [String: FilterParameter]?, boundsVerifier: Int -> UInt8) -> Pixel in
    
    let pixelAverage = (Int(pixel.red) + Int(pixel.green) + Int(pixel.blue)) / 3
    
    pixel.red = boundsVerifier(pixelAverage)
    pixel.green = boundsVerifier(pixelAverage)
    pixel.blue = boundsVerifier(pixelAverage)
    
    return pixel
}

var negativeFilter: (Pixel, [String: FilterParameter]?, Int -> UInt8) -> Pixel = {
    (var pixel: Pixel, parameters: [String: FilterParameter]?, boundsVerifier: Int -> UInt8) -> Pixel in
    
    pixel.red = boundsVerifier(255 - Int(pixel.red))
    pixel.green = boundsVerifier(255 - Int(pixel.green))
    pixel.blue = boundsVerifier(255 - Int(pixel.blue))
    
    return pixel
}

var channelAdjustmentFilter: (Pixel, [String: FilterParameter]?, Int -> UInt8) -> Pixel = {
    (var pixel: Pixel, parameters: [String: FilterParameter]?, boundsVerifier: Int -> UInt8)  -> Pixel in
    
    // return same values if no parameters were passed in
    guard parameters != nil else {
        return pixel
    }
    
    if let params = parameters {
        if let newChannelValue = params["red"]?.AppliedValue{
            pixel.red = boundsVerifier(newChannelValue)
        }
        
        if let newChannelValue = params["green"]?.AppliedValue{
            pixel.green = boundsVerifier(newChannelValue)
        }
        
        if let newChannelValue = params["blue"]?.AppliedValue{
            pixel.blue = boundsVerifier(newChannelValue)
        }
        
        if let newChannelValue = params["alpha"]?.AppliedValue{
            pixel.alpha = boundsVerifier(newChannelValue)
        }
    }
    return pixel
}

var sparticlesFilter: (Pixel, [String: FilterParameter]?, Int -> UInt8) -> Pixel = {
    (var pixel: Pixel, parameters: [String: FilterParameter]?, boundsVerifier: Int -> UInt8)  -> Pixel in
    
    let noiseThreshold = UInt32(parameters!["noiseThreshold"]!.AppliedValue!)
    var setNoise = arc4random_uniform(100) + 1
    
    if setNoise < noiseThreshold {
        pixel.red = UInt8(arc4random_uniform(255) + 1)
        pixel.green = UInt8(arc4random_uniform(255) + 1)
        pixel.blue = UInt8(arc4random_uniform(255) + 1)
    }
    return pixel
}

var convertToRgbFilter: (Pixel, [String: FilterParameter]?, Int -> UInt8) -> Pixel = {
    (var pixel: Pixel, parameters: [String: FilterParameter]?, boundsVerifier: Int -> UInt8)  -> Pixel in
 
    if pixel.red > pixel.blue && pixel.red > pixel.green {
        pixel.red = 255
        pixel.green = 0
        pixel.blue = 0
    }
    if pixel.green > pixel.blue && pixel.red > pixel.red {
        pixel.red = 0
        pixel.green = 255
        pixel.blue = 0
    }
    if pixel.blue > pixel.red && pixel.red > pixel.green {
        pixel.red = 0
        pixel.green = 0
        pixel.blue = 255
    }
    return pixel
}

var brightnessFilter:(Pixel, [String: FilterParameter]?, Int -> UInt8) -> Pixel = {
    (var pixel: Pixel, parameters: [String: FilterParameter]?, boundsVerifier: Int -> UInt8)  -> Pixel in
    
    let pixelAverage = Float((Int(pixel.red) + Int(pixel.green) + Int(pixel.blue)) / 3)
    let modifier = Float(parameters!["modifier"]!.AppliedValue!)
    
    pixel.red = boundsVerifier(Int(Float(pixel.red) + modifier))
    pixel.green = boundsVerifier(Int(Float(pixel.green) + modifier))
    pixel.blue = boundsVerifier(Int(Float(pixel.blue) + modifier))
    
    return pixel
}

var contrastFilter: (Pixel, [String: FilterParameter]?, Int -> UInt8) -> Pixel = {
    (var pixel: Pixel, parameters: [String: FilterParameter]?, boundsVerifier: Int -> UInt8)  -> Pixel in
    
    var modifier = Float(parameters!["modifier"]!.AppliedValue!)
    
    // hack to convert passed in interger from slider to float
    if modifier > 1 {
        modifier = modifier / 10 + 1
    }
    else if modifier < 1 {
        modifier = 1 - (modifier / 10 * -1)
    }
    
    pixel.red = boundsVerifier(Int(Float(pixel.red) * modifier))
    pixel.green = boundsVerifier(Int(Float(pixel.green) * modifier))
    pixel.blue = boundsVerifier(Int(Float(pixel.blue) * modifier))

    return pixel
}
