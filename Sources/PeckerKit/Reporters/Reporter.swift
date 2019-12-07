import Foundation

public protocol Reporter {
    
    func report(sources: [SourceDetail])
}
