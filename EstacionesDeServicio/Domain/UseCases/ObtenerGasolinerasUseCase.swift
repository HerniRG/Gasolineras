import Foundation

final class ObtenerGasolinerasUseCase {
    private let apiService: APIService

    init(apiService: APIService = APIService.shared) {
        self.apiService = apiService
    }

    func ejecutar() async throws -> [Gasolinera] {
        return try await apiService.fetchGasolineras()
    }
}
