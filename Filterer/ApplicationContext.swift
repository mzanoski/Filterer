//
//  ApplicationContext.swift
//  Filterer
//
//  Created by Marko Zanoski on 2015-12-14.
//  Copyright © 2015 UofT. All rights reserved.
//

import Foundation
import UIKit

protocol UIStateProtocol {
    var Name: String {get}
    var hasFilteredImage: Bool {get set}
    
    func enterSate()
    func exitState()
}

class ApplicationContext {
    static let Context = ApplicationContext()
    var imageProcessor: ImageProcessor?
    var filters = Dictionary<String, Filter>()
    var appliedFilters = Dictionary<String, Filter>()
    
    var filteredImage: UIImage? 
    var originalImage: UIImage?
    var hasFilteredImage: Bool
    var hasSelectedImage: Bool
    
    var buttonFilterMap = Dictionary<Int, String>()
    
    private init(){
        hasFilteredImage = false
        hasSelectedImage = false
        
        filters["Grayscale"] = Filter(name: "Grayscale", filterFormula: grayscaleFilter, filterParameters: nil)
        filters["Negative"] = Filter(name: "Negative", filterFormula: negativeFilter, filterParameters: nil)
        filters["Brightness"] = Filter(name: "Brightness", filterFormula: brightnessFilter,
            filterParameters: Set<FilterParameter>(arrayLiteral:
                FilterParameter(name: "modifier", minValue: -100, maxValue: 100, defaultValue: 0)
            )
        )
        filters["Contrast"] = Filter(name: "Contrast", filterFormula: contrastFilter,
            filterParameters: Set<FilterParameter>(arrayLiteral:
                FilterParameter(name: "modifier", minValue: -10, maxValue: 12, defaultValue: 1)
            )
        )
        
        filters["Sparticles"] = Filter(name: "Sparticles", filterFormula: sparticlesFilter,
            filterParameters: Set<FilterParameter>(arrayLiteral:
                FilterParameter(name: "noiseThreshold", minValue: 0, maxValue: 100, defaultValue: 0)
            )
        )
    }
    
    func setImageForFiltering(image: UIImage){
        imageProcessor = ImageProcessor(image: image)
        originalImage = image
        hasSelectedImage = true
        filteredImage = nil
        hasFilteredImage = false
    }
    
    func addToButtonFilterMap(buttonTag: Int, filterName: String){
        buttonFilterMap[buttonTag] = filterName
    }
    
    func addFilterToFilterChain(buttonTag: Int){
        let filterName = buttonFilterMap[buttonTag]!
        appliedFilters[filterName] = filters[filterName]
    }
    
    func removeFilterFromFilterChain(buttonTag: Int){
        let filterName = buttonFilterMap[buttonTag]!
        appliedFilters[filterName] = nil
    }
    
    func applyFilterToImage(buttonTag: Int, filterParameters: [String: Int]?){
        let filterName = buttonFilterMap[buttonTag]!
        
        if let params = filterParameters {
            appliedFilters[filterName]?.setValueForParameters(params)
        }
        
        filteredImage = imageProcessor!.applyFilters(Array(appliedFilters.values))
        hasFilteredImage = true
    }
    
    
    
    
}