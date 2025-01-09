import Foundation
import SwiftUI
import Combine
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
    
    // Nueva propiedad para los litros del depósito de combustible
    @AppStorage("fuelTankLiters") private var fuelTankLitersRaw: Double = 50.0
    @Published var fuelTankLiters: Double = 50.0 {
        didSet {
            fuelTankLitersRaw = fuelTankLiters
            updateFilteredGasolineras() // Actualizar filtros si es necesario
        }
    }
    
    @Published var gasolineras: [Gasolinera] = []
    @Published var filteredGasolineras: [Gasolinera] = []
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""
    
    // MARK: - Filtros y Ordenación
    @Published var sortOption: SortOption = .distance {
        didSet {
            updateFilteredGasolineras()
        }
    }
    
    @Published var radius: Double = 5.0 { // Radio en kilómetros
        didSet {
            updateFilteredGasolineras()
        }
    }
    
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
        self.fuelTankLiters = fuelTankLitersRaw
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
        
        if userLocation == nil {
            self.userLocation = loc.coordinate
            self.region = MKCoordinateRegion(
                center: loc.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
            self.loadGasolineras()
        } else {
            self.userLocation = loc.coordinate
            self.updateDistances() // Recalcular distancias para todas las gasolineras
            self.updateFilteredGasolineras() // Actualizar el filtrado basado en la nueva ubicación
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
                self.updateDistances() // Calcular distancias para todas las gasolineras
                self.updateFilteredGasolineras() // Filtrar según criterios
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func retryLoading() {
        errorMessage = nil
        isLoading = true
        loadGasolineras()
    }
    
    // MARK: - Filtros y Ordenación
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
        filtered = filtered.filter { gasolinera in
            gasolinera.price(for: selectedFuelType) != nil
        }
        
        // Filtro por radio
        if let _ = userLocation {
            let radiusInMeters = radius * 1000
            filtered = filtered.filter { gasolinera in
                if let distancia = gasolinera.distancia {
                    return distancia <= radiusInMeters
                }
                return false
            }
        }
        
        // Ordenación
        switch sortOption {
        case .distance:
            filtered.sort {
                ($0.distancia ?? .infinity) < ($1.distancia ?? .infinity)
            }
        case .price:
            filtered.sort { (a, b) -> Bool in
                let priceA = a.price(for: selectedFuelType) ?? Double.infinity
                let priceB = b.price(for: selectedFuelType) ?? Double.infinity
                
                if priceA != priceB {
                    return priceA < priceB
                } else {
                    // Si los precios son iguales, ordenar por distancia
                    let distanceA = a.distancia ?? Double.infinity
                    let distanceB = b.distancia ?? Double.infinity
                    return distanceA < distanceB
                }
            }
        }
        
        self.filteredGasolineras = filtered
    }
    
    /// Método para actualizar las distancias de todas las gasolineras
    func updateDistances() {
        guard let userLocation = userLocation else { return }
        let userCL = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        
        gasolineras = gasolineras.map { gasolinera in
            var updated = gasolinera
            if let lat = gasolinera.latitud, let lon = gasolinera.longitud {
                let stationCL = CLLocation(latitude: lat, longitude: lon)
                updated.distancia = userCL.distance(from: stationCL)
            } else {
                updated.distancia = nil
            }
            return updated
        }
    }
}
