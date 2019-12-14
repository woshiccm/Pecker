import Foundation

public enum RuleType: String, Decodable, CaseIterable {
    
    case skipPublic = "skip_public"
    case xctest
    case attributes
    case xml
    case comment
}
