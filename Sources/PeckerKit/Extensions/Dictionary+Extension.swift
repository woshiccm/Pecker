import Foundation

extension Dictionary {

    /// Merge keys/values of two dictionaries. If key is conflict, use the second dictionary.
    ///
    /// let dict : [String : String] = ["key1" : "value1"]
    /// let dict2 : [String : String] = ["key2" : "value2"]
    /// let result = dict + dict2
    /// result["key1"] -> "value1"
    /// result["key2"] -> "value2"
    static func + (lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
        return lhs.merging(rhs) { (_, new) in new }
    }

    /// Merge keys and values from the second dictionary into the first one. If key is conflict, use the second dictionary.
    ///
    /// var dict : [String : String] = ["key1" : "value1"]
    /// let dict2 : [String : String] = ["key2" : "value2"]
    /// dict += dict2
    /// dict["key1"] -> "value1"
    /// dict["key2"] -> "value2"
    static func += (lhs: inout [Key: Value], rhs: [Key: Value]) {
        lhs.merge(rhs) { (_, new) in new }
    }
}
