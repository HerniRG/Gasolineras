import SwiftUI
import MapKit

@MainActor
final class GasolinerasViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // MARK: - Variables de Filtro/Estado
    @AppStorage("selectedFuelTypeRaw") private var selectedFuelTypeRaw: String = FuelType.gasolina95.rawValue
    @Published var selectedFuelType: FuelType = .gasolina95 {
        didSet {
            selectedFuelTypeRaw = selectedFuelType.rawValue
            updateFilteredGasolineras() // Actualizar filtros cuando cambia el tipo de combustible
        }
    }
    
    @Published var gasolineras: [Gasolinera] = []
    @Published var filteredGasolineras: [Gasolinera] = []
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""

    // MARK: - Ubicación
    @Published var region: MKCoordinateRegion
    @Published var userLocation: CLLocationCoordinate2D?

    // MARK: - Permisos de localización
    @Published var locationAuthorized: Bool = false
    @Published var locationDenied: Bool = false
    
    private let locationManager = CLLocationManager()
    
    // Configuración inicial para la región (p.ej. Madrid)
    override init() {
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
        super.init()
        setupLocationManager()
        self.selectedFuelType = FuelType(rawValue: selectedFuelTypeRaw) ?? .gasolina95
    }
    
    // MARK: - Configuración e inicialización del LocationManager
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        // No pedimos permisos aquí directamente si queremos hacerlo desde el Onboarding.
    }
    
    /// Comprueba y actualiza los flags `locationAuthorized` y `locationDenied`
    func checkAuthorizationStatus() {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationAuthorized = true
            locationDenied = false
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            locationAuthorized = false
            locationDenied = true
        case .notDetermined:
            // Todavía no ha dicho ni Sí ni No
            locationAuthorized = false
            locationDenied = false
        @unknown default:
            locationAuthorized = false
            locationDenied = false
        }
    }
    
    /// Solicita al usuario el permiso de localización
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Abre la app de Ajustes (para cuando el usuario ha denegado los permisos)
    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    /// Solicita actualizar la ubicación del usuario
    func requestLocationUpdate() {
        locationManager.requestLocation()
    }
    
    // MARK: - Delegados del LocationManager
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorizationStatus()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        
        // Si es la primera vez que tenemos la ubicación, actualizamos el mapa y cargamos datos
        if userLocation == nil {
            self.userLocation = loc.coordinate
            self.region = MKCoordinateRegion(
                center: loc.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
            loadGasolineras()
        } else {
            // Actualizamos la ubicación y los filtros
            self.userLocation = loc.coordinate
            updateFilteredGasolineras()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "Error al obtener la ubicación: \(error.localizedDescription)"
        isLoading = false
    }
    
    // MARK: - Carga de datos
    func loadGasolineras() {
        isLoading = true
        errorMessage = nil
        gasolineras = []
        filteredGasolineras = []
        
        Task {
            do {
                // Aquí llamas a tu servicio/API real:
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
    
    // MARK: - Filtros y ordenación
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
        
        // Calculamos distancia si hay userLocation
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
            // Orden por distancia ascendente
            filtered.sort { ($0.distancia ?? .infinity) < ($1.distancia ?? .infinity) }
        }
        
        self.filteredGasolineras = filtered
    }
}
