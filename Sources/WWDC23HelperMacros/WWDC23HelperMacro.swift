import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

enum CustomError: Error, CustomStringConvertible {
    case notAViewController
    case message(String)

    var description: String {
        switch self {
        case .message(let text):
            return text
        case .notAViewController:
            return "Demostration macro must be applied to viewcontrollers."
        }
    }
 }

struct CustomDiagnosticMessage: DiagnosticMessage, Error {
    let message: String
    let diagnosticID: MessageID
    let severity: DiagnosticSeverity
}

extension CustomDiagnosticMessage: FixItMessage {
    var fixItID: MessageID { diagnosticID }
}




public struct DemostrationMacro {}

/*
extension DemostrationMacro: MemberMacro {
    
    public static func expansion<Declaration, Context>(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: Declaration,
        in context: Context
    ) throws -> [SwiftSyntax.DeclSyntax] where Declaration : SwiftSyntax.DeclGroupSyntax, Context : SwiftSyntaxMacros.MacroExpansionContext {
        
        guard case .argumentList(let arguments) = node.argument else {
            return []
        }
        
        let argumentList = arguments.compactMap { $0.expression.as(StringLiteralExprSyntax.self) }
            .compactMap { $0.segments.as(StringLiteralSegmentsSyntax.self) }
            .compactMap { $0.first?.as(StringSegmentSyntax.self) }
            .compactMap { $0.content.text }
        
        let subjectTitle = argumentList.first!
        let subtitle = argumentList.last ?? ""
        
        let protocolImpl: DeclSyntax =
        """
        
        static func subjectTitle() -> String {
            return "\(raw: subjectTitle.description)"
        }
        
        static func subtitle() -> String {
            return "\(raw: subtitle.description)"
        }
        """
        
        return [protocolImpl]
    }
    
    
}
*/

extension DemostrationMacro: ExtensionMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol, conformingTo protocols: [SwiftSyntax.TypeSyntax], in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        
        var wrongType: (Syntax?, String)?
        if let _ = declaration.as(ClassDeclSyntax.self) {
            wrongType = nil
        } else if let structDecl = declaration.as(StructDeclSyntax.self) {
            wrongType = (Syntax(structDecl.structKeyword), "struct")
        } else if let enumDecl = declaration.as(EnumDeclSyntax.self) {
            wrongType = (Syntax(enumDecl.enumKeyword), "enum")
        } else {
            wrongType = (nil, "Unknown")
        }
        
        guard wrongType == nil else {

            let (keywrodNode, type) = wrongType!
            let errorMesage = "Demostration macro must be applied to class, instead of \(type)."
            
            guard let keywrodNode = keywrodNode else  {
                throw CustomError.message(errorMesage)
            }
            
            let messageID = MessageID(domain: "WWDC23HelperMacros", id: "notAClass")
            
            let classNode = Syntax(TokenSyntax(.keyword(SwiftSyntax.Keyword.class), presence: .present))
            
            let diag = Diagnostic(node: keywrodNode,
                                  message: CustomDiagnosticMessage(
                                    message: errorMesage,
                                    diagnosticID: messageID,
                                    severity: .error),
                                  fixIts: [
                                    FixIt(message: CustomDiagnosticMessage(message: "Replace \(type) with class.",
                                                                           diagnosticID: messageID,
                                                                           severity: .error),
                                          changes: [
                                            FixIt.Change.replace(oldNode: keywrodNode,
                                                                 newNode: classNode)
                                    ])
                                ]
                                  )
            context.diagnose(diag)
            return []
        }

        let vc = declaration.as(ClassDeclSyntax.self)!
            .inheritanceClause?
            .inheritedTypes.first?
            .type.as(TypeSyntax.self)
        
        let VCName = "\(vc ?? "")".filter { $0 != Character(" ")}
        
        guard VCName == "UIViewController" else {
            throw CustomError.notAViewController
        }
        
        guard case .argumentList(let arguments) = node.arguments else {
            return []
        }
        
        let extensionDecl = try ExtensionDeclSyntax("extension \(type.trimmed): DemonstrationProtocol") {
            for arg in arguments {
                let decl: DeclSyntax =
                """
                func \(arg.label!)() -> String {
                    return \(arg.expression)
                }
                """
                decl
            }
        }
        
        return [extensionDecl]
    }
}

@main
struct WWDC23HelperPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        DemostrationMacro.self
    ]
}
