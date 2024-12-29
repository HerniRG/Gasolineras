import SwiftUI
import MapKit

struct MapaGasolinerasView: View {
    let gasolineras: [Gasolinera]
    @Binding var region: MKCoordinateRegion

    @State private var isUpdatingRegion = false // Controla llamadas repetitivas

    private let zoomThreshold: Double = 0.05

    var body: some View {
        let showPins = region.span.latitudeDelta <= zoomThreshold
        let gasolinerasVisibles = showPins ? gasolineras : []

        ZStack {
            // Mapa con las gasolineras visibles según el zoom
            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: gasolinerasVisibles) { gasolinera in
                MapAnnotation(coordinate: gasolinera.coordinate) {
                    NavigationLink(destination: GasolineraDetailView(gasolinera: gasolinera)) {
                        VStack(spacing: 4) {
                            Image(systemName: "fuelpump.fill")
                                .foregroundColor(.red)
                                .padding(6)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 4)

                            if let distancia = gasolinera.distancia {
                                Text("\(distancia / 1000, specifier: "%.2f") km") // Distancia en kilómetros
                                    .font(.caption)
                                    .foregroundColor(.primary)
                                    .padding(4)
                                    .background(Color(UIColor.systemBackground))
                                    .cornerRadius(5)
                                    .shadow(radius: 2)
                            }
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.bottom)

            // Texto animado que actúa como botón
            if !showPins {
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        Text("Haz zoom para ver las gasolineras")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    .padding(10)
                    .background(Color(UIColor.systemBackground).opacity(0.95))
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.2), radius: 5)
                    Spacer()
                }
                .padding(.top, 40)
            }
        }
    }
}
