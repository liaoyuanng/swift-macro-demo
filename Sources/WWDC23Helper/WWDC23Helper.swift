// The Swift Programming Language
// https://docs.swift.org/swift-book

public protocol DemonstrationProtocol {
    func subjectTitle() -> String
    func subtitle() -> String
}

@attached(extension,  conformances: DemonstrationProtocol, names: named(subjectTitle), named(subtitle))
public macro demonstration(subjectTitle: String, subtitle: String) = #externalMacro(module: "WWDC23HelperMacros", type: "DemostrationMacro")
