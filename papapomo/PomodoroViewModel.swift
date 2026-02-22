import SwiftUI
import Combine
import Foundation

final class PomodoroViewModel: ObservableObject {
    @Published var phase: PomodoroPhase = .work
    @Published var isRunning = false
    @Published var completedFocusSessions = 0
    @Published var timeRemaining: Int
    @Published var totalPhaseSeconds: Int

    @Published var settings: PomodoroSettings {
        didSet {
            dataStore.saveSettings(settings)
            applySettingsToCurrentPhaseIfIdle()
        }
    }

    @Published var tags: [String] {
        didSet {
            dataStore.saveTags(tags)
        }
    }

    @Published var selectedTag: String {
        didSet {
            dataStore.saveSelectedTag(selectedTag)
        }
    }
    @Published var currentQuote: String

    let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private let dataStore: PomodoroDataStore
    private var taggedDailyFocusByDate: [String: [String: Int]]
    private var quoteIndex: Int

    init(dataStore: PomodoroDataStore = UserDefaultsPomodoroDataStore()) {
        self.dataStore = dataStore

        let loadedSettings = dataStore.loadSettings()
        let workSeconds = loadedSettings.workMinutes * 60
        settings = loadedSettings
        timeRemaining = workSeconds
        totalPhaseSeconds = workSeconds
        quoteIndex = 0
        currentQuote = QuoteService.quote(at: 0)
        taggedDailyFocusByDate = dataStore.loadTaggedDailyFocus()

        let storedTags = dataStore.loadTags()
        let normalizedTags: [String]
        if storedTags.isEmpty {
            normalizedTags = ["General", "Physics", "Meditation"]
            dataStore.saveTags(normalizedTags)
        } else {
            normalizedTags = Self.normalizedTags(storedTags)
        }

        let storedSelected = dataStore.loadSelectedTag()
        let resolvedSelected = normalizedTags.contains(storedSelected) ? storedSelected : normalizedTags[0]

        tags = normalizedTags
        selectedTag = resolvedSelected
        dataStore.saveSelectedTag(selectedTag)
    }

    var progress: Double {
        guard totalPhaseSeconds > 0 else { return 0 }
        return 1 - (Double(timeRemaining) / Double(totalPhaseSeconds))
    }

    var timerColor: Color {
        .white
    }

    var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var lastSevenDays: [DayStat] {
        FocusStatsService.lastSevenDays(from: taggedDailyFocusByDate)
    }

    var lastSevenSummary: WeekSummary {
        FocusStatsService.lastSevenDaysSummary(from: taggedDailyFocusByDate)
    }

    var tagStats: [TagStat] {
        FocusStatsService.tagTotalsForLastSevenDays(from: taggedDailyFocusByDate)
    }

    func toggleRunning() {
        isRunning.toggle()
    }

    func handleTick() {
        guard isRunning else { return }

        if timeRemaining > 0 {
            timeRemaining -= 1
            if phase == .work {
                recordFocusSecond()
            }
        } else {
            advancePhase()
        }
    }

    func resetCurrentPhase() {
        isRunning = false
        timeRemaining = totalPhaseSeconds
    }

    func advancePhase() {
        isRunning = false

        if phase == .work {
            completedFocusSessions += 1
            rotateQuoteIfNeeded()
            if completedFocusSessions.isMultiple(of: settings.sessionsBeforeLongBreak) {
                phase = .longBreak
                totalPhaseSeconds = settings.longBreakMinutes * 60
            } else {
                phase = .shortBreak
                totalPhaseSeconds = settings.shortBreakMinutes * 60
            }
        } else {
            phase = .work
            totalPhaseSeconds = settings.workMinutes * 60
        }

        timeRemaining = totalPhaseSeconds
    }

    func addTag(_ rawTag: String) {
        let cleaned = rawTag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }

        let existing = Set(tags.map { $0.lowercased() })
        guard !existing.contains(cleaned.lowercased()) else { return }

        tags.append(cleaned)
        tags = Self.normalizedTags(tags)
    }

    func removeTag(_ tag: String) {
        guard tags.count > 1 else { return }
        guard let index = tags.firstIndex(of: tag) else { return }

        tags.remove(at: index)

        if selectedTag == tag {
            selectedTag = tags.first ?? "General"
        }
    }

    private func applySettingsToCurrentPhaseIfIdle() {
        guard !isRunning else { return }

        switch phase {
        case .work:
            totalPhaseSeconds = settings.workMinutes * 60
        case .shortBreak:
            totalPhaseSeconds = settings.shortBreakMinutes * 60
        case .longBreak:
            totalPhaseSeconds = settings.longBreakMinutes * 60
        }

        timeRemaining = totalPhaseSeconds
    }

    private func recordFocusSecond() {
        let todayKey = FocusDateKey.key(for: Date())
        var dayMap = taggedDailyFocusByDate[todayKey, default: [:]]
        dayMap[selectedTag, default: 0] += 1
        taggedDailyFocusByDate[todayKey] = dayMap

        taggedDailyFocusByDate = FocusStatsService.pruneOlderThanOneYear(taggedDailyFocusByDate)
        dataStore.saveTaggedDailyFocus(taggedDailyFocusByDate)
        objectWillChange.send()
    }

    private func rotateQuoteIfNeeded() {
        guard completedFocusSessions.isMultiple(of: 2) else { return }
        guard !QuoteService.quotes.isEmpty else { return }

        quoteIndex = (quoteIndex + 1) % QuoteService.quotes.count
        currentQuote = QuoteService.quote(at: quoteIndex)
    }

    private static func normalizedTags(_ input: [String]) -> [String] {
        var seen: Set<String> = []
        var output: [String] = []

        for tag in input {
            let cleaned = tag.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !cleaned.isEmpty else { continue }
            let key = cleaned.lowercased()
            guard !seen.contains(key) else { continue }
            seen.insert(key)
            output.append(cleaned)
        }

        if output.isEmpty {
            return ["General"]
        }

        if !output.contains(where: { $0.lowercased() == "general" }) {
            output.insert("General", at: 0)
        }

        return output
    }

}
