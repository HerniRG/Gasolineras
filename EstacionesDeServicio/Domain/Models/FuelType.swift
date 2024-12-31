enum FuelType: String, CaseIterable, Identifiable {
    case gasolina95 = "Gasolina 95"
    case gasolina98 = "Gasolina 98"
    case gasoleoA = "Gasóleo A"
    case gasoleoPremium = "Gasóleo Premium"
    case glp = "GLP"
    
    var id: String { self.rawValue }
}
