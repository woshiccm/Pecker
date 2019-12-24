import Foundation
import Yams

// Reference https://github.com/realm/SwiftLint/blob/master/Source/SwiftLintFramework/Models/YamlParser.swift

internal enum YamlParserError: Error, Equatable {
    case yamlParsing(String)
}

public struct YamlParser {
    public static func parse(_ yaml: String,
                             env: [String: String] = ProcessInfo.processInfo.environment) throws -> YamlConfiguration {
        do {
            let dict = try Yams.load(yaml: yaml, .default,
                                     .peckerConstructor(env: env)) as? [String: Any] ?? [:]
            let data = try JSONSerialization.data(withJSONObject: dict, options: [])
            let decoder = JSONDecoder()
            return try decoder.decode(YamlConfiguration.self, from: data)
        } catch {
            throw YamlParserError.yamlParsing("\(error)")
        }
    }
}

private extension Constructor {
    static func peckerConstructor(env: [String: String]) -> Constructor {
        return Constructor(customScalarMap(env: env))
    }

    static func customScalarMap(env: [String: String]) -> ScalarMap {
        var map = defaultScalarMap
        map[.str] = String.constructExpandingEnvVars(env: env)
        map[.bool] = Bool.constructUsingOnlyTrueAndFalse

        return map
    }
}

private extension String {
    static func constructExpandingEnvVars(env: [String: String]) -> (_ scalar: Node.Scalar) -> String? {
        return { (scalar: Node.Scalar) -> String? in
            return scalar.string.expandingEnvVars(env: env)
        }
    }

    func expandingEnvVars(env: [String: String]) -> String {
        var result = self
        for (key, value) in env {
            result = result.replacingOccurrences(of: "${\(key)}", with: value)
        }

        return result
    }
}

private extension Bool {
    static func constructUsingOnlyTrueAndFalse(from scalar: Node.Scalar) -> Bool? {
        switch scalar.string.lowercased() {
        case "true":
            return true
        case "false":
            return false
        default:
            return nil
        }
    }
}
