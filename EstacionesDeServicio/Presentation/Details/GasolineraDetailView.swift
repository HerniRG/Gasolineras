import SwiftUI
import MapKit

struct GasolineraDetailView: View {
    let gasolinera: Gasolinera
    @State private var detailRegion = MKCoordinateRegion()
    @EnvironmentObject var viewModel: GasolinerasViewModel
        
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
                
                // Distancia al usuario
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
                VStack(alignment: .leading, spacing: 10) {
                    Text("Precios")
                        .font(.headline)
                    
                    // Lista de precios con FuelPrice y cálculo de llenado
                    VStack(spacing: 15) {
                        ForEach(FuelType.allCases) { fuel in
                            if let precio = gasolinera.price(for: fuel) {
                                HStack {
                                    FuelPrice(fuelType: fuel, price: precio, isHorizontal: true)
                                    Text("\(costoLlenado(precio), specifier: "%.2f") € / llenado (\(Int(viewModel.fuelTankLiters)) l)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                
                // Horario
                VStack(alignment: .leading, spacing: 5) {
                    Text("Horario")
                        .font(.headline)
                    Text(gasolinera.horario)
                    
                    // Indicador de disponibilidad
                    if isOpenNow(horario: gasolinera.horario) {
                        Text("¡Abierta ahora!")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Text("Cerrada ahora")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                Spacer()
                
                // Botón para abrir en Mapas
                Button(action: openInMaps) {
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
    }
    
    private func openInMaps() {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: gasolinera.coordinate))
        mapItem.name = gasolinera.rotulo
        mapItem.openInMaps()
    }
    
    private func costoLlenado(_ precioPorLitro: Double) -> Double {
        return precioPorLitro * viewModel.fuelTankLiters
    }
    
    private func isOpenNow(horario: String) -> Bool {
        // Lógica simplificada para analizar si está abierta
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: now)
        let currentMinutes = (components.hour ?? 0) * 60 + (components.minute ?? 0)
        
        // Horario formato "L-D: 07:00-22:00" o "24H"
        if horario.contains("24H") {
            return true
        }
        
        if let range = horario.range(of: #"(\d{2}:\d{2})-(\d{2}:\d{2})"#, options: .regularExpression) {
            let hours = horario[range].split(separator: "-")
            if let start = hours.first, let end = hours.last {
                let startMinutes = timeStringToMinutes(String(start))
                let endMinutes = timeStringToMinutes(String(end))
                return currentMinutes >= startMinutes && currentMinutes <= endMinutes
            }
        }
        
        return false
    }
    
    private func timeStringToMinutes(_ time: String) -> Int {
        let parts = time.split(separator: ":")
        if let hour = Int(parts[0]), let minute = Int(parts[1]) {
            return hour * 60 + minute
        }
        return 0
    }
}
