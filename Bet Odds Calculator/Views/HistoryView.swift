import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: HistoryViewModel
    @EnvironmentObject var settings: SettingsViewModel
    @State private var showClearConfirmation = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.records.isEmpty {
                    emptyState
                } else {
                    List {
                        statsSection
                        recordsSection
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !viewModel.records.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(role: .destructive) {
                            showClearConfirmation = true
                        } label: {
                            Image(systemName: "trash")
                        }
                        .tint(.red)
                    }
                }
            }
            .confirmationDialog("Clear History", isPresented: $showClearConfirmation) {
                Button("Clear All", role: .destructive) {
                    viewModel.clearHistory()
                }
            } message: {
                Text("Are you sure you want to delete all betting records?")
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No Bets Yet")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Your bet history will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var statsSection: some View {
        Section("Summary") {
            HStack {
                Text("Total Profit")
                Spacer()
                Text("\(settings.currencySymbol)\(String(format: "%.2f", viewModel.totalProfit))")
                    .fontWeight(.semibold)
                    .foregroundColor(viewModel.totalProfit > 0 ? .green : viewModel.totalProfit < 0 ? .red : .secondary)
            }
            HStack {
                Text("Win Rate")
                Spacer()
                Text(String(format: "%.1f%%", viewModel.winRate))
                    .fontWeight(.semibold)
            }
            HStack {
                Text("Total Bets")
                Spacer()
                Text("\(viewModel.records.count)")
                    .fontWeight(.semibold)
            }
        }
    }

    private var recordsSection: some View {
        Section("Bets") {
            ForEach(viewModel.records) { record in
                BetRecordRow(record: record, currencySymbol: settings.currencySymbol)
            }
            .onDelete { offsets in
                viewModel.deleteRecord(at: offsets)
            }
        }
    }
}

struct BetRecordRow: View {
    let record: BetRecord
    let currencySymbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Stake: \(currencySymbol)\(String(format: "%.2f", record.stake))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Odds: \(record.odds) (\(record.oddsType))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(record.profit >= 0 ? "+" : "")\(currencySymbol)\(String(format: "%.2f", record.profit))")
                        .fontWeight(.semibold)
                        .foregroundColor(record.profit > 0 ? .green : record.profit < 0 ? .red : .secondary)
                    Text(record.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            HStack {
                Text("Return: \(currencySymbol)\(String(format: "%.2f", record.totalReturn))")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HistoryView(viewModel: HistoryViewModel())
        .environmentObject(SettingsViewModel())
}
