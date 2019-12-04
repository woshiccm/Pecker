import Foundation

private func ~= (regex: Regex, string: String) -> Bool {
    return regex.matches(string, options: [.anchored])
}

struct Regex {
    
    private let regex: NSRegularExpression
    
    init(regex: NSRegularExpression) {
        self.regex = regex
    }
    
    init(_ pattern: String, options: NSRegularExpression.Options = []) {
        do {
            regex = try NSRegularExpression(pattern: pattern, options: options)
        } catch {
            preconditionFailure("Invalid regex: \(error)")
        }
    }
    
    func matches(_ string: String, options: NSRegularExpression.MatchingOptions = []) -> Bool {
        return regex.matchesWhole(string, options: options)
    }
}

extension Regex: ExpressibleByStringLiteral {
    
    typealias StringLiteralType = String
    
    init(stringLiteral value: StringLiteralType) {
        self = Regex(value)
    }
    
    init(unicodeScalarLiteral value: String) {
        self.init(stringLiteral: value)
    }
    
    init(extendedGraphemeClusterLiteral value: String) {
        self.init(stringLiteral: value)
    }
}

extension Regex: Hashable, Equatable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(regex)
    }
    
    static func == (lhs: Regex, rhs: Regex) -> Bool {
        return lhs.regex == rhs.regex
    }
}

private extension NSRegularExpression {
    
    func matchesWhole(_ string: String, options: NSRegularExpression.MatchingOptions = []) -> Bool {
        var isMatch = false
        let length = (string as NSString).length
        enumerateMatches(in: string, options: options, range: NSRange(location: 0, length: length)) { result, _, stop in
            guard let match = result else { return }
            
            if match.range.location == 0 && match.range.length == length {
                isMatch = true
                stop.pointee = true
            }
        }
        return isMatch
    }
}
