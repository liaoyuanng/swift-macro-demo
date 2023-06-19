import WWDC23Helper


class UIViewController {
    
}

protocol DemonstrationProtocol {
    static func subjectTitle() -> String
    static func subtitle() -> String
}


@demonstration(subjectTitle: "Swift macros", subtitle: "How to use it?")
class TestClass: UIViewController {
    
}

