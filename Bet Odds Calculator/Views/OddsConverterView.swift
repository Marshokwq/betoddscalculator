import SwiftUI

struct OddsConverterView: View {
    @State private var inputValue: String = ""
    @State private var inputType: OddsType = .decimal

    private var decimalOdds: Double {
        OddsConverter.stringToDecimal(inputValue, type: inputType) ?? 0
    }

    private var inputPlaceholder: String {
        switch inputType {
        case .decimal: return "e.g. 2.50"
        case .fractional: return "e.g. 3/2"
        case .american: return "e.g. +150 or -200"
        }
    }

    private var keyboardType: UIKeyboardType {
        inputType == .decimal ? .decimalPad : .default
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Input") {
                    Picker("Odds Type", selection: $inputType) {
                        ForEach(OddsType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .onChange(of: inputType) {
                        inputValue = ""
                    }

                    TextField(inputPlaceholder, text: $inputValue)
                        .keyboardType(keyboardType)
                        .autocorrectionDisabled()
                        .onChange(of: inputValue) {
                            let filtered = OddsConverter.filterInput(inputValue, type: inputType)
                            if filtered != inputValue { inputValue = filtered }
                        }
                }

                Section("Output Formats") {
                    if decimalOdds > 1 {
                        ConversionResultRow(title: "Decimal",
                                            value: String(format: "%.2f", decimalOdds))
                        ConversionResultRow(title: "Fractional",
                                            value: OddsConverter.decimalToFractional(decimalOdds))
                        ConversionResultRow(title: "American",
                                            value: OddsConverter.decimalToAmerican(decimalOdds))
                    } else if !inputValue.isEmpty {
                        Text("Enter a valid odds value")
                            .foregroundColor(.red)
                            .font(.subheadline)
                    } else {
                        Text("Enter an odds value above")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                }

                Section("Explanation") {
                    Text(explanation)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Odds Converter")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var explanation: String {
        switch inputType {
        case .decimal:
            return "Decimal odds represent the total return on a bet, including the stake. Example: 2.50 means a $10 bet returns $25."
        case .fractional:
            return "Fractional odds show the profit relative to the stake. Example: 3/2 means win $3 for every $2 wagered."
        case .american:
            return "American odds: positive (+150) shows profit on a $100 bet. Negative (-200) shows how much to bet to win $100."
        }
    }
}

struct ConversionResultRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
                .font(.subheadline)
        }
        .padding(8)
        .background(Color(.systemBlue).opacity(0.1))
        .cornerRadius(6)
    }
}

#Preview {
    OddsConverterView()
}
