import Foundation

enum SortOption: String, CaseIterable, Identifiable {
    case distance = "Distancia"
    case price = "Precio"
    case intelligent = "Inteligente"
    
    var id: String { self.rawValue }
}
