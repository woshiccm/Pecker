import Foundation

///Detect result output type
public enum ReporterType: String, Decodable {
    
    /// Warnings displayed in the IDE
    case xcode
    
    /// Export json file
    case json
}
