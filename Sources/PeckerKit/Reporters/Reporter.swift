import Foundation

public protocol Reporter {
    
    func report(_ configuration: Configuration, sources: [SourceDetail])
}
