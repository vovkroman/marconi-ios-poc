import Foundation
import os.log

public class Log {

    public enum Category {
        case `default`
        case lifeCycle
        case api
    }
    
    @usableFromInline
    static var bundle: String = Bundle.main.bundleIdentifier!
    
    @inlinable
    public static func info(_ message: String, category: Category = .default) {
        let customLog = OSLog(subsystem: bundle, category: "\(category)")
        os_log("%@", log: customLog, type: .info, message)
    }
    
    @inlinable
    public static func debug(_ message: String, category: Category = .default) {
        let customLog = OSLog(subsystem: bundle, category: "\(category)")
        os_log("%@%@", log: customLog, type: .debug, "✅ ", message)
    }
    
    @inlinable
    public static func error(_ message: String, category: Category = .default) {
        let customLog = OSLog(subsystem: bundle, category: "\(category)")
        os_log("%@%@", log: customLog, type: .error, "❌ ", message)
    }
}

extension Log.Category: CustomStringConvertible {
    public var description: String {
        switch self {
        case .lifeCycle:
            return "Life Cycle"
        case .api:
            return "API"
        case .default:
            return "DEBUG"
        }
    }
}
