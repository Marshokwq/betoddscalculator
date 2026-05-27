import SwiftUI

struct BetCalculatorView: View {
    @State private var stake: String = ""
    @State private var odds: String = ""
    @State private var selectedOddsType: OddsType = .decimal
    @State private var showSavedAlert = false

    @ObservedObject var historyViewModel: HistoryViewModel
    @EnvironmentObject var settings: SettingsViewModel

    private var decimalOdds: Double {
        OddsConverter.stringToDecimal(odds, type: selectedOddsType) ?? 0
    }

    private var profit: Double {
        guard let stakeValue = Double(stake), stakeValue > 0, decimalOdds > 1 else { return 0 }
        return (stakeValue * decimalOdds) - stakeValue
    }

    private var totalReturn: Double {
        guard let stakeValue = Double(stake), stakeValue > 0, decimalOdds > 1 else { return 0 }
        return stakeValue * decimalOdds
    }

    private var isValidInput: Bool {
        guard let stakeValue = Double(stake), stakeValue > 0 else { return false }
        return decimalOdds > 1
    }

    private var oddsPlaceholder: String {
        switch selectedOddsType {
        case .decimal: return "e.g. 2.50"
        case .fractional: return "e.g. 3/2"
        case .american: return "e.g. +150 or -200"
        }
    }

    private var oddsKeyboardType: UIKeyboardType {
        selectedOddsType == .decimal ? .decimalPad : .default
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Bet Details") {
                    HStack {
                        Text(settings.currencySymbol)
                            .foregroundColor(.secondary)
                        TextField("Stake", text: $stake)
                            .keyboardType(.decimalPad)
                            .onChange(of: stake) {
                                let filtered = OddsConverter.filterInput(stake, type: .decimal)
                                if filtered != stake { stake = filtered }
                            }
                    }

                    Picker("Odds Type", selection: $selectedOddsType) {
                        ForEach(OddsType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }

                    TextField(oddsPlaceholder, text: $odds)
                        .keyboardType(oddsKeyboardType)
                        .autocorrectionDisabled()
                        .onChange(of: odds) {
                            let filtered = OddsConverter.filterInput(odds, type: selectedOddsType)
                            if filtered != odds { odds = filtered }
                        }
                }

                Section("Results") {
                    HStack {
                        Text("Total Return")
                        Spacer()
                        Text("\(settings.currencySymbol)\(String(format: "%.2f", totalReturn))")
                            .fontWeight(.semibold)
                    }

                    HStack {
                        Text("Profit")
                        Spacer()
                        Text("\(settings.currencySymbol)\(String(format: "%.2f", profit))")
                            .fontWeight(.semibold)
                            .foregroundColor(profit > 0 ? .green : profit < 0 ? .red : .secondary)
                    }
                }

                Section {
                    Button(action: saveBet) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Save Bet")
                        }
                    }
                    .disabled(!isValidInput)
                }
            }
            .navigationTitle("Bet Calculator")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                selectedOddsType = settings.defaultOddsType
            }
            .onChange(of: selectedOddsType) {
                odds = ""
            }
        }
    }

    private func saveBet() {
        let record = BetRecord(
            stake: Double(stake) ?? 0,
            odds: odds,
            oddsType: selectedOddsType.rawValue,
            profit: profit,
            totalReturn: totalReturn,
            date: Date()
        )
        historyViewModel.addRecord(record)
        stake = ""
        odds = ""
        showSavedAlert = true
    }
}

#Preview {
    BetCalculatorView(historyViewModel: HistoryViewModel())
        .environmentObject(SettingsViewModel())
}
