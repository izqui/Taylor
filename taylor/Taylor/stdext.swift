import Foundation

extension String {
    /// Components of a path; ignores the leading slash and empty components
    /// e.g. "/foo/bar/baz" -> [foo, bar, baz]
    
    var taylor_pathComponents: [String] {
        return self.componentsSeparatedByString("/").filter { $0 != "" }
    }
}