import Foundation
import SwiftSyntax
import IndexStoreDB

public protocol Rule {}

public protocol SourceCollectRule: Rule {
    
    func skip(_ node: Syntax) -> Bool
}


