import SwiftUI
import MapKit

struct MapaGasolinerasView: View {
    let gasolineras: [Gasolinera]
    
    @EnvironmentObject var viewModel: GasolinerasViewModel
    
    // Para mostrar la animación del ojo
    @State private var animateEye: Bool = false
    
    private let zoomThreshold: Double = 0.05
    
    var body: some View {
        ZStack {
            // --- Mapa ---
            Map(
                coordinateRegion: $viewModel.region,
                showsUserLocation: true,
                annotationItems: gasolinerasVisibles
            ) { gasolinera in
                MapAnnotation(coordinate: gasolinera.coordinate) {
                    NavigationLink(destination: GasolineraDetailView(gasolinera: gasolinera)) {
                        GasolineraAnnotationView(
                            gasolinera: gasolinera,
                            selectedFuelType: viewModel.selectedFuelType,
                            isCheapest: viewModel.cheapestGasolineras.contains(where: { $0.id == gasolinera.id })
                        )
                    }
                }
            }
            .mapControls {EmptyView()}
            .edgesIgnoringSafeArea(.bottom)
            
            // --- Mensaje de "Haz zoom para ver las gasolineras" ---
            if !showPins {
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.blue)
                        Text("Haz zoom para ver las gasolineras")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    .bubbleStyle()
                    
                    Spacer()
                }
                .padding(.top, 20)
                .transition(.opacity)
            }
            
            // --- Leyenda inferior (Precio más bajo, botón centrar, etc.) ---
            VStack (spacing: 8) {
                if showPins && !viewModel.cheapestGasolineras.isEmpty {
                    HStack {
                        Spacer()
                        PrecioResumenView()  // Resumen precios
                            .padding(.top, 20)
                        Spacer()
                    }
                    .transition(.opacity)
                }
                
                Spacer()
                
                if showPins {
                    Button(action: {
                        viewModel.centerMapOnCheapestGasolineras()
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "dollarsign.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18) // Tamaño ligeramente más grande
                                .foregroundColor(.green) // Color distintivo para el badge
                                .background(Color.white) // Fondo blanco para destacar
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary.opacity(0.4), lineWidth: 0.5) // Borde fino de color .primary
                                )
                            
                            Text("Precio más bajo en \(viewModel.radius, specifier: "%.2f") km ")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            
                            Image(systemName: "eye")
                                .foregroundColor(.blue)
                                .font(.system(size: 12, weight: .bold))
                                .scaleEffect(viewModel.showNotification ? 1.4 : 1.0)
                                .animation(.easeOut(duration: 0.6), value: viewModel.showNotification)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .bubbleStyle()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 0.5)
                    )
                    .padding(.bottom, 20)
                }
                
                HStack {
                                        
                    Spacer()
                    
                    // Botón "centrar en mi ubicación"
                    FloatingButton(icon: "location.fill") {
                        viewModel.requestLocationUpdate()
                        viewModel.centerOnUserLocation()
                    }
                    .accessibilityLabel("Centrar en mi ubicación actual")
                }
                .padding(.horizontal)
                .transition(.opacity)
            }
            .padding(.bottom, 30)
            .padding(.horizontal, 10)
            
            // --- Notificación opcional (desaparece tras 3s) ---
            if viewModel.showNotification {
                VStack {
                    Text(viewModel.notificationText)
                        .font(.caption)
                        .padding(8)
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .shadow(radius: 4)
                        .offset(y: -100)
                }
                .transition(.opacity)
            }
        }
        // Animaciones
        .animation(.easeInOut, value: showPins)
        .onAppear {
            Task {
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 segundos
                withAnimation(.easeOut(duration: 0.6)) {
                    animateEye = true
                }
            }
        }
    }
    
    // --- Computed Properties ---
    
    private var showPins: Bool {
        viewModel.region.span.latitudeDelta <= zoomThreshold
    }
    
    private var gasolinerasVisibles: [Gasolinera] {
        showPins ? gasolineras : []
    }
    
    /// Devuelve el índice actual para la notificación
    private var currentDisplayIndex: Int {
        // El índice ya está gestionado en el ViewModel
        return viewModel.currentCheapestIndex == 0 && viewModel.cheapestGasolineras.count > 0 ? viewModel.cheapestGasolineras.count : viewModel.currentCheapestIndex
    }
    
    /// Texto que se muestra en la notificación
    private var notificationText: String {
        viewModel.notificationText
    }
}
