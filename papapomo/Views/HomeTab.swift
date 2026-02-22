import SwiftUI

struct HomeTab: View {
    @ObservedObject var viewModel: PomodoroViewModel

    var body: some View {
        ZStack {
            LuxuryTheme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    VStack(spacing: 8) {
                        Text(viewModel.phase.rawValue)
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(LuxuryTheme.textPrimary)

                        Text("Completed Focus Sessions: \(viewModel.completedFocusSessions)")
                            .font(.subheadline)
                            .foregroundStyle(LuxuryTheme.textSecondary)
                    }
                    .luxuryCard()

                    tagSelector
                        .luxuryCard()

                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 18)

                        Circle()
                            .trim(from: 0, to: viewModel.progress)
                            .stroke(
                                Color.white,
                                style: StrokeStyle(lineWidth: 18, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 0.35), value: viewModel.progress)

                        Text(viewModel.formattedTime)
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(LuxuryTheme.textPrimary)
                    }
                    .frame(width: 265, height: 265)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .luxuryCard()

                    HStack(spacing: 12) {
                        controlButton(title: viewModel.isRunning ? "Pause" : "Start", filled: true) {
                            viewModel.toggleRunning()
                        }

                        controlButton(title: "Reset") {
                            viewModel.resetCurrentPhase()
                        }

                        controlButton(title: "Skip") {
                            viewModel.advancePhase()
                        }
                    }

                    VStack(spacing: 10) {
                        Text("\"\(viewModel.currentQuote)\"")
                            .font(.callout.italic())
                            .foregroundStyle(LuxuryTheme.textPrimary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .luxuryCard()
                }
                .padding(16)
            }
        }
        .onReceive(viewModel.ticker) { _ in
            viewModel.handleTick()
        }
    }

    private var tagSelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Session Tag")
                .font(.caption.weight(.semibold))
                .foregroundStyle(LuxuryTheme.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.tags, id: \.self) { tag in
                        Button(tag) {
                            viewModel.selectedTag = tag
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 999)
                                .fill(viewModel.selectedTag == tag ? Color.white : Color.white.opacity(0.08))
                        )
                        .foregroundStyle(viewModel.selectedTag == tag ? Color.black : Color.white)
                    }
                }
            }
        }
    }

    private func controlButton(title: String, filled: Bool = false, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(filled ? Color.white : Color.white.opacity(0.08))
            .foregroundStyle(filled ? Color.black : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
}
