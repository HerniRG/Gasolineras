import SwiftUI
import MapKit

struct GasolinerasView: View {
    @EnvironmentObject var viewModel: GasolinerasViewModel
    @State private var selectedTab: Tab = .list
    @State private var isShowingPreferences: Bool = false
    @State private var isShowingGPSActivation: Bool = false
    @StateObject private var keyboard = KeyboardObserver()
    @State private var isNavigatingToSearch: Bool = false  // Nuevo estado para la navegación
    
    enum Tab { case list, map }
    
    var body: some View {
        NavigationView {
            content
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    
                    // 1) Título Personalizado en el Centro
                    ToolbarItem(placement: .principal) {
                        HStack(spacing: 8) {
                            Image("gasolineraIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                            
                            Text("Tu Gasolinera")
                                .font(.headline)
                        }
                    }
                    
                    // 2) Botón de Preferencias en la Esquina Derecha
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
        .sheet(isPresented: $isShowingPreferences) {
            PreferencesView()
                .environmentObject(viewModel)
        }
        .onReceive(viewModel.$locationAuthorized.combineLatest(viewModel.$locationDenied)) { authorized, denied in
            if !authorized || denied {
                isShowingGPSActivation = true
            }
        }
        .fullScreenCover(isPresented: $isShowingGPSActivation) {
            GPSActivationView {
                isShowingGPSActivation = false
            }
            .environmentObject(viewModel)
        }
        .onChange(of: selectedTab) { newTab in
            if newTab == .map {
                viewModel.searchText = ""
            }
        }
        // Navegación a SearchView
        .fullScreenCover(isPresented: $isNavigatingToSearch) {
            SearchView()
                .environmentObject(viewModel) // Asegúrate de pasar el EnvironmentObject si es necesario
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
                    
                    // --- Búsqueda y Filtros ---
                    if selectedTab == .list {
                        VStack(spacing: 8) {
                            Button(action: {
                                isNavigatingToSearch = true
                            }) {
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.gray)
                                    Text("Buscar gasolineras o ubicación")
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(10)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 16)

                            FilterControlsView()
                                .padding(.horizontal)
                        }
                        .padding(.top, 4)
                    }

                    // --- Contenido Principal: Lista o Mapa ---
                    if selectedTab == .list {
                        if viewModel.filteredGasolineras.isEmpty {
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
                                .transition(.asymmetric(
                                    insertion: .move(edge: .leading),
                                    removal: .move(edge: .leading)
                                ))
                        }
                    } else {
                        mapView
                    }
                }
                .frame(maxHeight: .infinity)
                .edgesIgnoringSafeArea(.bottom)
            }

            // --- Botón Flotante en el Centro Inferior ---
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.2)) {
                            selectedTab = (selectedTab == .list) ? .map : .list
                        }
                    }) {
                        Label(
                            title: {
                                Text(selectedTab == .list ? "Mapa" : "Lista")
                                    .transition(.opacity) // Suaviza el cambio de texto
                            },
                            icon: {
                                Image(systemName: selectedTab == .list ? "map.fill" : "list.bullet")
                                    .rotationEffect(.degrees(selectedTab == .list ? 0 : 180)) // Rotación suave del icono
                                    .scaleEffect(selectedTab == .list ? 1.0 : 1.2) // Efecto de escala al cambiar
                                    .animation(.easeInOut(duration: 0.3), value: selectedTab)
                            }
                        )
                        .font(.caption)
                        .padding()
                        .foregroundColor(Color.white)
                        .background(selectedTab == .list ? Color.blue : Color.green) // Cambio de color animado
                        .clipShape(Capsule())
                        .shadow(radius: 5)
                        .scaleEffect(selectedTab == .list ? 1.0 : 1.1) // Hace un pequeño zoom al cambiar
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
                    }
                    Spacer()
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: selectedTab)
    }
    
    @ViewBuilder
    private var mapView: some View {
        // Ahora solo contenemos MapaGasolinerasView
        MapaGasolinerasView(
            gasolineras: viewModel.gasolineras
        )
        .transition(
            .asymmetric(insertion: .move(edge: .trailing),
                        removal: .move(edge: .trailing))
        )
    }
}
