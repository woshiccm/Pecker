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

extension Function {
    private var isOperator: Bool {
        Validation.isOperator(name)
    }
}

extension Function: CustomStringConvertible {
    
    /// operator function  naming rules are different from ordinary function, for example:
    /// func ==> (lhs: String, rhs: Int) -> Bool {
    ///    return lhs == String(rhs)
    /// }
    /// name is  ==>(_:_:)
    public var description: String {
        if isOperator {
            return parameters.map { _ in "_" }.reduce("\(name)(") { $0 + "\($1):" } + ")"
        } else {
            return parameters.reduce("\(name)(") { $0 + "\($1):" } + ")"
        }
    }
}
