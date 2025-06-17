import Foundation

struct Producto: Identifiable, Codable {
    let id: Int
    let nombre: String

    enum CodingKeys: String, CodingKey {
        case id = "IDProducto"
        case nombre = "Producto"
    }
}
