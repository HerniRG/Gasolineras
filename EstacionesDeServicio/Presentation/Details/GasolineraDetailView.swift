import SwiftUI
import MapKit

struct GasolineraDetailView: View {
    let gasolinera: Gasolinera
    @State private var detailRegion = MKCoordinateRegion()
    @EnvironmentObject var viewModel: GasolinerasViewModel
    
    // Variables de estado para el Confirmation Dialog
    @State private var isShowingNavigationOptions = false
    @State private var availableNavigationApps: [NavigationApp] = []
    
    enum NavigationApp: Identifiable {
        case appleMaps
        case googleMaps
        case waze
        
        var id: String {
            switch self {
            case .appleMaps:
                return "appleMaps"
            case .googleMaps:
                return "googleMaps"
            case .waze:
                return "waze"
            }
        }
        
        var displayName: String {
            switch self {
            case .appleMaps:
                return "Apple Maps"
            case .googleMaps:
                return "Google Maps"
            case .waze:
                return "Waze"
            }
        }
        
        var iconName: String {
            switch self {
            case .appleMaps:
                return "map.fill"
            case .googleMaps:
                return "g.circle.fill" // Asegúrate de tener un icono adecuado
            case .waze:
                return "wand.and.stars" // Asegúrate de tener un icono adecuado
            }
        }
        
        func open(coordinate: CLLocationCoordinate2D, name: String) {
            switch self {
            case .appleMaps:
                let placemark = MKPlacemark(coordinate: coordinate)
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = name
                mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
            case .googleMaps:
                if let url = URL(string: "comgooglemaps://?daddr=\(coordinate.latitude),\(coordinate.longitude)&directionsmode=driving") {
                    debugPrint("Abriendo Google Maps con URL: \(url)")
                    UIApplication.shared.open(url, options: [:]) { success in
                        if !success {
                            debugPrint("No se pudo abrir Google Maps. Intentando con Apple Maps como fallback.")
                            openAppleMaps(coordinate: coordinate, name: name)
                        }
                    }
                } else {
                    debugPrint("URL inválida para Google Maps. Abriendo Apple Maps como fallback.")
                    openAppleMaps(coordinate: coordinate, name: name)
                }
            case .waze:
                if let url = URL(string: "waze://?ll=\(coordinate.latitude),\(coordinate.longitude)&navigate=yes") {
                    debugPrint("Abriendo Waze con URL: \(url)")
                    UIApplication.shared.open(url, options: [:]) { success in
                        if !success {
                            debugPrint("No se pudo abrir Waze. Intentando con Apple Maps como fallback.")
                            openAppleMaps(coordinate: coordinate, name: name)
                        }
                    }
                } else {
                    debugPrint("URL inválida para Waze. Abriendo Apple Maps como fallback.")
                    openAppleMaps(coordinate: coordinate, name: name)
                }
            }
        }
        
        private func openAppleMaps(coordinate: CLLocationCoordinate2D, name: String) {
            let placemark = MKPlacemark(coordinate: coordinate)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = name
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                
                // Mapa con una anotación
                Map(coordinateRegion: $detailRegion, annotationItems: [gasolinera]) { item in
                    MapAnnotation(coordinate: item.coordinate) {
                        Image("gasolineraIcon")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                }
                .frame(height: 200)
                .cornerRadius(10)
                
                // Información básica
                Text(gasolinera.rotulo)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Distancia al usuario (si está disponible)
                if let distancia = gasolinera.distancia {
                    Text("A \(distancia / 1000, specifier: "%.2f") km")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                
                // Dirección
                VStack(alignment: .leading, spacing: 5) {
                    Text("Dirección")
                        .font(.headline)
                    Text("\(gasolinera.direccion), \(gasolinera.localidad), \(gasolinera.provincia)")
                }
                
                // Precios
                VStack(alignment: .leading, spacing: 16) {
                    Text("Precios")
                        .font(.headline)
                    
                    // Lista de precios con FuelPrice y cálculo de llenado
                    let availableFuels = FuelType.allCases.filter { gasolinera.price(for: $0) != nil }
                    
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(availableFuels.indices, id: \.self) { index in
                            let fuel = availableFuels[index]
                            if let precio = gasolinera.price(for: fuel) {
                                VStack(alignment: .leading, spacing: 8) {
                                    FuelPrice(fuelType: fuel, price: precio, isHorizontal: true)
                                        .frame(maxWidth: 250, alignment: .leading)

                                    Text("\(costoLlenado(precio), specifier: "%.2f") € / llenado (\(Int(viewModel.fuelTankLiters)) litros)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    let diferenciaPrecio = precio - viewModel.calcularPromedioEnRadio(fuelType: fuel)
                                    let esMasCaro = diferenciaPrecio >= 0
                                    let descripcion = esMasCaro ? "más caro" : "más barato"

                                    Text("\(abs(diferenciaPrecio), specifier: "%.3f") €/L \(descripcion) respecto a la media en \(Int(viewModel.radius)) km")
                                        .font(.caption)
                                        .foregroundColor(esMasCaro ? .red : .green)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }

                                // Agrega un divisor entre combustibles disponibles, excepto en el último
                                if index < availableFuels.count - 1 {
                                    Divider()
                                        .background(Color.gray.opacity(0.3))
                                        .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                }
                
                // Horario
                VStack(alignment: .leading, spacing: 8) {
                    Text("Horario")
                        .font(.headline)
                    
                    // Separamos el horario por ';' y mostramos cada parte en su propia línea
                    let horarioSegments = gasolinera.horario
                        .split(separator: ";")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    
                    ForEach(horarioSegments, id: \.self) { segmento in
                        Text(segmento)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Botón para abrir en Mapas
                Button(action: {
                    prepareNavigationOptions()
                    isShowingNavigationOptions = true
                }) {
                    Text("Cómo llegar")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .navigationTitle("Detalles")
        .onAppear {
            // Centrar en la gasolinera
            detailRegion = MKCoordinateRegion(
                center: gasolinera.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
        .confirmationDialog("Cómo llegar", isPresented: $isShowingNavigationOptions, titleVisibility: .visible) {
            ForEach(availableNavigationApps) { app in
                Button(action: {
                    app.open(coordinate: gasolinera.coordinate, name: gasolinera.rotulo)
                }) {
                    Label(app.displayName, systemImage: app.iconName)
                }
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("Elige la aplicación de mapas")
        }
    }
    
    // MARK: - Funciones Auxiliares
    
    /// Prepara la lista de aplicaciones de navegación disponibles
    private func prepareNavigationOptions() {
        var apps: [NavigationApp] = [.appleMaps]
        
        if canOpenGoogleMaps() {
            apps.append(.googleMaps)
        } else {
            debugPrint("Google Maps no está instalado.")
        }
        
        if canOpenWaze() {
            apps.append(.waze)
        } else {
            debugPrint("Waze no está instalado.")
        }
        
        availableNavigationApps = apps
    }
    
    /// Verifica si Google Maps está instalado
    private func canOpenGoogleMaps() -> Bool {
        guard let url = URL(string: "comgooglemaps://") else { return false }
        let canOpen = UIApplication.shared.canOpenURL(url)
        debugPrint("¿Puede abrir Google Maps? \(canOpen)")
        return canOpen
    }
    
    /// Verifica si Waze está instalado
    private func canOpenWaze() -> Bool {
        guard let url = URL(string: "waze://") else { return false }
        let canOpen = UIApplication.shared.canOpenURL(url)
        debugPrint("¿Puede abrir Waze? \(canOpen)")
        return canOpen
    }
    
    /// Calcula el costo de llenado dado un precio
    private func costoLlenado(_ precioPorLitro: Double) -> Double {
        return precioPorLitro * viewModel.fuelTankLiters
    }
}
