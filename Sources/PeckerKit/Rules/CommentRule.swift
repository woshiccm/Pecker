import Foundation
import SwiftSyntax

/// Add some comment before the code, will skip.
struct CommentRule: SourceCollectRule {
    
    enum Comment {
        /// If comment contains, skip
        static let signal = "pecker:ignore"
        
        /// If comment contains, skip all in the scope
        static let all = "pecker:ignore all"
    }
    
    func skip(_ node: SyntaxProtocol, location: SourceLocation) -> Bool {
        guard let node = node as? ModifierSyntax else { return true }
        let comments = node.leadingTrivia?.compactMap({ $0.comment }) ?? []
        if comments.contains(where: { $0.contains(Comment.signal) }) || comments.contains(where: { $0.contains(Comment.all) })  {
            return true
        }
        
        if let classDel: ClassDeclSyntax = node.searchParent() {
            if containAllSkip(classDel) {
                return true
            }
        }
        
        if let structDel: StructDeclSyntax = node.searchParent() {
            if containAllSkip(structDel) {
                return true
            }
        }
        
        if let enumDel: EnumDeclSyntax = node.searchParent() {
            if containAllSkip(enumDel) {
                return true
            }
        }
        
        if let protocolDel: ProtocolDeclSyntax = node.searchParent() {
            if containAllSkip(protocolDel) {
                return true
            }
        }
        
        if let extensionDel: ExtensionDeclSyntax = node.searchParent() {
            if containAllSkip(extensionDel) {
                return true
            }
        }
        
        return false
    }
    
    private func containAllSkip(_ node: SyntaxProtocol) -> Bool {
        let comments = node.leadingTrivia?.compactMap({ $0.comment }) ?? []
        if comments.contains(where: { $0.contains(Comment.all) }) {
            return true
        }
        return false
    }
}
