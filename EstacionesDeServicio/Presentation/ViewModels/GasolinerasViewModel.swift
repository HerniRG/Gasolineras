import Foundation
import SwiftUI
import Combine
import MapKit

@MainActor
final class GasolinerasViewModel: NSObject, ObservableObject, @preconcurrency CLLocationManagerDelegate {
    // MARK: - Variables de Filtro/Estado
    @AppStorage("selectedFuelTypeRaw") private var selectedFuelTypeRaw: String = FuelType.gasolina95.rawValue
    @Published var selectedFuelType: FuelType = .gasolina95 {
        didSet {
            selectedFuelTypeRaw = selectedFuelType.rawValue
            updateFilteredGasolineras()
        }
    }
    
    @AppStorage("fuelTankLiters") private var fuelTankLitersRaw: Double = 50.0
    @Published var fuelTankLiters: Double = 50.0 {
        didSet {
            fuelTankLitersRaw = fuelTankLiters
            updateFilteredGasolineras()
        }
    }
    
    @Published var gasolineras: [Gasolinera] = []
    @Published var filteredGasolineras: [Gasolinera] = []
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""
    // Propiedades para la búsqueda global
    @Published var globalSearchResults: [Gasolinera] = []
    
    @Published var currentCheapestIndex = 0
    @Published var retryCount: Int = 0
    private let maxRetries: Int = 3
    
    @Published var sortOption: SortOption = .price {
        didSet {
            updateFilteredGasolineras()
        }
    }
    
    @Published var radius: Double = 5.0 {
        didSet {
            updateFilteredGasolineras()
        }
    }
    
    @Published var region: MKCoordinateRegion
    @Published var userLocation: CLLocationCoordinate2D?
    
    @Published var locationAuthorized: Bool = false
    @Published var locationDenied: Bool = false
    
    private let locationManager = CLLocationManager()
    
    @Published var minPrice: Double? = nil
    @Published var cheapestGasolineras: [Gasolinera] = []
    
    @Published var showNotification: Bool = false
    @Published var notificationText: String = ""
    
    override init() {
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
        super.init()
        setupLocationManager()
        self.selectedFuelType = FuelType(rawValue: selectedFuelTypeRaw) ?? .gasolina95
        self.fuelTankLiters = fuelTankLitersRaw
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }

    @objc private func appDidBecomeActive() {
        if locationAuthorized {
            locationManager.startUpdatingLocation()
        }
    }

    @objc private func appWillResignActive() {
        locationManager.stopUpdatingLocation()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
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
            locationAuthorized = false
            locationDenied = false
        @unknown default:
            locationAuthorized = false
            locationDenied = false
        }
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func requestLocationUpdate() {
        locationManager.requestLocation()
    }
    
    // MARK: - Delegados del LocationManager
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorizationStatus()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        
        self.retryCount = 0
        DispatchQueue.main.async {
            if self.userLocation == nil {
                self.userLocation = loc.coordinate
                self.region = MKCoordinateRegion(
                    center: loc.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                )
                self.loadGasolineras()
            } else {
                self.userLocation = loc.coordinate
                self.updateDistances()
                self.updateFilteredGasolineras()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                self.errorMessage = "Permisos de localización denegados. Actívalos en Ajustes."
                self.isLoading = false
            default:
                if retryCount < maxRetries {
                    retryCount += 1
                    Task {
                        try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
                        self.locationManager.startUpdatingLocation()
                    }
                } else {
                    self.errorMessage = "No se pudo obtener la ubicación después de varios intentos."
                    self.isLoading = false
                }
            }
        } else {
            self.errorMessage = "Error al obtener la ubicación: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    // MARK: - Carga de datos
    func loadGasolineras() {
        Task {
            do {
                if let lastUpdated = try SwiftDataManager.shared.getLastUpdatedDate(),
                   Calendar.current.isDateInToday(lastUpdated) {
                    let cachedGasolineras = try SwiftDataManager.shared.fetchGasolineras()
                    self.gasolineras = cachedGasolineras
                    self.updateDistances()
                    self.updateFilteredGasolineras()
                    self.isLoading = false
                } else {
                    try await fetchFromAPI()
                }
            } catch {
                debugPrint("Error al acceder a la base de datos: \(error.localizedDescription)")
                try? await fetchFromAPI()
            }
        }
    }
    
    func retryLoading() {
        errorMessage = nil
        isLoading = true
        loadGasolineras()
    }
    
    private func fetchFromAPI() async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await APIService.shared.fetchGasolineras()
            self.gasolineras = result
            self.updateDistances()
            self.updateFilteredGasolineras()
            isLoading = false
            
            try await SwiftDataManager.shared.saveGasolineras(result)
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
    
    // MARK: - Filtros y Ordenación
    func updateFilteredGasolineras() {
        var filtered = gasolineras
        
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.rotulo.lowercased().contains(searchText.lowercased()) ||
                $0.localidad.lowercased().contains(searchText.lowercased())
            }
        }
        
        filtered = filtered.filter { gasolinera in
            gasolinera.price(for: selectedFuelType) != nil
        }
        
        if let _ = userLocation {
            let radiusInMeters = radius * 1000
            filtered = filtered.filter { gasolinera in
                if let distancia = gasolinera.distancia {
                    return distancia <= radiusInMeters
                }
                return false
            }
        }
        
        switch sortOption {
        case .price:
            filtered.sort { (a, b) -> Bool in
                let priceA = a.price(for: selectedFuelType) ?? Double.infinity
                let priceB = b.price(for: selectedFuelType) ?? Double.infinity
                
                if priceA != priceB {
                    return priceA < priceB
                } else {
                    let distanceA = a.distancia ?? Double.infinity
                    let distanceB = b.distancia ?? Double.infinity
                    return distanceA < distanceB
                }
            }
        case .distance:
            filtered.sort {
                ($0.distancia ?? .infinity) < ($1.distancia ?? .infinity)
            }
        }
        
        self.filteredGasolineras = filtered
        
        if let min = filtered.compactMap({ $0.price(for: selectedFuelType) }).min() {
            minPrice = min
        } else {
            minPrice = nil
        }
        
        identifyCheapestGasolinera()
    }
    
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
    
    private func identifyCheapestGasolinera() {
        let gasolinerasEnRadio = filteredGasolineras.filter { gasolinera in
            if let distancia = gasolinera.distancia {
                return distancia <= radius * 1000
            }
            return false
        }
        
        if let minPrice = gasolinerasEnRadio.compactMap({ $0.price(for: selectedFuelType) }).min() {
            self.cheapestGasolineras = gasolinerasEnRadio.filter { $0.price(for: selectedFuelType) == minPrice }
        } else {
            self.cheapestGasolineras = []
        }
    }
    
    func cycleCheapestGasolinera() -> (Gasolinera, Int)? {
        guard !cheapestGasolineras.isEmpty else { return nil }
        
        let gasolinera = cheapestGasolineras[currentCheapestIndex]
        let displayIndex = currentCheapestIndex + 1  // Índice 1-based para la notificación
        
        currentCheapestIndex = (currentCheapestIndex + 1) % cheapestGasolineras.count
        
        return (gasolinera, displayIndex)
    }
    
    func calcularPromedioEnRadio(fuelType: FuelType? = nil) -> Double {
        let tipoCombustible = fuelType ?? selectedFuelType
        let precios = filteredGasolineras.compactMap { $0.price(for: tipoCombustible) }

        guard !precios.isEmpty else { return 0.0 }
        return precios.reduce(0.0, +) / Double(precios.count)
    }
    
    func updateCheapestGasolineraManually() {
        identifyCheapestGasolinera()
    }
    
    // MARK: - Función para realizar la búsqueda global
    // MARK: - Función para realizar la búsqueda global
    func performGlobalSearch(query: String) {
        if query.isEmpty {
            globalSearchResults = []
            return
        }
        
        // Filtrar gasolineras que contienen el término de búsqueda en rotulo, localidad, provincia o direccion
        let lowercasedQuery = query.lowercased()
        var filtered = gasolineras.filter { gasolinera in
            return gasolinera.rotulo.lowercased().contains(lowercasedQuery) ||
                   gasolinera.localidad.lowercased().contains(lowercasedQuery) ||
                   gasolinera.provincia.lowercased().contains(lowercasedQuery) ||
                   gasolinera.direccion.lowercased().contains(lowercasedQuery)
        }
        
        // Ordenar las gasolineras filtradas por distancia (más cercana primero)
        filtered.sort { a, b in
            if let aDistance = a.distancia, let bDistance = b.distancia {
                return aDistance < bDistance
            } else if a.distancia != nil {
                return true // Si solo a tiene distancia, va primero
            } else {
                return false // Si solo b tiene distancia o ninguna, b va primero
            }
        }
        
        // Asignar los resultados ordenados a globalSearchResults
        globalSearchResults = filtered
    }

    
    // MARK: - Funciones de Centrado
    func centerOnUserLocation() {
        guard let currentLocation = userLocation else {
            debugPrint("Error: No se pudo obtener la ubicación actual del usuario.")
            return
        }
        
        let currentDelta = region.span.latitudeDelta
        
        DispatchQueue.main.async {
            if currentDelta > 5.0 {
                // Actualización inmediata sin animación
                self.region = MKCoordinateRegion(
                    center: currentLocation,
                    span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
                )
                // Programamos la animación unos décimas de segundo después
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        self.region = MKCoordinateRegion(
                            center: currentLocation,
                            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                        )
                    }
                }
            } else {
                withAnimation {
                    self.region = MKCoordinateRegion(
                        center: currentLocation,
                        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                    )
                }
            }
        }
    }
    
    func centerMapOnCheapestGasolineras() {
        guard let (cheapestGas, displayIndex) = cycleCheapestGasolinera() else { return }
        
        let newRegion = MKCoordinateRegion(
            center: cheapestGas.coordinate,
            span: MKCoordinateSpan(
                latitudeDelta: region.span.latitudeDelta,
                longitudeDelta: region.span.longitudeDelta
            )
        )
        
        Task {
            // Posponer las actualizaciones hasta la siguiente iteración
            await Task.yield()
            await MainActor.run {
                withAnimation {
                    self.region = newRegion
                    if self.cheapestGasolineras.count > 1 {
                        self.notificationText = "Gasolinera con el precio más bajo centrada (\(displayIndex) de \(self.cheapestGasolineras.count))"
                    } else {
                        self.notificationText = "Gasolinera con el precio más bajo centrada"
                    }
                    self.showNotification = true
                }
            }
            
            // Oculta la notificación a los 3 segundos
            try await Task.sleep(nanoseconds: 3 * 1_000_000_000)
            await MainActor.run {
                withAnimation {
                    self.showNotification = false
                }
            }
        }
    }
}
