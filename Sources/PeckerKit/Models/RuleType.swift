import Foundation

public enum RuleType: String, Decodable {
    
    case skipPublic = "skip_public"
    case xctest
}

extension RuleType: CaseIterable {}
