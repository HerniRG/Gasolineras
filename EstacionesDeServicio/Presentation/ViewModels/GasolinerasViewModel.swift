import Foundation
import CoreLocation
import MapKit

enum FuelType: String, CaseIterable, Identifiable {
    case all = "Todos"
    case gasolina95 = "Gasolina 95"
    case gasolina98 = "Gasolina 98"
    case gasoleoA = "Gasóleo A"
    case glp = "GLP"
    
    var id: String { self.rawValue }
}

@MainActor
final class GasolinerasViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var gasolineras: [Gasolinera] = []
    @Published var filteredGasolineras: [Gasolinera] = []
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""
    @Published var region: MKCoordinateRegion
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var selectedFuelType: FuelType = .all
    
    private let locationManager = CLLocationManager()
    
    // Configuración inicial para región por defecto
    override init() {
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038), // Madrid como ejemplo
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02) // Zoom más cercano
        )
        super.init()
        setupLocationManager()
    }
    
    // Carga de datos
    func loadGasolineras() {
        isLoading = true
        errorMessage = nil
        gasolineras = []
        filteredGasolineras = []
        
        Task {
            do {
                let result = try await APIService.shared.fetchGasolineras()
                self.gasolineras = result
                updateFilteredGasolineras()
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    func retryLoading() {
        errorMessage = nil
        isLoading = true
        loadGasolineras()
    }
    
    // Filtros y ordenación
    func updateFilteredGasolineras() {
        var filtered = gasolineras
        
        // Filtro por texto
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.rotulo.lowercased().contains(searchText.lowercased()) ||
                $0.localidad.lowercased().contains(searchText.lowercased())
            }
        }
        
        // Filtro por tipo de combustible
        switch selectedFuelType {
        case .gasolina95:
            filtered = filtered.filter { $0.precioGasolina95 != nil }
        case .gasolina98:
            filtered = filtered.filter { $0.precioGasolina98 != nil }
        case .gasoleoA:
            filtered = filtered.filter { $0.precioGasoleoA != nil }
        case .glp:
            filtered = filtered.filter { $0.precioGLP != nil }
        default:
            break
        }
        
        // Distancia si hay ubicación del usuario
        if let userLocation = userLocation {
            let userCL = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
            filtered = filtered.map { gasolinera in
                var updated = gasolinera
                if let lat = gasolinera.latitud, let lon = gasolinera.longitud {
                    let stationLocation = CLLocation(latitude: lat, longitude: lon)
                    updated.distancia = userCL.distance(from: stationLocation)
                } else {
                    updated.distancia = nil
                }
                return updated
            }
            // Ordenar por distancia ascendente
            filtered.sort { ($0.distancia ?? .infinity) < ($1.distancia ?? .infinity) }
        }
        
        self.filteredGasolineras = filtered
    }
    
    // MARK: - Location Manager
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        
        if userLocation == nil {
            // Es la primera vez que obtenemos la ubicación
            self.userLocation = loc.coordinate
            self.region = MKCoordinateRegion(
                center: loc.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
            loadGasolineras()  // Cargamos las gasolineras cuando tenemos ubicación
        } else {
            self.userLocation = loc.coordinate
            updateFilteredGasolineras()  // Solo recalcula los filtros
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "Error al obtener la ubicación: \(error.localizedDescription)"
        isLoading = false
    }
    
    func requestLocationUpdate() {
        locationManager.requestLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            errorMessage = "La aplicación necesita acceso a tu ubicación para mostrar las gasolineras cercanas."
            isLoading = false
        default:
            break
        }
    }
}
