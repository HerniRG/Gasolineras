import SwiftUI
import MapKit

struct GasolinerasView: View {
    @EnvironmentObject var viewModel: GasolinerasViewModel
    @State private var selectedTab: Tab = .list
    @State private var isShowingPreferences: Bool = false
    @State private var isShowingGPSActivation: Bool = false // Nueva variable de estado
    @StateObject private var keyboard = KeyboardObserver()
    
    enum Tab { case list, map }
    
    var body: some View {
        NavigationView {
            content
                .navigationTitle("Gasolineras")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // Botón de preferencias en la esquina superior derecha
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isShowingPreferences = true
                        }) {
                            Image(systemName: "gearshape.fill")
                        }
                        .accessibilityLabel("Preferencias")
                    }
                }
        }
        .navigationViewStyle(.stack)
        // Presentar PreferencesView como una hoja (sheet)
        .sheet(isPresented: $isShowingPreferences) {
            PreferencesView()
                .environmentObject(viewModel)
        }
        // Observador para detectar cambios en permisos de ubicación
        .onReceive(viewModel.$locationAuthorized.combineLatest(viewModel.$locationDenied)) { authorized, denied in
            if !authorized || denied {
                isShowingGPSActivation = true
            }
        }
        // Presentar GPSActivationView como una cubierta de pantalla completa
        .fullScreenCover(isPresented: $isShowingGPSActivation) {
            GPSActivationView {
                // Acción a realizar después de que el usuario active el GPS
                isShowingGPSActivation = false
            }
            .environmentObject(viewModel) // Pasar el viewModel al entorno
        }
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
                    if selectedTab == .list {
                        VStack(spacing: 8) {
                            searchBar
                            FilterControlsView()
                                .padding(.horizontal)
                        }
                        .padding(.top, 8)
                    }
                    
                    if selectedTab == .list {
                        if viewModel.filteredGasolineras.isEmpty {
                            // Mostrar mensaje si no hay resultados
                            VStack {
                                Text("No se encontraron resultados.")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                    .padding(.top, 24)
                                Spacer()
                            }
                            .transition(.opacity)
                        } else {
                            ListView(gasolineras: viewModel.filteredGasolineras)
                                .listStyle(PlainListStyle())
                                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
                        }
                    } else {
                        mapView
                    }
                    
                    // Mostrar el CustomTabBar solo cuando los datos están cargados y no hay teclado visible
                    if !keyboard.isKeyboardVisible {
                        CustomTabBar(selectedTab: $selectedTab, tabs: [.list, .map])
                            //.padding(.top, 10) // Removido para eliminar el hueco
                            .padding(.bottom, 20) // Espacio adecuado para evitar superposición
                            .transition(.move(edge: .bottom))
                            .animation(.easeInOut(duration: 0.3), value: selectedTab)
                    }
                }
                .frame(maxHeight: .infinity)
                .edgesIgnoringSafeArea(.bottom)
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
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingButton(icon: "location.fill", action: {
                        viewModel.requestLocationUpdate()
                        centerOnUserLocation()
                    })
                    .padding(16)
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
    
    private var searchBar: some View {
        HStack {
            TextField("Buscar por gasolinera o localidad...", text: $viewModel.searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 8)
                .onChange(of: viewModel.searchText) {
                    viewModel.updateFilteredGasolineras()
                }
            if !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.searchText = ""
                    viewModel.updateFilteredGasolineras()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 8)
            }
        }
        .padding(.horizontal, 16)
    }
}
