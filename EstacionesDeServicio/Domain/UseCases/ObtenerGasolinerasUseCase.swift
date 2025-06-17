import Foundation

final class ObtenerGasolinerasUseCase {
    private let apiService: APIService

    init(apiService: APIService = APIService.shared) {
        self.apiService = apiService
    }

    func ejecutar(municipioID: Int, productoID: Int) async throws -> [Gasolinera] {
        return try await apiService.fetchGasolineras(municipioID: municipioID, productID: productoID)
    }
}
