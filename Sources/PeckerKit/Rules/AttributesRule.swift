import Foundation
import SwiftSyntax

/// The rules for Attribute
struct AttributesRule: SourceCollectRule {
    
    enum BlackListAttribute: String, CaseIterable {
        case ibaction = "IBAction"
    }
    
    func skip(_ node: Syntax) -> Bool {
        if let funcDecl = node as? FunctionDeclSyntax {
            return skip(funcDecl)
        }
        return false
    }
    
    /// If a fucntion attributes contains the case in BlackListAttribute, skip.
    /// - Parameter node: FunctionDeclSyntax
    func skip(_ node: FunctionDeclSyntax) -> Bool {
        if let attributesArray = node.attributes?.lazy.compactMap({ $0.tokens.map{ $0.text} }) {
            for attributes in attributesArray {
                for attribute in attributes {
                    if BlackListAttribute.allCases.contains(where: { $0.rawValue == attribute }) {
                        return true
                    }
                }
            }
        }
        return false
    }
}
