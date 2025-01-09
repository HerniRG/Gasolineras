import Foundation

enum FuelType: String, CaseIterable, Identifiable {
    case gasolina95 = "Gasolina 95"
    case gasolina98 = "Gasolina 98"
    case gasoleoA = "Gasóleo A"
    case gasoleoPremium = "Gasóleo Premium"
    case glp = "GLP"
    case gnc = "GNC"
    case gnl = "GNL" // Gas Natural Licuado
    case hidrogeno = "Hidrógeno"
    case bioetanol = "Bioetanol"
    case biodiesel = "Biodiesel"
    case esterMetilico = "Éster Metílico"
    
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
        case .gnc:
            return "GNC"
        case .gnl:
            return "GNL"
        case .hidrogeno:
            return "Hidrógeno"
        case .bioetanol:
            return "Bioetanol"
        case .biodiesel:
            return "Biodiesel"
        case .esterMetilico:
            return "Éster Metílico"
        }
    }
}
