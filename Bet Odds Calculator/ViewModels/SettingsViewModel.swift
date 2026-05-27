import Foundation

class SettingsViewModel: ObservableObject {
    @Published var defaultOddsType: OddsType {
        didSet { save() }
    }
    @Published var defaultCurrency: String {
        didSet { save() }
    }
    @Published var isDarkMode: Bool {
        didSet { save() }
    }

    init() {
        let loaded = AppSettings.load()
        defaultOddsType = loaded.defaultOddsType
        defaultCurrency = loaded.defaultCurrency
        isDarkMode = loaded.isDarkMode
    }

    func reset() {
        let defaults = AppSettings()
        defaultOddsType = defaults.defaultOddsType
        defaultCurrency = defaults.defaultCurrency
        isDarkMode = defaults.isDarkMode
    }

    var currencySymbol: String {
        switch defaultCurrency {
        case "USD": return "$"
        case "EUR": return "€"
        case "GBP": return "£"
        case "AUD": return "A$"
        case "CAD": return "C$"
        default: return "$"
        }
    }

    private func save() {
        AppSettings(defaultOddsType: defaultOddsType,
                    defaultCurrency: defaultCurrency,
                    isDarkMode: isDarkMode).save()
    }
}
