import Foundation

class XMLRule: AnalyzeRule {
    
    weak var server: XMLServer?
    
    // Need to opimize, current has not check module.
    func analyze(_ source: SourceDetail) -> Bool {
        if source.sourceKind == .class {
            return server?.findXMLElement(matching: source.name).count ?? 0 > 0
        }
        return false
    }
}
