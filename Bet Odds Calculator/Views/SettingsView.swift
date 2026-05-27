import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsViewModel
    @State private var showResetConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Display") {
                    Picker("Default Odds Type", selection: $settings.defaultOddsType) {
                        ForEach(OddsType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }

                    Toggle("Dark Mode", isOn: $settings.isDarkMode)
                }

                Section("Preferences") {
                    Picker("Default Currency", selection: $settings.defaultCurrency) {
                        Text("USD ($)").tag("USD")
                        Text("EUR (€)").tag("EUR")
                        Text("GBP (£)").tag("GBP")
                        Text("AUD (A$)").tag("AUD")
                        Text("CAD (C$)").tag("CAD")
                    }
                }

                Section("Information") {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                }

                Section {
                    Button(role: .destructive, action: { showResetConfirmation = true }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Reset All Settings")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog("Reset Settings", isPresented: $showResetConfirmation) {
                Button("Reset", role: .destructive) {
                    settings.reset()
                }
            } message: {
                Text("Are you sure you want to reset all settings to default?")
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsViewModel())
}
