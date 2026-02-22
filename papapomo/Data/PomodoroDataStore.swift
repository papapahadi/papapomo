import Foundation

protocol PomodoroDataStore {
    func loadSettings() -> PomodoroSettings
    func saveSettings(_ settings: PomodoroSettings)

    func loadTaggedDailyFocus() -> [String: [String: Int]]
    func saveTaggedDailyFocus(_ taggedDailyFocus: [String: [String: Int]])

    func loadTags() -> [String]
    func saveTags(_ tags: [String])

    func loadSelectedTag() -> String
    func saveSelectedTag(_ selectedTag: String)
}

final class UserDefaultsPomodoroDataStore: PomodoroDataStore {
    private let defaults: UserDefaults
    private let settingsKey = "pomodoro.settings.v1"
    private let taggedDailyFocusKey = "pomodoro.weekly.v1"
    private let tagsKey = "pomodoro.tags.v1"
    private let selectedTagKey = "pomodoro.selectedTag.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadSettings() -> PomodoroSettings {
        guard
            let data = defaults.data(forKey: settingsKey),
            let loaded = try? JSONDecoder().decode(PomodoroSettings.self, from: data)
        else {
            return PomodoroSettings()
        }
        return loaded
    }

    func saveSettings(_ settings: PomodoroSettings) {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        defaults.set(data, forKey: settingsKey)
    }

    func loadTaggedDailyFocus() -> [String: [String: Int]] {
        guard let data = defaults.data(forKey: taggedDailyFocusKey) else {
            return [:]
        }

        if let loaded = try? JSONDecoder().decode([String: [String: Int]].self, from: data) {
            return loaded
        }

        if let legacy = try? JSONDecoder().decode([String: Int].self, from: data) {
            return legacy.reduce(into: [:]) { result, pair in
                result[pair.key] = ["General": pair.value]
            }
        }

        return [:]
    }

    func saveTaggedDailyFocus(_ taggedDailyFocus: [String: [String: Int]]) {
        guard let data = try? JSONEncoder().encode(taggedDailyFocus) else { return }
        defaults.set(data, forKey: taggedDailyFocusKey)
    }

    func loadTags() -> [String] {
        guard
            let data = defaults.data(forKey: tagsKey),
            let loaded = try? JSONDecoder().decode([String].self, from: data)
        else {
            return []
        }
        return loaded
    }

    func saveTags(_ tags: [String]) {
        guard let data = try? JSONEncoder().encode(tags) else { return }
        defaults.set(data, forKey: tagsKey)
    }

    func loadSelectedTag() -> String {
        defaults.string(forKey: selectedTagKey) ?? "General"
    }

    func saveSelectedTag(_ selectedTag: String) {
        defaults.set(selectedTag, forKey: selectedTagKey)
    }
}
