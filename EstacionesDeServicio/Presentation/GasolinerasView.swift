import SwiftUI
import MapKit

struct GasolinerasView: View {
    @EnvironmentObject var viewModel: GasolinerasViewModel // Usar el ViewModel desde el entorno
    @State private var selectedTab: Tab = .list
    
    enum Tab { case list, map }
    
    var body: some View {
        NavigationView {
            content
                .animation(
                    .easeInOut(duration: 0.3),
                    value: viewModel.isLoading || viewModel.errorMessage != nil || selectedTab == .list
                )
                .navigationTitle("Gasolineras")
        }
        .navigationViewStyle(.stack) // Usar .stack para mejor compatibilidad en iPhone
    }
    
    @ViewBuilder
    private var content: some View {
        ZStack {
            if viewModel.isLoading {
                SkeletonLoadingView()
                    .transition(.opacity)
            } else if let error = viewModel.errorMessage {
                ErrorView(error: error, retryAction: viewModel.retryLoading)
                    .transition(.move(edge: .bottom))
            } else {
                VStack(spacing: 0) {
                    // Controles de Filtrado solo en la pestaña de lista
                    if selectedTab == .list {
                        FilterControlsView()
                            .padding(.horizontal)
                            .padding(.top, 8)
                    }
                    
                    // Contenido de la pestaña seleccionada
                    if selectedTab == .list {
                        ListView(gasolineras: viewModel.filteredGasolineras)
                            .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
                    } else {
                        mapView
                    }
                    
                    // Barra de pestañas personalizada
                    CustomTabBar(selectedTab: $selectedTab, tabs: [.list, .map])
                }
            }
        }
    }
    
    @ViewBuilder
    private var mapView: some View {
        ZStack {
            MapaGasolinerasView(
                gasolineras: viewModel.gasolineras,
                region: $viewModel.region
            )
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))

            // Posicionamiento del FloatingButton
            VStack {
                Spacer() // Empuja hacia abajo
                HStack {
                    Spacer() // Empuja hacia la derecha
                    FloatingButton(icon: "location.fill", action: {
                        viewModel.requestLocationUpdate()
                        centerOnUserLocation()
                    })
                    .padding(16) // Ajusta la posición
                }
            }
        }
    }
    
    private func centerOnUserLocation() {
        guard let currentLocation = viewModel.userLocation else {
            print("Error: No se pudo obtener la ubicación actual del usuario.")
            return
        }

        withAnimation {
            viewModel.region = MKCoordinateRegion(
                center: currentLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
        }
    }
}
