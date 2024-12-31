import Foundation

enum SortOption: String, CaseIterable, Identifiable {
    case distance = "Distancia"
    case price = "Precio"
    
    var id: String { self.rawValue }
}
