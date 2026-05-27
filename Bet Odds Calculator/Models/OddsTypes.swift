import Foundation

enum OddsType: String, CaseIterable, Codable {
    case decimal = "Decimal"
    case fractional = "Fractional"
    case american = "American"
}

struct BetRecord: Identifiable, Codable {
    var id: UUID = UUID()
    let stake: Double
    let odds: String
    let oddsType: String
    let profit: Double
    let totalReturn: Double
    let date: Date
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct AppSettings: Codable {
    var defaultOddsType: OddsType = .decimal
    var defaultCurrency: String = "USD"
    var isDarkMode: Bool = false
    
    static func load() -> AppSettings {
        if let data = UserDefaults.standard.data(forKey: "appSettings"),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            return decoded
        }
        return AppSettings()
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: "appSettings")
        }
    }
}
