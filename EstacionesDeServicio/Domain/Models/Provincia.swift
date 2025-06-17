import Foundation

struct Provincia: Identifiable, Codable {
    let id: Int
    let nombre: String

    enum CodingKeys: String, CodingKey {
        case id = "IDProvincia"
        case nombre = "Provincia"
    }
}
