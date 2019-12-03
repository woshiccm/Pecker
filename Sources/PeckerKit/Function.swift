import Foundation
import SwiftSyntax

/// Represent a function in source code
/// Contains instanceMethod, classMethod, staticMethod
public struct Function {
    
    /// The name of a function
    public let name: String
    
    /// The parameters of a function
    public let parameters: [String]
}

extension Function: CustomStringConvertible {
    public var description: String {
        parameters.reduce("\(name)(") { $0 + "\($1):" } + ")"
    }
}
