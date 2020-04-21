import Foundation
import SwiftSyntax

/// The rules for UITest and UnitTests
struct XCTestRule: SourceCollectRule {
    
    func skip(_ node: SyntaxProtocol, location: SourceLocation) -> Bool {
        if let clsDecl = node as? ClassDeclSyntax {
            return skip(clsDecl, location: location)
        }
        if let funcDecl = node as? FunctionDeclSyntax {
            return skip(funcDecl, location: location)
        }
        return false
    }
    
    /// If a class is Inherited from XCTestCase, skip it
    /// - Parameter node: ClassDeclSyntax
    func skip(_ node: ClassDeclSyntax, location: SourceLocation) -> Bool {
        return isInheritedFromXCTestCase(node) || fuzzyRule(location: location)
    }
    
    /// If a UITest function hasPrefix "test" and has parameters, skip it
    /// - Parameter node: FunctionDeclSyntax
    func skip(_ node: FunctionDeclSyntax, location: SourceLocation) -> Bool {
        if let classDecl: ClassDeclSyntax = node.searchParent(), isInheritedFromXCTestCase(classDecl) {
            if node.identifier.text.hasPrefix("test") && node.signature.input.parameterList.count == 0 {
                return true
            }
        }
        
        // Fuzzy recognition
        if fuzzyRule(location: location) {
            if node.identifier.text.hasPrefix("test") && node.signature.input.parameterList.count == 0 {
                return true
            }
        }
        return false
    }
    
    private func fuzzyRule(location: SourceLocation) -> Bool {
        let array = location.description.components(separatedBy: "/")
        return array.contains(where: { $0.hasSuffix("Tests") })
    }
}

private func isInheritedFromXCTestCase(_ node: ClassDeclSyntax) -> Bool {
    return node.isInherited(from: "XCTestCase")
}
