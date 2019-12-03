import Foundation

extension SourceDetail {
    init(name: String, sourceKind: SourceKind) {
        self.init(name: name, sourceKind: sourceKind, location: createDefaultLocation())
    }
}

func createDefaultLocation() -> SourceLocation {
    return SourceLocation(path: "", line: 0, column: 0, offset: 0)
}

/// Check if whitelist contain the giving source, if contain, don't need to detect
/// - Parameter source: The giving source
func checkWhitelist(source: SourceDetail) -> Bool {
    for s in whitelist {
        if source.name == s.name && source.sourceKind == s.sourceKind {
            return true
        }
    }
    
    return false
}


/// The sources in whitelist don't need to detect
let whitelist: [SourceDetail] = [SourceDetail(name: "AppDelegate", sourceKind: .class),
                                 SourceDetail(name: "SceneDelegate", sourceKind: .class)
                                ]


/*
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
SourceDetail(name: "viewDidAppear(_:)", sourceKind: .function)
*/
