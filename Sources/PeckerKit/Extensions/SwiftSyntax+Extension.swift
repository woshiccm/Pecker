import Foundation
import SwiftSyntax

extension FunctionDeclSyntax {
    
    func searchParent<T: DeclSyntax>() -> T? {
        var currentParent: Syntax? = parent
        
        while currentParent != nil {
          if let decl = currentParent as? T {
            return decl
          }
          currentParent = currentParent?.parent
        }
        return nil
    }
}

extension ClassDeclSyntax {
    func isInherited(from string: String) -> Bool {
        inheritanceClause?.inheritedTypeCollection.contains(where: { $0.lastToken?.text == string }) ?? false
    }
}
