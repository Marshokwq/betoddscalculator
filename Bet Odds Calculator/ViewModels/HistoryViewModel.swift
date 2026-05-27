import Foundation

class HistoryViewModel: ObservableObject {
    @Published var records: [BetRecord] = []
    
    private let historyKey = "betHistory"
    
    init() {
        loadHistory()
    }
    
    func addRecord(_ record: BetRecord) {
        records.insert(record, at: 0)
        saveHistory()
    }
    
    func deleteRecord(at offsets: IndexSet) {
        records.remove(atOffsets: offsets)
        saveHistory()
    }
    
    func clearHistory() {
        records.removeAll()
        saveHistory()
    }
    
    var totalWins: Double {
        records.filter { $0.profit > 0 }.reduce(0) { $0 + $1.profit }
    }

    var totalLosses: Double {
        records.filter { $0.profit < 0 }.reduce(0) { $0 + $1.profit }
    }
    
    var winRate: Double {
        guard !records.isEmpty else { return 0 }
        let wins = records.filter { $0.profit > 0 }.count
        return Double(wins) / Double(records.count) * 100
    }
    
    var totalProfit: Double {
        records.reduce(0) { $0 + $1.profit }
    }
    
    var averageOdds: Double {
        guard !records.isEmpty else { return 0 }
        let sum = records.reduce(0.0) { sum, record in
            if let decimal = Double(record.odds) {
                return sum + decimal
            }
            return sum
        }
        return sum / Double(records.count)
    }
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: historyKey)
        }
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([BetRecord].self, from: data) {
            records = decoded
        }
    }
}
