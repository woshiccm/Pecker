import Foundation
import SwiftSyntax
import TSCBasic
import TSCUtility

public struct XcodeReporter: Reporter {
    
    public func report(_ configuration: Configuration, sources: [SourceDetail]) {
        let diagnosticEngine = makeDiagnosticEngine()
        for source in sources {
            diagnosticEngine.emit(warning: "Pecker: \(source.name) was never used; consider removing it; \(source.location)")
        }
    }
}

/// Makes and returns a new configured diagnostic engine.
private func makeDiagnosticEngine() -> DiagnosticsEngine {
  let engine = DiagnosticsEngine()
  return engine
}
