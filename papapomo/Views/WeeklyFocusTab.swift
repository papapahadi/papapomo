import SwiftUI
import Charts

struct WeeklyFocusTab: View {
    @ObservedObject var viewModel: PomodoroViewModel

    private let shortDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }()

    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter
    }()

    var body: some View {
        NavigationStack {
            ZStack {
                LuxuryTheme.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 14) {
                        summaryCard

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Last 7 Days Focus")
                                .font(.headline)
                                .foregroundStyle(LuxuryTheme.textPrimary)

                            Chart(viewModel.lastSevenDays) { day in
                                BarMark(
                                    x: .value("Day", shortDayFormatter.string(from: day.date)),
                                    y: .value("Hours", Double(day.seconds) / 3600.0)
                                )
                                .foregroundStyle(Color.white)
                                .cornerRadius(4)
                            }
                            .chartXAxis {
                                AxisMarks { value in
                                    AxisValueLabel()
                                        .foregroundStyle(LuxuryTheme.textSecondary)
                                }
                            }
                            .chartYAxis {
                                AxisMarks(position: .leading) { value in
                                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                        .foregroundStyle(Color.white.opacity(0.18))
                                    AxisValueLabel()
                                        .foregroundStyle(LuxuryTheme.textSecondary)
                                }
                            }
                            .frame(height: 220)

                            ForEach(viewModel.lastSevenDays) { day in
                                HStack {
                                    Text(dayFormatter.string(from: day.date))
                                        .foregroundStyle(LuxuryTheme.textPrimary)
                                    Spacer()
                                    Text(hoursAndMinutes(day.seconds))
                                        .foregroundStyle(LuxuryTheme.textSecondary)
                                }
                            }
                        }
                        .luxuryCard()

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Tag Stats (Last 7 Days)")
                                .font(.headline)
                                .foregroundStyle(LuxuryTheme.textPrimary)

                            if viewModel.tagStats.isEmpty {
                                Text("No focused time recorded yet")
                                    .foregroundStyle(LuxuryTheme.textSecondary)
                            } else {
                                Chart(viewModel.tagStats) { tag in
                                    BarMark(
                                        x: .value("Hours", Double(tag.seconds) / 3600.0),
                                        y: .value("Tag", tag.tag)
                                    )
                                    .foregroundStyle(Color.white)
                                    .cornerRadius(4)
                                }
                                .chartXAxis {
                                    AxisMarks { _ in
                                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                            .foregroundStyle(Color.white.opacity(0.18))
                                        AxisValueLabel()
                                            .foregroundStyle(LuxuryTheme.textSecondary)
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks { _ in
                                        AxisValueLabel()
                                            .foregroundStyle(LuxuryTheme.textSecondary)
                                    }
                                }
                                .frame(height: CGFloat(max(220, viewModel.tagStats.count * 42)))

                                ForEach(viewModel.tagStats) { tag in
                                    HStack {
                                        Text(tag.tag)
                                            .foregroundStyle(LuxuryTheme.textPrimary)
                                        Spacer()
                                        Text(hoursAndMinutes(tag.seconds))
                                            .foregroundStyle(LuxuryTheme.textSecondary)
                                    }
                                }
                            }
                        }
                        .luxuryCard()
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Focus Stats")
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("7-Day Summary")
                .font(.headline)
                .foregroundStyle(LuxuryTheme.textPrimary)

            Text(hoursAndMinutes(viewModel.lastSevenSummary.totalSeconds))
                .font(.title2.weight(.semibold))
                .foregroundStyle(LuxuryTheme.textPrimary)

            Text("Active days: \(viewModel.lastSevenSummary.activeDays) / 7")
                .foregroundStyle(LuxuryTheme.textSecondary)

            Text("Daily average: \(hoursAndMinutes(viewModel.lastSevenSummary.averagePerDaySeconds))")
                .foregroundStyle(LuxuryTheme.textSecondary)

            if let bestDay = viewModel.lastSevenSummary.bestDay {
                Text("Best day: \(dayFormatter.string(from: bestDay.date)) • \(hoursAndMinutes(bestDay.seconds))")
                    .foregroundStyle(LuxuryTheme.textSecondary)
            }
        }
        .luxuryCard()
    }

    private func hoursAndMinutes(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}
