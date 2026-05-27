import Foundation

class MultiOddsViewModel: ObservableObject {
    @Published var selectedOdds: [Double] = []
    @Published var stake: Double = 0
    @Published var oddsList: String = ""
    
    var totalOdds: Double {
        guard !selectedOdds.isEmpty else { return 0 }
        return selectedOdds.reduce(1, *)
    }
    
    var potentialReturn: Double {
        stake * totalOdds
    }
    
    var potentialProfit: Double {
        (stake * totalOdds) - stake
    }
    
    func addOdd(_ odd: String) {
        if let doubleOdd = Double(odd), doubleOdd > 1 {
            selectedOdds.append(doubleOdd)
            oddsList = selectedOdds.map { String(format: "%.2f", $0) }.joined(separator: ", ")
        }
    }
    
    func removeOdd(at index: Int) {
        guard index >= 0 && index < selectedOdds.count else { return }
        selectedOdds.remove(at: index)
        oddsList = selectedOdds.map { String(format: "%.2f", $0) }.joined(separator: ", ")
    }
    
    func clearOdds() {
        selectedOdds.removeAll()
        oddsList = ""
    }
    
    func parseOddsFromText(_ text: String) {
        let odds = text
            .split(separator: ",")
            .compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
            .filter { $0 > 1 }
        
        selectedOdds = odds
        oddsList = selectedOdds.map { String(format: "%.2f", $0) }.joined(separator: ", ")
    }
    
    func createBetRecord() -> BetRecord? {
        guard stake > 0 && !selectedOdds.isEmpty else { return nil }
        
        let oddString = selectedOdds.map { String(format: "%.2f", $0) }.joined(separator: " × ")
        
        return BetRecord(
            stake: stake,
            odds: oddString,
            oddsType: "Decimal",
            profit: potentialProfit,
            totalReturn: potentialReturn,
            date: Date()
        )
    }
}
