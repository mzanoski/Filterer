import Foundation

// MARK: FilterParameter Implementation
struct FilterParameter{
    let Name: String
    let MinValue: Int?
    let MaxValue: Int?
    let DefaultValue: Int?
    var AppliedValue: Int?
    
    init(name: String, minValue: Int?, maxValue: Int?, defaultValue: Int?){
        self.Name = name
        self.MinValue = minValue
        self.MaxValue = maxValue
        self.DefaultValue = defaultValue
        self.AppliedValue = defaultValue
    }
    
    mutating func setAppliedValue(value: Int?){
        self.AppliedValue = value
    }
}

extension FilterParameter: Hashable, Equatable{
    var hashValue: Int{
        get{
            return self.Name.hashValue
        }
    }
}

// implement == operator for FilterParameter class to conform to Equatable protocol
func ==(lhs: FilterParameter, rhs: FilterParameter) -> Bool {
    return lhs.hashValue == rhs.hashValue
}


// MARK: Filter Implementation
class Filter{
    // MARK: Filter properties
    // formula is a function that takes a Pixel as a parameter and applies some calculation to each pixel value.  
    // it returns a tuple of optionals for each channel that will be applied to given pixel's red, blue, green, and/or alpha channels
    var Name: String
    private var filterFormula: (Pixel, [String: FilterParameter]?, Int -> UInt8) -> Pixel
    private(set) var Parameters: [String: FilterParameter]?
    
    typealias fFormula = (Pixel, [String: FilterParameter]?, Int -> UInt8) -> Pixel
    
    // MARK: Inits
    init(name: String, filterFormula: (Pixel, [String: FilterParameter]?, Int -> UInt8) -> Pixel, filterParameters: Set<FilterParameter>?){
        self.Name = name
        self.filterFormula = filterFormula
        
        if filterParameters != nil {
            self.Parameters = Dictionary()
            for parameter in filterParameters! {
                self.Parameters![parameter.Name] = parameter
            }
        }
        else{
            self.Parameters = nil
        }
    }
    
    // MARK: Private functions
    // called internally by the Filter to apply changes to pixel channel(s)
    private func processPixel(pixel: Pixel, filterFormula: fFormula, boundsVerifier: Int -> UInt8) -> Pixel{
        return filterFormula(pixel, self.Parameters, boundsVerifier)
    }
    
    // used to internally to prevent applying out-of-bounds UInt8 values
    private func convertIntToValidPixelValue(valueToSet: Int) -> UInt8{
        return UInt8(min(max((valueToSet), 0), 255))
    }
    
    // MARK: Internal functions
    // allows caller to apply given filter formula to apply to all channels (except alpha) in the pixel
    func apply(pixel: Pixel) -> Pixel {
        // if not specifiying the channel filter is applied to, apply to all but alpha
        return self.processPixel(pixel, filterFormula: self.filterFormula, boundsVerifier: self.convertIntToValidPixelValue)
    }
    
    func setValueForParameter(parameterName: String, value: Int){
        if var parameter = self.Parameters?[parameterName] {
            //guard parameter.MinValue != nil && value > parameter.MinValue else { return }
            //guard parameter.MaxValue != nil && value < parameter.MaxValue else { return }
            
            parameter.AppliedValue = value
            self.Parameters![parameterName] = parameter
        }
    }
    
    func setValueForParameters(parameters: [String: Int]){
        for param in parameters {
            self.setValueForParameter(param.0, value: param.1)
        }
    }
}
