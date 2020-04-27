import Foundation
import SwiftSyntax

/// Skip optional function rule
struct SkipOptionalFunctionRule: SourceCollectRule {
    
    func skip(_ node: SyntaxProtocol, location: SourceLocation) -> Bool {
        if let funcDecl = node as? FunctionDeclSyntax {
            if let modifiers = funcDecl.modifiers {
                return modifiers.contains(where: { $0.name.text == "optional" })
            }
        }
        return false
    }
}

