import Foundation

extension SourceDetail {
    init(name: String, sourceKind: SourceKind) {
        self.init(name: name, sourceKind: sourceKind, location: createDefaultLocation())
    }
}

func createDefaultLocation() -> SourceLocation {
    return SourceLocation(path: "", line: 0, column: 0, offset: 0)
}

/// Check if blacklist contain the giving source, if contain, ignore.
/// - Parameter source: The giving source
func checkBlacklist(source: SourceDetail) -> Bool {
    for s in blacklistSources {
        if source.name == s.name && source.sourceKind == s.sourceKind {
            return true
        }
    }
    
    return false
}

/// The sources in blacklist ignore.
let blacklistSources: [SourceDetail] = [SourceDetail(name: "AppDelegate", sourceKind: .class),
                                        SourceDetail(name: "SceneDelegate", sourceKind: .class),
                                        SourceDetail(name: "application(_:didFinishLaunchingWithOptions:)", sourceKind: .function),
                                        SourceDetail(name: "applicationWillResignActive(_:) ", sourceKind: .function),
                                        SourceDetail(name: "applicationDidEnterBackground(_:)", sourceKind: .function),
                                        SourceDetail(name: "applicationWillEnterForeground(_:)", sourceKind: .function),
                                        SourceDetail(name: "applicationDidBecomeActive(_:)", sourceKind: .function),
                                        SourceDetail(name: "applicationWillTerminate(_:)", sourceKind: .function),
                                        SourceDetail(name: "applicationDidFinishLaunching(_:) ", sourceKind: .function),
                                        SourceDetail(name: "applicationDidReceiveMemoryWarning(_:)", sourceKind: .function),
                                        SourceDetail(name: "application(_:configurationForConnecting:options:)", sourceKind: .function),
                                        SourceDetail(name: "viewDidLoad()", sourceKind: .function),
                                        SourceDetail(name: "viewDidAppear(_:)", sourceKind: .function),
                                        SourceDetail(name: "viewWillAppear(_:)", sourceKind: .function),
                                        SourceDetail(name: "viewWillDisappear(_:)", sourceKind: .function),
                                        SourceDetail(name: "viewDidDisappear(_:)", sourceKind: .function),
                                        SourceDetail(name: "CodingKeys", sourceKind: .enum)
                                        ]

