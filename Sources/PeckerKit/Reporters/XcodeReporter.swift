import Foundation
import SwiftSyntax

public struct XcodeReporter: Reporter {
    
    public func report(sources: [SourceDetail]) {
        let diagnosticEngine = makeDiagnosticEngine()
        for source in sources {
            let message = Diagnostic.Message(.warning, "Pecker: \(source.sourceKind) \(source.name) was never used; conside remove it")
            diagnosticEngine.diagnose(message, location: source.location.toSSLocation, actions: nil)
        }
    }
}

/// Makes and returns a new configured diagnostic engine.
private func makeDiagnosticEngine() -> DiagnosticEngine {
  let engine = DiagnosticEngine()
  let consumer = PrintingDiagnosticConsumer()
  engine.addConsumer(consumer)
  return engine
}
