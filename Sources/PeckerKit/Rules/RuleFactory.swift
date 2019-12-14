import Foundation

struct RuleFactory {
    
    /// Filter disabledRules and create rule
    /// - Parameter disabledRules: The TuleTypes need to disable
    static func make(_ disabledRules: [RuleType]?) -> [Rule] {
        let rules: [RuleType]
        if let disabledRules = disabledRules {
            rules = RuleType.allCases.filter{ !disabledRules.contains($0) }
        } else {
            rules = RuleType.allCases
        }
        return rules.map(RuleFactory.make)
    }
    
    static func make(_ type: RuleType) -> Rule {
        switch type {
        case .skipPublic:
            return SkipPublicRule()
        case .xctest:
            return XCTestRule()
        case .attributes:
            return AttributesRule()
        case .xml:
            return XMLRule()
        case .comment:
            return CommentRule()
        }
    }
}
