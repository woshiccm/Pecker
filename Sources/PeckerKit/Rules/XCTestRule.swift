import Foundation
import SwiftSyntax

/// The rules for UITest and UnitTests
struct XCTestRule: SourceCollectRule {
    
    func skip(_ node: Syntax) -> Bool {
        if let clsDecl = node as? ClassDeclSyntax {
            return skip(clsDecl)
        }
        if let funcDecl = node as? FunctionDeclSyntax {
            return skip(funcDecl)
        }
        return false
    }
    
    /// If a class is Inherited from XCTestCase, skip it
    /// - Parameter node: ClassDeclSyntax
    func skip(_ node: ClassDeclSyntax) -> Bool {
        return isInheritedFromXCTestCase(node)
    }
    
    /// If a UITest funciton hasPrefix "test" and has parameters, skip it
    /// - Parameter node: FunctionDeclSyntax
    func skip(_ node: FunctionDeclSyntax) -> Bool {
        if let classDecl: ClassDeclSyntax = node.searchParent(), isInheritedFromXCTestCase(classDecl) {
            if node.identifier.text.hasPrefix("test") && node.signature.input.parameterList.count == 0 {
                return true
            }
        }
        return false
    }
}

private func isInheritedFromXCTestCase(_ node: ClassDeclSyntax) -> Bool {
    return node.isInherited(from: "XCTestCase")
}
