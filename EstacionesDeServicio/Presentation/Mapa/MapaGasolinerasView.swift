import SwiftUI
import MapKit

struct MapaGasolinerasView: View {
    let gasolineras: [Gasolinera]
    @Binding var region: MKCoordinateRegion
    
    @EnvironmentObject var viewModel: GasolinerasViewModel
    
    @State private var isUpdatingRegion = false
    @State private var showNotification: Bool = false
    
    @State private var animateEye: Bool = false // Variable de estado para la animación
    
    private let zoomThreshold: Double = 0.05
    
    var body: some View {
        ZStack {
            // --- Mapa ---
            Map(
                coordinateRegion: $region,
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
            .edgesIgnoringSafeArea(.bottom)
            
            // --- Mensaje de "Haz zoom para ver las gasolineras" ---
            if !showPins {
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        Text("Haz zoom para ver las gasolineras")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    .bubbleStyle()  // Aplicando el modificador
                    
                    Spacer()
                }
                .padding(.top, 40)
                .transition(.opacity)
            }
            
            // --- Parte inferior: leyenda (estrella), PrecioResumenView y FloatingButton ---
            VStack {
                // Leyenda: "Precio más bajo en X km (Y encontradas)"
                if showPins && !viewModel.cheapestGasolineras.isEmpty {
                    HStack {
                        Spacer()
                        // Tu vista de resumen de precios
                        PrecioResumenView()
                            .padding(.top, 40)
                        
                        Spacer()
                    }
                    .transition(.opacity)
                }
                
                Spacer()
                
                // HStack con el PrecioResumenView y el botón flotante
                if showPins {
                    HStack {
                        
                        Button(action: {
                            centerMapOnCheapestGasolineras()
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: "star.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(.yellow)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary.opacity(0.4), lineWidth: 0.5) // Borde existente
                                    )
                                
                                Text("Precio más bajo en \(viewModel.radius, specifier: "%.2f") km ")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                Image(systemName: "eye")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 12, weight: .bold))
                                    .scaleEffect(animateEye ? 1.4 : 1.0) // Efecto de rebote
                                    .animation(.easeOut(duration: 0.6), value: animateEye) // Animación suave
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .bubbleStyle()  // Aplicando el modificador de estilo burbuja
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 0.5) // Borde fino azul
                        )
                        .accessibilityLabel("Centrar en gasolineras más económicas")
                        
                        Spacer()
                        
                        // Botón flotante para centrar en la ubicación del usuario
                        FloatingButton(icon: "location.fill") {
                            viewModel.requestLocationUpdate()
                            centerOnUserLocation()
                        }
                        .accessibilityLabel("Centrar en mi ubicación actual")
                    }
                    .transition(.opacity)
                }
            }
            .padding(.bottom, 30)
            .padding(.horizontal, 10)
            
            // --- Notificación opcional (desaparece tras 2s) ---
            if showNotification {
                VStack {
                    Text(viewModel.cheapestGasolineras.count > 1
                         ? "Gasolineras con los precios más bajos centradas"
                         : "Gasolinera con el precio más bajo centrada")
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
        // Aplica la animación al ZStack completo
        .animation(.easeInOut, value: showPins)
        .animation(.easeInOut, value: showNotification)
        .onAppear {
            // Activar la animación del ojo una vez al aparecer la vista
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeOut(duration: 0.6)) {
                    animateEye = true
                }
            }
        }
    }
    
    // Mostrar o no los pines según el zoom
    private var showPins: Bool {
        region.span.latitudeDelta <= zoomThreshold
    }
    
    // Cuando no hay suficiente zoom, no mostramos nada
    private var gasolinerasVisibles: [Gasolinera] {
        showPins ? gasolineras : []
    }
    
    // Centra el mapa en las gasolineras más económicas
    private func centerMapOnCheapestGasolineras() {
        guard !viewModel.cheapestGasolineras.isEmpty else { return }
        let firstCheapest = viewModel.cheapestGasolineras.first!
        
        let newRegion = MKCoordinateRegion(
            center: firstCheapest.coordinate,
            span: MKCoordinateSpan(
                latitudeDelta: region.span.latitudeDelta,
                longitudeDelta: region.span.longitudeDelta
            )
        )
        
        withAnimation {
            region = newRegion
            showNotification = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showNotification = false
            }
        }
    }
    
    // Centra el mapa en la ubicación actual del usuario
    private func centerOnUserLocation() {
        guard let currentLocation = viewModel.userLocation else {
            print("Error: No se pudo obtener la ubicación actual del usuario.")
            return
        }
        
        withAnimation {
            // Ajusta el valor del span según el zoom deseado
            region = MKCoordinateRegion(
                center: currentLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
        }
    }
}
