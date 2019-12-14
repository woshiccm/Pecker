import Foundation
import SwiftSyntax

/// Add some comment before the code, will skip.
struct CommentRule: SourceCollectRule {
    
    enum Comment {
        /// If comment contains, skip
        static let signal = "pecker:ignore"
        
        /// If comment contains, skip all in the scop
        static let all = "pecker:ignore all"
    }
    
    func skip(_ node: Syntax) -> Bool {
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
        
        if let classDel: StructDeclSyntax = node.searchParent() {
            if containAllSkip(classDel) {
                return true
            }
        }
        
        if let classDel: EnumDeclSyntax = node.searchParent() {
            if containAllSkip(classDel) {
                return true
            }
        }
        
        if let classDel: ProtocolDeclSyntax = node.searchParent() {
            if containAllSkip(classDel) {
                return true
            }
        }
        
        if let classDel: ExtensionDeclSyntax = node.searchParent() {
            if containAllSkip(classDel) {
                return true
            }
        }
        
        return false
    }
    
    private func containAllSkip(_ node: Syntax) -> Bool {
        let comments = node.leadingTrivia?.compactMap({ $0.comment }) ?? []
        if comments.contains(where: { $0.contains(Comment.all) }) {
            return true
        }
        return false
    }
}
