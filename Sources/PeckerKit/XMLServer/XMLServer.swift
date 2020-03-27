import Foundation
import TSCBasic

class XMLServer {
    
    private let targetPath: AbsolutePath
    private let excluded: Set<AbsolutePath>
    private let included: [AbsolutePath]
    /// The file system to operate on.
    private let fs: FileSystem
    
    private var xmlDB: Set<XMLElement> = []
    
    init(rootPath: AbsolutePath, configuration: Configuration) {
        self.targetPath = rootPath
        self.excluded = Set(configuration.excluded)
        self.included = configuration.included
        self.fs = localFileSystem
    }
    
    func bootstrap() {
        let xmlFiles = computeContents()
        for file in xmlFiles {
            let xmlParser = XMLParserCoordinator(filePath: file)
            xmlParser.parse()
            xmlDB = xmlDB.union(xmlParser.xmlElements)
        }
    }
    
    /// Compute the contents of the files in a target.
    ///
    /// This avoids recursing into certain directories like exclude.
    private func computeContents() -> [AbsolutePath] {
        var contents: [AbsolutePath] = []
        var queue: [AbsolutePath] = [targetPath]
        
        while let curr = queue.popLast() {
            
            // Ignore if this is an excluded path.
            if self.excluded.contains(curr) { continue }
            
            // Append and continue if the path has an extension
            if (curr.extension == "xib" || curr.extension == "storyboard" ) {
                contents.append(curr)
                continue
            }

            // If not directory continue
            guard fs.isDirectory(curr) else {
                continue
            }

            do {
                // Add directory content to the queue.
                let dirContents = try fs.getDirectoryContents(curr).map{ curr.appending(component: $0) }
                queue += dirContents
            } catch {
                log(error.localizedDescription, level: .warning)
            }
        }
        
        return contents
    }
}

extension XMLServer {
    
    func findXMLElement(matching: String) -> [XMLElement] {
        return xmlDB.filter { $0.name == matching }
    }
}
