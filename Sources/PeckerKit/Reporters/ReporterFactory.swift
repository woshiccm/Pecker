import Foundation

struct ReporterFactory {
    
    static func make(_ type: ReporterType?) -> Reporter {
        switch type {
        case .xcode?:
            return XcodeReporter()
        case .json?:
            return JSONReporter()
        default:
            return XcodeReporter()
        }
    }
}
