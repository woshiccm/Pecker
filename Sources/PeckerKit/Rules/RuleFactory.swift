import Foundation

struct RuleFactory {
    
    static var yamlConfiguration: YamlConfiguration?
    
    /// Filter disabledRules and create rule
    /// - Parameter disabledRules: The TuleTypes need to disable
    static func make() -> [Rule] {
        let disabledRules = yamlConfiguration?.disabledRules
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
        case .superClass:
            var superClassRule = SuperClassRule()
            superClassRule.blacklist = superClassRule.blacklist.union(Set(RuleFactory.yamlConfiguration?.blacklistSuperClass ?? []))
            return superClassRule
        }
    }
}
