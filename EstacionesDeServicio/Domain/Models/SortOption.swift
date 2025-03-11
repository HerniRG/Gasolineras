import Foundation

enum SortOption: String, CaseIterable, Identifiable {
    case price = "Precio"
    case distance = "Distancia"
    
    var id: String { self.rawValue }
}
