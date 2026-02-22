import SwiftUI

struct SettingsTab: View {
    @ObservedObject var viewModel: PomodoroViewModel
    @State private var newTag = ""

    var body: some View {
        NavigationStack {
            ZStack {
                LuxuryTheme.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 14) {
                        settingsCard
                        tagsCard
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Settings")
        }
    }

    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Durations (minutes)")
                .font(.headline)
                .foregroundStyle(LuxuryTheme.textPrimary)

            Stepper("Focus: \(viewModel.settings.workMinutes)", value: $viewModel.settings.workMinutes, in: 1...90)
            Stepper("Short Break: \(viewModel.settings.shortBreakMinutes)", value: $viewModel.settings.shortBreakMinutes, in: 1...45)
            Stepper("Long Break: \(viewModel.settings.longBreakMinutes)", value: $viewModel.settings.longBreakMinutes, in: 1...90)
            Stepper("Long break after \(viewModel.settings.sessionsBeforeLongBreak) focus sessions", value: $viewModel.settings.sessionsBeforeLongBreak, in: 2...8)
        }
        .foregroundStyle(LuxuryTheme.textSecondary)
        .luxuryCard()
    }

    private var tagsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tags")
                .font(.headline)
                .foregroundStyle(LuxuryTheme.textPrimary)

            HStack {
                TextField("Add new tag", text: $newTag)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .foregroundStyle(LuxuryTheme.textPrimary)

                Button("Add") {
                    viewModel.addTag(newTag)
                    newTag = ""
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.white)
                .foregroundStyle(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            ForEach(viewModel.tags, id: \.self) { tag in
                HStack {
                    Text(tag)
                        .foregroundStyle(LuxuryTheme.textPrimary)
                    Spacer()
                    if viewModel.selectedTag == tag {
                        Text("Selected")
                            .font(.caption)
                            .foregroundStyle(LuxuryTheme.textSecondary)
                    }
                    if viewModel.tags.count > 1 {
                        Button(role: .destructive) {
                            viewModel.removeTag(tag)
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
                Divider().overlay(Color.white.opacity(0.12))
            }
        }
        .luxuryCard()
    }
}
