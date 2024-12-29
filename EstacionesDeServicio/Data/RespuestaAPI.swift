import Foundation

struct RespuestaAPI: Codable {
    let listaEESSPrecio: [Gasolinera]
    let nota: String?
    let fecha: String

    enum CodingKeys: String, CodingKey {
        case listaEESSPrecio = "ListaEESSPrecio"
        case nota = "Nota"
        case fecha = "Fecha"
    }
}
