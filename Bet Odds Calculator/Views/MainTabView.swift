import SwiftUI

struct MainTabView: View {
    @StateObject private var historyViewModel = HistoryViewModel()
    @StateObject private var settings = SettingsViewModel()

    var body: some View {
        TabView {
            BetCalculatorView(historyViewModel: historyViewModel)
                .tabItem {
                    Label("Calculator", systemImage: "plusminus.circle.fill")
                }

            MultiOddsView(historyViewModel: historyViewModel)
                .tabItem {
                    Label("Multi Bet", systemImage: "sum")
                }

            OddsConverterView()
                .tabItem {
                    Label("Converter", systemImage: "arrow.triangle.2.circlepath")
                }

            HistoryView(viewModel: historyViewModel)
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .environmentObject(settings)
        .preferredColorScheme(settings.isDarkMode ? .dark : .light)
    }
}

#Preview {
    MainTabView()
}
