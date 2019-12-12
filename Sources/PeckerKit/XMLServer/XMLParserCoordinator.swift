import Foundation
import TSCBasic

class XMLParserCoordinator: NSObject {
    
    private let textHolderKeys = XMLElementKind.allCases
    private let filePath: AbsolutePath
    private let xmlParser: XMLParser
    var xmlElements: Set<XMLElement> = []
    
    init(filePath: AbsolutePath) {
        self.filePath = filePath
        guard let xmlParser = XMLParser(contentsOf: filePath.asURL) else {
            preconditionFailure("error: is not found.")
        }
        self.xmlParser = xmlParser
        super.init()
        xmlParser.delegate = self
    }
    
    func parse() {
        xmlParser.parse()
    }
}

extension XMLParserCoordinator: XMLParserDelegate {
    
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        for key in textHolderKeys {
            if let value = attributeDict[key.rawValue] {
                let element = XMLElement(name: value, kind: key, module: attributeDict["customModule"])
                xmlElements.insert(element)
            }
        }
    }
}
