import Foundation
import SwiftSyntax

public final class SwiftVisitor: SyntaxVisitor {
        
    let filePath: String
    let sourceLocationConverter: SourceLocationConverter
    
    public private(set) var sources: [SourceDetail] = []
    public private(set) var sourceExtensions: [SourceDetail] = []
    
    public init(filePath: String, sourceLocationConverter: SourceLocationConverter) {
        self.filePath = filePath
        self.sourceLocationConverter = sourceLocationConverter
    }
    
    public func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        if let position = findLocaiton(syntax: node.identifier) {
            collect(SourceDetail(name: node.identifier.text, sourceKind: .class, location: position))
        }
        return .visitChildren
    }
    
    public func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        if let position = findLocaiton(syntax: node.identifier) {
            collect(SourceDetail(name: node.identifier.text, sourceKind: .struct, location: position))
        }
        return .visitChildren
    }
    
    public func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        let ps = node.signature.input.parameterList.compactMap {
            $0.firstName?.text
        }
        let function = Function(name: node.identifier.text, parameters: ps)
        if let position = findLocaiton(syntax: node.identifier) {
            collect(SourceDetail(name: function.description, sourceKind: .function, location: position))
        }
        return .visitChildren
    }
    
    public func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        if let position = findLocaiton(syntax: node.identifier) {
            collect(SourceDetail(name: node.identifier.text, sourceKind: .enum, location: position))
        }
        return .visitChildren
    }
    
    public func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        if let position = findLocaiton(syntax: node.identifier) {
            collect(SourceDetail(name: node.identifier.text, sourceKind: .protocol, location: position))
        }
        return .visitChildren
    }
    
    public func visit(_ node: TypealiasDeclSyntax) -> SyntaxVisitorContinueKind {
        if let position = findLocaiton(syntax: node.identifier) {
            collect(SourceDetail(name: node.identifier.text, sourceKind: .typealias, location: position))
        }
        return .visitChildren
    }
    
    public func visit(_ node: OperatorDeclSyntax) -> SyntaxVisitorContinueKind {
        if let position = findLocaiton(syntax: node.identifier) {
            collect(SourceDetail(name: node.identifier.text, sourceKind: .operator, location: position))
        }
        return .visitChildren
    }
    
    public func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        for token in node.extendedType.tokens {
            if let token = node.extendedType.lastToken, let position = findLocaiton(syntax: token) {
                sourceExtensions.append(SourceDetail(name: token.description , sourceKind: .extension, location: position))
            }
        }
        return .visitChildren
    }
}

extension SwiftVisitor {
    
    func collect(_ source: SourceDetail) {
        if !checkWhitelist(source: source) {
            sources.append(source)
        }
    }
    
    func findLocaiton(syntax: Syntax) -> SourceLocation? {
        let position = sourceLocationConverter.location(for: syntax.positionAfterSkippingLeadingTrivia)
        guard let line = position.line,
            let column = position.column else {
            return nil
        }
        return SourceLocation(path: filePath, line: line, column: column, offset: position.offset)
    }
}
