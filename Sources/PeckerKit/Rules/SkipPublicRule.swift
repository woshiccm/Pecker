import Foundation
import SwiftSyntax

/// Skip public syntax
struct SkipPublicRule: SourceCollectRule {
    
    func skip(_ node: Syntax) -> Bool {
        return true
    }
}
