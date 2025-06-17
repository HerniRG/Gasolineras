import Foundation

struct Municipio: Identifiable, Codable {
    let id: Int
    let nombre: String

    enum CodingKeys: String, CodingKey {
        case id = "IDMunicipio"
        case nombre = "Municipio"
    }
}
