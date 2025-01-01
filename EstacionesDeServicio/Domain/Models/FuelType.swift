import Foundation

enum FuelType: String, CaseIterable, Identifiable {
    case gasolina95 = "Gasolina 95"
    case gasolina98 = "Gasolina 98"
    case gasoleoA = "Gasóleo A"
    case gasoleoPremium = "Gasóleo Premium"
    case glp = "GLP"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .gasolina95:
            return "Gasolina 95"
        case .gasolina98:
            return "Gasolina 98"
        case .gasoleoA:
            return "Gasóleo A"
        case .gasoleoPremium:
            return "Gasóleo Premium"
        case .glp:
            return "GLP"
        }
    }
}
