import SwiftUI
import MapKit

struct MapaGasolinerasView: View {
    let gasolineras: [Gasolinera]
    @Binding var region: MKCoordinateRegion

    @EnvironmentObject var viewModel: GasolinerasViewModel // Añadido

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
                        GasolineraAnnotationView(gasolinera: gasolinera, selectedFuelType: viewModel.selectedFuelType.rawValue)
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
