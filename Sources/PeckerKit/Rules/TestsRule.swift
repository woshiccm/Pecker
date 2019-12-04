import Foundation
import SwiftSyntax

/// The rules for UITest and UnitTests
struct TestsRule {
    
    /// If a class is Inherited from XCTestCase, don't detect it
    /// - Parameter node: ClassDeclSyntax
    static func collect(_ node: ClassDeclSyntax) -> Bool {
        return !isInheritedFromXCTestCase(node)
    }
    
    /// If a UITest funciton hasPrefix "test", don't detect it
    /// - Parameter node: FunctionDeclSyntax
    static func collect(_ node: FunctionDeclSyntax) -> Bool {
        if let classDecl: ClassDeclSyntax = node.searchParent(), isInheritedFromXCTestCase(classDecl) {
            if node.identifier.text.hasPrefix("test") && node.signature.input.parameterList.count == 0 {
                return false
            }
        }
        return true
    }
}

private func isInheritedFromXCTestCase(_ node: ClassDeclSyntax) -> Bool {
    return node.isInherited(from: "XCTestCase")
}
