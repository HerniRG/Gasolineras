import Foundation

final class APIService {
    static let shared = APIService()
    private init() {}

    private let baseURL = "https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes"

    func fetchGasolineras() async throws -> [Gasolinera] {
        let urlString = "\(baseURL)/EstacionesTerrestres/"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        // Verificar código de respuesta HTTP
        if let httpResponse = response as? HTTPURLResponse {
            guard (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }
        }

        // Decodificar JSON
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        let respuestaAPI = try decoder.decode(RespuestaAPI.self, from: data)
        return respuestaAPI.listaEESSPrecio
    }

    func fetchProvincias() async throws -> [Provincia] {
        let urlString = "\(baseURL)/Listados/Provincias/"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        let (data, response) = try await URLSession.shared.data(from: url)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) { throw URLError(.badServerResponse) }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        let result = try decoder.decode(ProvinciasResponse.self, from: data)
        return result.listaProvincias
    }

    func fetchMunicipios(idProvincia: Int) async throws -> [Municipio] {
        let urlString = "\(baseURL)/Listados/MunicipiosPorProvincia/\(idProvincia)"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        let (data, response) = try await URLSession.shared.data(from: url)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) { throw URLError(.badServerResponse) }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        let result = try decoder.decode(MunicipiosResponse.self, from: data)
        return result.listaMunicipios
    }

    func fetchProductos() async throws -> [Producto] {
        let urlString = "\(baseURL)/Listados/ProductosPetroliferos/"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        let (data, response) = try await URLSession.shared.data(from: url)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) { throw URLError(.badServerResponse) }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        let result = try decoder.decode(ProductosResponse.self, from: data)
        return result.listaProductos
    }

    func fetchGasolineras(municipioID: Int, productID: Int) async throws -> [Gasolinera] {
        let urlString = "\(baseURL)/EstacionesTerrestres/FiltroMunicipioProducto/\(municipioID)/\(productID)"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        let (data, response) = try await URLSession.shared.data(from: url)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) { throw URLError(.badServerResponse) }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        let respuestaAPI = try decoder.decode(RespuestaAPI.self, from: data)
        return respuestaAPI.listaEESSPrecio
    }
}

private struct ProvinciasResponse: Codable {
    let listaProvincias: [Provincia]

    enum CodingKeys: String, CodingKey {
        case listaProvincias = "ListaProvincias"
    }
}

private struct MunicipiosResponse: Codable {
    let listaMunicipios: [Municipio]

    enum CodingKeys: String, CodingKey {
        case listaMunicipios = "Municipios"
    }
}

private struct ProductosResponse: Codable {
    let listaProductos: [Producto]

    enum CodingKeys: String, CodingKey {
        case listaProductos = "ListaProductos"
    }
}
