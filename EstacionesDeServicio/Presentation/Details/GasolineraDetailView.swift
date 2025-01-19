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
                    VStack(spacing: 15) {
                        ForEach(FuelType.allCases) { fuel in
                            if let precio = gasolinera.price(for: fuel) {
                                HStack {
                                    // Vista para mostrar precio de un tipo de combustible
                                    FuelPrice(fuelType: fuel, price: precio, isHorizontal: true)
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        // Cálculo del costo de llenado
                                        Text("\(costoLlenado(precio), specifier: "%.2f") € / llenado (\(Int(viewModel.fuelTankLiters)) l)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(nil)
                                        
                                        // Texto para el promedio del tipo de combustible actual
                                        Text("\(viewModel.calcularPromedioEnRadio(fuelType: fuel), specifier: "%.3f") € / l promedio en \(Int(viewModel.radius)) km")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(nil)
                                    }
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
    
    /// Calcula el costo de llenado dado un precio
    private func costoLlenado(_ precioPorLitro: Double) -> Double {
        return precioPorLitro * viewModel.fuelTankLiters
    }
}
