import Foundation

class OddsConverter {
    static func decimalToFractional(_ decimal: Double) -> String {
        if let fractional = approximateFraction(decimal - 1) {
            return "\(fractional.0)/\(fractional.1)"
        }
        return "1/1"
    }

    static func decimalToAmerican(_ decimal: Double) -> String {
        if decimal >= 2.0 {
            let american = Int((decimal - 1) * 100)
            return "+\(american)"
        } else if decimal > 1.0 {
            let american = Int(-100 / (decimal - 1))
            return "\(american)"
        }
        return "+100"
    }

    static func fractionalFormatToDecimal(_ fractional: String) -> Double? {
        let components = fractional.split(separator: "/").map(String.init)
        guard components.count == 2,
              let num = Double(components[0]),
              let den = Double(components[1]),
              den != 0 else {
            return nil
        }
        return (num / den) + 1
    }

    static func americanToDecimal(_ american: String) -> Double? {
        guard let value = Double(american) else { return nil }
        if value > 0 {
            return (value / 100) + 1
        } else if value < 0 {
            return (100 / abs(value)) + 1
        }
        return nil
    }

    static func stringToDecimal(_ value: String, type: OddsType) -> Double? {
        switch type {
        case .decimal:
            return Double(value)
        case .fractional:
            return fractionalFormatToDecimal(value)
        case .american:
            return americanToDecimal(value)
        }
    }

    static func filterInput(_ input: String, type: OddsType) -> String {
        switch type {
        case .decimal:
            var dotSeen = false
            return String(input.filter { char in
                if char == "." {
                    guard !dotSeen else { return false }
                    dotSeen = true
                    return true
                }
                return char.isNumber
            })
        case .fractional:
            var slashSeen = false
            return String(input.filter { char in
                if char == "/" {
                    guard !slashSeen else { return false }
                    slashSeen = true
                    return true
                }
                return char.isNumber
            })
        case .american:
            var result = ""
            for char in input {
                if char.isNumber {
                    result.append(char)
                } else if (char == "+" || char == "-") && result.isEmpty {
                    result.append(char)
                }
            }
            return result
        }
    }

    private static func approximateFraction(_ decimal: Double) -> (Int, Int)? {
        let maxDenominator = 100
        for denominator in 1...maxDenominator {
            let numerator = Int(round(decimal * Double(denominator)))
            if abs(Double(numerator) / Double(denominator) - decimal) < 0.01 {
                return (numerator, denominator)
            }
        }
        return nil
    }
}
