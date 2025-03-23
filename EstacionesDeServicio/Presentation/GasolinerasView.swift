import SwiftUI
import MapKit

struct GasolinerasView: View {
    @EnvironmentObject var viewModel: GasolinerasViewModel
    @State private var selectedTab: Tab = .list
    @State private var isShowingPreferences: Bool = false
    @State private var isShowingGPSActivation: Bool = false
    @StateObject private var keyboard = KeyboardObserver()
    @State private var isNavigatingToSearch: Bool = false  // Estado para la navegación
    
    // Estado para detectar si el último elemento está visible
    @State private var isLastItemVisible: Bool = false
    @State private var showFloatingButton: Bool = false
    
    enum Tab { case list, map }
    
    var body: some View {
        NavigationView {
            content
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // 1) Título personalizado en el centro
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
                    
                    // 2) Botón de preferencias en la esquina derecha
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
                .environmentObject(viewModel)
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
                    .transition(.opacity)
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
                                Spacer()
                                Image(systemName: "magnifyingglass.circle")
                                    .resizable()
                                    .frame(width: 64, height: 64)
                                    .foregroundColor(.gray.opacity(0.4))

                                Text("No encontramos gasolineras con esos filtros")
                                    .font(.headline)
                                    .padding(.top, 8)

                                Text("Prueba a ampliar la distancia o cambiar el tipo de combustible.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                Spacer()
                            }
                            .transition(.opacity)
                        } else {
                            List {
                                // Usamos un ForEach enumerado para identificar el último elemento
                                ForEach(Array(viewModel.filteredGasolineras.enumerated()), id: \.element.id) { index, gasolinera in
                                    NavigationLink(destination: GasolineraDetailView(gasolinera: gasolinera)) {
                                        GasolineraRow(gasolinera: gasolinera)
                                    }
                                    .onAppear {
                                        if index == viewModel.filteredGasolineras.count - 1 {
                                            withAnimation {
                                                isLastItemVisible = true
                                            }
                                        }
                                    }
                                    .onDisappear {
                                        if index == viewModel.filteredGasolineras.count - 1 {
                                            withAnimation {
                                                isLastItemVisible = false
                                            }
                                        }
                                    }
                                }
                            }
                            .listStyle(PlainListStyle())
                            // Al cambiar el número de resultados, reseteamos la variable para que se recalcule la visibilidad del botón
                            .onChange(of: viewModel.filteredGasolineras.count) { newCount in
                                withAnimation {
                                    isLastItemVisible = false
                                }
                            }
                        }
                    } else {
                        mapView
                    }
                }
                .frame(maxHeight: .infinity)
                .edgesIgnoringSafeArea(.bottom)
                .transition(.opacity)
            }
            
            // --- Botón Flotante en el Centro Inferior ---
            // Solo se muestra si NO hay loading ni error
            if !viewModel.isLoading && viewModel.errorMessage == nil {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            withAnimation(.easeInOut(duration: 0.4)) {
                                selectedTab = (selectedTab == .list) ? .map : .list
                            }
                        }) {
                            Label(
                                title: {
                                    Text(selectedTab == .list ? "Mapa" : "Lista")
                                        .transition(.opacity)
                                },
                                icon: {
                                    Image(systemName: selectedTab == .list ? "map.fill" : "list.bullet")
                                        .rotationEffect(.degrees(selectedTab == .list ? 0 : 180))
                                        .scaleEffect(selectedTab == .list ? 1.0 : 1.2)
                                        .animation(.easeInOut(duration: 0.3), value: selectedTab)
                                }
                            )
                            .font(.caption)
                            .padding()
                            .foregroundColor(.white)
                            .background(selectedTab == .list ? Color.blue : Color.green)
                            .clipShape(Capsule())
                            .shadow(radius: 5)
                            .scaleEffect(selectedTab == .list ? 1.0 : 1.1)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
                        }
                        Spacer()
                    }
                }
            .opacity((showFloatingButton && !isLastItemVisible) ? 1 : 0)
            .offset(y: (showFloatingButton && !isLastItemVisible) ? 0 : 50)
            .onAppear {
                if !showFloatingButton {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showFloatingButton = true
                        }
                    }
                }
            }
            }
        }
        .animation(.easeInOut(duration: 0.4), value: viewModel.isLoading)
    }
    
    @ViewBuilder
    private var mapView: some View {
        // Contenido del mapa con transición
        MapaGasolinerasView(gasolineras: viewModel.gasolineras)
            .transition(.move(edge: .bottom))
    }
}
