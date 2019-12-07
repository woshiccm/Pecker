import Foundation
import SwiftSyntax

public protocol Rule {}

public protocol SourceCollectRule: Rule {
    
    func skip(_ node: Syntax) -> Bool
}


