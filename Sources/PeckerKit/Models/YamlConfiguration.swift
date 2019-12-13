import Foundation

public struct YamlConfiguration: Decodable {
    
    /// Rule identifiers to exclude from running
    public let disabledRules: [RuleType]?
    
    /// Output type
    public let reporter: ReporterType?
    
    /// Paths to include during detecing
    public let included: [String]?
    
    /// Paths to ignore during detecing
    public let excluded: [String]?
    
    /// Acts as a blacklist, the  Files specified in this list will ignore
    public let blacklistFiles: [String]?
    
    /// Acts as a blacklist, the  symbols specified in this list will ignore
    public let blacklistSymbols: [String]?
    
    /// The path of the output  json file
    public let outputFile: String?
    
    enum CodingKeys: String, CodingKey {
        case disabledRules = "disabled_rules"
        case reporter
        case included
        case excluded
        case blacklistFiles = "blacklist_files"
        case blacklistSymbols = "blacklist_symbols"
        case outputFile = "output_file"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.disabledRules = try container.decodeIfPresent([RuleType].self, forKey: .disabledRules)
        self.reporter = try container.decodeIfPresent(ReporterType.self, forKey: .reporter)
        self.included = try container.decodeIfPresent([String].self, forKey: .included)
        self.excluded = try container.decodeIfPresent([String].self, forKey: .excluded)
        self.blacklistFiles = try container.decodeIfPresent([String].self, forKey: .blacklistFiles)
        self.blacklistSymbols = try container.decodeIfPresent([String].self, forKey: .blacklistSymbols)
        self.outputFile = try container.decodeIfPresent(String.self, forKey: .outputFile)
    }
}

extension YamlConfiguration: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(disabledRules)
        hasher.combine(reporter)
        hasher.combine(included)
        hasher.combine(excluded)
        hasher.combine(blacklistFiles)
        hasher.combine(blacklistSymbols)
        hasher.combine(outputFile)
    }
    
    public static func == (lhs: YamlConfiguration, rhs: YamlConfiguration) -> Bool {
        return (lhs.disabledRules == rhs.disabledRules) &&
            (lhs.reporter == rhs.reporter) &&
            (lhs.included == rhs.included) &&
            (lhs.excluded == rhs.excluded) &&
            (lhs.blacklistFiles == rhs.blacklistFiles) &&
            (lhs.blacklistSymbols == rhs.blacklistSymbols) &&
            (lhs.outputFile == rhs.outputFile)
    }
}
