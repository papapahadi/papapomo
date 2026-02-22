import Foundation

enum FocusStatsService {
    static func lastSevenDays(from taggedDailyFocusByDate: [String: [String: Int]], now: Date = Date(), calendar: Calendar = .current) -> [DayStat] {
        let today = calendar.startOfDay(for: now)

        var output: [DayStat] = []
        output.reserveCapacity(7)

        for offset in stride(from: 6, through: 0, by: -1) {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            let key = FocusDateKey.key(for: date)
            let seconds = taggedDailyFocusByDate[key, default: [:]].values.reduce(0, +)
            output.append(DayStat(date: date, seconds: seconds))
        }

        return output
    }

    static func lastSevenDaysSummary(from taggedDailyFocusByDate: [String: [String: Int]], now: Date = Date(), calendar: Calendar = .current) -> WeekSummary {
        let days = lastSevenDays(from: taggedDailyFocusByDate, now: now, calendar: calendar)
        let totalSeconds = days.reduce(0) { $0 + $1.seconds }
        let activeDays = days.filter { $0.seconds > 0 }.count
        let average = totalSeconds / 7
        let bestDay = days.max { $0.seconds < $1.seconds }
        return WeekSummary(totalSeconds: totalSeconds, activeDays: activeDays, averagePerDaySeconds: average, bestDay: bestDay)
    }

    static func tagTotalsForLastSevenDays(from taggedDailyFocusByDate: [String: [String: Int]], now: Date = Date(), calendar: Calendar = .current) -> [TagStat] {
        let days = lastSevenDays(from: taggedDailyFocusByDate, now: now, calendar: calendar)
        var totals: [String: Int] = [:]

        for day in days {
            let key = FocusDateKey.key(for: day.date)
            for (tag, seconds) in taggedDailyFocusByDate[key, default: [:]] {
                totals[tag, default: 0] += seconds
            }
        }

        return totals
            .map { TagStat(tag: $0.key, seconds: $0.value) }
            .sorted { lhs, rhs in
                if lhs.seconds == rhs.seconds { return lhs.tag < rhs.tag }
                return lhs.seconds > rhs.seconds
            }
    }

    static func pruneOlderThanOneYear(_ taggedDailyFocusByDate: [String: [String: Int]], now: Date = Date(), calendar: Calendar = .current) -> [String: [String: Int]] {
        guard let threshold = calendar.date(byAdding: .day, value: -365, to: now) else { return taggedDailyFocusByDate }

        return taggedDailyFocusByDate.filter { key, _ in
            guard let date = FocusDateKey.date(from: key) else { return false }
            return date >= threshold
        }
    }
}
