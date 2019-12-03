import Foundation
import TSCUtility

/// The mode in which the `swift-format` tool should run.
enum ToolMode: String, Codable, ArgumentKind {
  case detect
  case version

  static var completion: ShellCompletion {
    return .values(
      [
        ("detect", "Detect the provided project."),
      ])
  }

  /// Creates a `ToolMode` value from the given command line argument string, throwing an error if
  /// the string is not valid.
  init(argument: String) throws {
    guard let mode = ToolMode(rawValue: argument) else {
      throw ArgumentParserError.invalidValue(argument: argument, error: .unknown(value: argument))
    }
    self = mode
  }
}
