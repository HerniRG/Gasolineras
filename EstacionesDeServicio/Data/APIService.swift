import Foundation

final class APIService {
    static let shared = APIService()
    private init() {}

    func fetchGasolineras() async throws -> [Gasolinera] {
        let urlString = "https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/EstacionesTerrestres/"
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
}
