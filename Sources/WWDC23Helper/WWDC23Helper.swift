// The Swift Programming Language
// https://docs.swift.org/swift-book

@attached(conformance)
@attached(member, names: named(subjectTitle), named(subtitle))
public macro demonstration(subjectTitle: String, subtitle: String) = #externalMacro(module: "WWDC23HelperMacros", type: "DemostrationMacro")
