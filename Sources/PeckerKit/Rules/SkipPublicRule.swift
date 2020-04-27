import Foundation
import SwiftSyntax

/// Skip public syntax
struct SkipPublicRule: SourceCollectRule {
    
    func skip(_ node: SyntaxProtocol, location: SourceLocation) -> Bool {
        if let modifierSyntax = node as? ModifierSyntax {
            return modifierSyntax.isPublic()
        }
        return false
    }
}
