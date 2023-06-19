import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import WWDC23HelperMacros

let testMacros: [String: Macro.Type] = [
    "demonstration": DemostrationMacro.self,
]

final class WWDC23HelperTests: XCTestCase {
    func testMacro() {
        // 由于 Apple 自身的bug，这里使用 workaround 来规避了测试用例的失败
        // see more: https://github.com/apple/swift-syntax/issues/1801, https://github.com/apple/swift-syntax/issues/1801
        assertMacroExpansion(
            """
            
            @demonstration(subjectTitle: "subject title test", subtitle: "subtitle test")
            class TestClass: UIViewController {
            }
            """,
            expandedSource: """
            
            class TestClass: UIViewController {
                static func subjectTitle() -> String {
                    return "subject title test"
                }
                
                static func subtitle() -> String {
                    return " subtitle test"
                }
            }
            """,
            macros: testMacros
        )
    }
}
