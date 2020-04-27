import Foundation
import SwiftSyntax

/// Skip class inherited from specific class
struct SuperClassRule: SourceCollectRule {
    
    var blacklist: Set<String> = ["NotificationService",
                                  "PreviewProvider"]
    
    func skip(_ node: SyntaxProtocol, location: SourceLocation) -> Bool {
        if let node = node as? InheritableSyntax {
            if blacklist.contains(where: node.isInherited(from:)) {
                return true
            }
        }
        return false
    }
}
