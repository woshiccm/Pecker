import Foundation
import SwiftSyntax

/// Skip class inherited from specific class
struct SuperClassRule: SourceCollectRule {
    
    static let blacklist: [String] = ["NotificationService",
                                      "PreviewProvider"]
    
    func skip(_ node: Syntax) -> Bool {
        if let node = node as? InheritableSyntax {
            if SuperClassRule.blacklist.contains(where: node.isInherited(from:)) {
                return true
            }
        }
        return false
    }
}
