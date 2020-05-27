import Foundation

public struct JSONReporter: Reporter {
    
    public func report(_ configuration: Configuration, sources: [SourceDetail]) {
        let entries = sources.map { JsonSymbol(symbol: $0.name, location: $0.location.description) }
        do {
            try writeEntries(entries: entries, to: configuration.outputFile.asURL)
        } catch {
            log("Output json file failed: \(error.localizedDescription)", level: .warning)
        }
    }
}

struct JsonSymbol: Encodable {
    let symbol: String
    let location: String
}

private func writeEntries(entries: [JsonSymbol], to path: URL) throws {
    do {
        let stringsData = NSMutableData()
        for entry in entries {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(entry)
            if let string = String(data: data, encoding: .utf8)?.replacingOccurrences(of: "\\/", with: "/"), let stringData = string.data(using: .utf16)  {
                stringsData.append(stringData)
            }
        }
        try stringsData.write(to: path, options: .atomic)
    }
}
