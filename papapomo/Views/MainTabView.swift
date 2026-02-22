import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = PomodoroViewModel()

    var body: some View {
        TabView {
            HomeTab(viewModel: viewModel)
                .tabItem {
                    Label("Home", systemImage: "timer")
                }

            SettingsTab(viewModel: viewModel)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }

            WeeklyFocusTab(viewModel: viewModel)
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }
        }
        .tint(.white)
        .preferredColorScheme(.dark)
    }
}
