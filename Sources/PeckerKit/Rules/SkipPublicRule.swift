import Foundation
import SwiftSyntax

/// Skip public syntax
struct SkipPublicRule: SourceCollectRule {
    
    func skip(_ node: Syntax) -> Bool {
        if let modifierSyntax = node as? ModifierSyntax {
            return modifierSyntax.isPublic()
        }
        return false
    }
}
