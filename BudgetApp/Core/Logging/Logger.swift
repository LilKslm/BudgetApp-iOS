import Foundation

enum LogLevel: String {
    case debug = "DEBUG"
    case info  = "INFO"
    case warn  = "WARN"
    case error = "ERROR"
}

struct AppLogger {
    static func log(_ level: LogLevel, _ message: String, file: String = #file, line: Int = #line) {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let entry = "[\(level.rawValue)] [\(fileName):\(line)] \(message)"

        #if DEBUG
        print(entry)
        #endif

        // Crashlytics wiring lives in Phase 3 when Firebase is added.
        // Keeping the interface stable so call sites don't change.
    }

    static func debug(_ msg: String, file: String = #file, line: Int = #line) { log(.debug, msg, file: file, line: line) }
    static func info(_ msg: String,  file: String = #file, line: Int = #line) { log(.info,  msg, file: file, line: line) }
    static func warn(_ msg: String,  file: String = #file, line: Int = #line) { log(.warn,  msg, file: file, line: line) }
    static func error(_ msg: String, file: String = #file, line: Int = #line) { log(.error, msg, file: file, line: line) }
}
