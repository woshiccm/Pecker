import Foundation
import SwiftSyntax

protocol InheritableSyntax {
    var inheritanceClause: TypeInheritanceClauseSyntax? { get }
    func isInherited(from string: String) -> Bool
}

extension InheritableSyntax {
    func isInherited(from string: String) -> Bool {
        inheritanceClause?.inheritedTypeCollection.contains(where: { $0.lastToken?.text == string }) ?? false
    }
}

extension ClassDeclSyntax: InheritableSyntax {}
extension StructDeclSyntax: InheritableSyntax {}
extension EnumDeclSyntax: InheritableSyntax {}
extension ProtocolDeclSyntax: InheritableSyntax {}

protocol ModifierSyntax: Syntax {
    var modifiers: ModifierListSyntax? { get }
    func isPublic() -> Bool
}

extension ModifierSyntax {
    func searchParent<T: ModifierSyntax>() -> T? {
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

extension ModifierSyntax {
    func isPublic() -> Bool {
        if let modifiers = modifiers {
            if modifiers.contains(where: {
                $0.name.tokenKind == .publicKeyword
            }) {
                return true
            }
            if modifiers.contains(where: {
                $0.name.tokenKind == .privateKeyword ||
                $0.name.tokenKind == .internalKeyword ||
                $0.name.tokenKind == .fileprivateKeyword
            }) {
                return false
            }
        }
        
        if let extDel: ExtensionDeclSyntax = searchParent(),
            let modifiers = extDel.modifiers,
            modifiers.contains(where: { $0.name.tokenKind == .publicKeyword }) {
            return true
        }
        return false
    }
}

extension ClassDeclSyntax: ModifierSyntax {}
extension StructDeclSyntax: ModifierSyntax {}
extension EnumDeclSyntax: ModifierSyntax {}
extension ProtocolDeclSyntax: ModifierSyntax {}
extension FunctionDeclSyntax: ModifierSyntax {}
extension TypealiasDeclSyntax: ModifierSyntax {}
extension OperatorDeclSyntax: ModifierSyntax {}
extension ExtensionDeclSyntax: ModifierSyntax {}


protocol IdentifierSyntax: Syntax {
    var identifier: TokenSyntax { get }
}

extension ClassDeclSyntax: IdentifierSyntax {}
extension StructDeclSyntax: IdentifierSyntax {}
extension EnumDeclSyntax: IdentifierSyntax {}
extension ProtocolDeclSyntax: IdentifierSyntax {}
extension FunctionDeclSyntax: IdentifierSyntax {}
extension TypealiasDeclSyntax: IdentifierSyntax {}
extension OperatorDeclSyntax: IdentifierSyntax {}

extension TriviaPiece {
    public var comment: String? {
        switch self {
        case .spaces,
             .tabs,
             .verticalTabs,
             .formfeeds,
             .newlines,
             .carriageReturns,
             .carriageReturnLineFeeds,
             .backticks,
             .garbageText:
            return nil
        case .lineComment(let comment),
             .blockComment(let comment),
             .docLineComment(let comment),
             .docBlockComment(let comment):
            return comment
        }
    }
}
