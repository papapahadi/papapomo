import Foundation

enum PomodoroPhase: String {
    case work = "Focus"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"
}

struct PomodoroSettings: Codable, Equatable {
    var workMinutes: Int = 25
    var shortBreakMinutes: Int = 5
    var longBreakMinutes: Int = 15
    var sessionsBeforeLongBreak: Int = 4
}

struct DayStat: Identifiable {
    let date: Date
    let seconds: Int

    var id: String { FocusDateKey.key(for: date) }
}

struct WeekSummary {
    let totalSeconds: Int
    let activeDays: Int
    let averagePerDaySeconds: Int
    let bestDay: DayStat?
}

struct TagStat: Identifiable {
    let tag: String
    let seconds: Int

    var id: String { tag }
}

enum FocusDateKey {
    static func key(for date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter.string(from: date)
    }

    static func date(from key: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter.date(from: key)
    }
}
