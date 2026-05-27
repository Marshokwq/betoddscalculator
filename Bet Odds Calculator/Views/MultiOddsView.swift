import SwiftUI

struct MultiOddsView: View {
    @StateObject private var viewModel = MultiOddsViewModel()
    @State private var stakeText: String = ""
    @State private var newOdd: String = ""
    @State private var selectedOddsType: OddsType = .decimal

    @ObservedObject var historyViewModel: HistoryViewModel
    @EnvironmentObject var settings: SettingsViewModel

    private var oddsPlaceholder: String {
        switch selectedOddsType {
        case .decimal: return "e.g. 2.50"
        case .fractional: return "e.g. 3/2"
        case .american: return "e.g. +150"
        }
    }

    private var oddsKeyboardType: UIKeyboardType {
        selectedOddsType == .decimal ? .decimalPad : .default
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Stake") {
                    HStack {
                        Text(settings.currencySymbol)
                            .foregroundColor(.secondary)
                        TextField("Stake Amount", text: $stakeText)
                            .keyboardType(.decimalPad)
                            .onChange(of: stakeText) {
                                let filtered = OddsConverter.filterInput(stakeText, type: .decimal)
                                if filtered != stakeText { stakeText = filtered }
                                viewModel.stake = Double(stakeText) ?? 0
                            }
                    }
                }

                Section("Add Odds") {
                    Picker("Odds Type", selection: $selectedOddsType) {
                        ForEach(OddsType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .onChange(of: selectedOddsType) { _ in newOdd = "" }

                    HStack {
                        TextField(oddsPlaceholder, text: $newOdd)
                            .keyboardType(oddsKeyboardType)
                            .autocorrectionDisabled()
                            .onChange(of: newOdd) {
                                let filtered = OddsConverter.filterInput(newOdd, type: selectedOddsType)
                                if filtered != newOdd { newOdd = filtered }
                            }

                        Button(action: addOdd) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                        .disabled(newOdd.isEmpty)
                    }
                }

                if !viewModel.selectedOdds.isEmpty {
                    Section("Selected Odds (\(viewModel.selectedOdds.count))") {
                        ForEach(Array(viewModel.selectedOdds.enumerated()), id: \.offset) { index, odd in
                            HStack {
                                Text(String(format: "%.2f", odd))
                                Spacer()
                                Button(action: { viewModel.removeOdd(at: index) }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }

                        Button(role: .destructive) {
                            viewModel.clearOdds()
                        } label: {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("Clear All")
                            }
                        }
                    }
                }

                Section("Accumulator Results") {
                    HStack {
                        Text("Total Odds")
                        Spacer()
                        Text(viewModel.selectedOdds.isEmpty ? "—" : String(format: "%.2f", viewModel.totalOdds))
                            .fontWeight(.semibold)
                    }

                    HStack {
                        Text("Potential Return")
                        Spacer()
                        Text("\(settings.currencySymbol)\(String(format: "%.2f", viewModel.potentialReturn))")
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }

                    HStack {
                        Text("Potential Profit")
                        Spacer()
                        Text("\(settings.currencySymbol)\(String(format: "%.2f", viewModel.potentialProfit))")
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                }

                Section {
                    Button(action: saveBet) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Save Multi Bet")
                        }
                    }
                    .disabled(viewModel.stake <= 0 || viewModel.selectedOdds.isEmpty)
                }
            }
            .navigationTitle("Multi Bet")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func addOdd() {
        guard let decimal = OddsConverter.stringToDecimal(newOdd, type: selectedOddsType),
              decimal > 1 else { return }
        viewModel.selectedOdds.append(decimal)
        newOdd = ""
    }

    private func saveBet() {
        if let record = viewModel.createBetRecord() {
            historyViewModel.addRecord(record)
            viewModel.stake = 0
            stakeText = ""
            viewModel.clearOdds()
            newOdd = ""
        }
    }
}

#Preview {
    MultiOddsView(historyViewModel: HistoryViewModel())
        .environmentObject(SettingsViewModel())
}
