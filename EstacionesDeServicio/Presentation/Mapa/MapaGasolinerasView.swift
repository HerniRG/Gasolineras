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
                            .foregroundColor(.blue)
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
                HStack {
                    if showPins {
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
                    }
                    
                    Spacer()
                    
                    // Botón flotante para centrar en la ubicación del usuario
                    FloatingButton(icon: "location.fill") {
                        viewModel.requestLocationUpdate()
                        centerOnUserLocation()
                    }
                    .accessibilityLabel("Centrar en mi ubicación actual")
                }
                .padding(.horizontal)
                .transition(.opacity)
                
            }
            .padding(.bottom, 30)
            .padding(.horizontal, 10)
            
            // --- Notificación opcional (desaparece tras 3s) ---
            if showNotification {
                VStack {
                    Text(viewModel.cheapestGasolineras.count > 1
                         ? "Gasolinera con el precio más bajo centrada (\(currentDisplayIndex) de \(viewModel.cheapestGasolineras.count))"
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
    
    // Calcula el índice actual para la notificación
    private var currentDisplayIndex: Int {
        if viewModel.currentCheapestIndex == 0 && viewModel.cheapestGasolineras.count > 0 {
            return viewModel.cheapestGasolineras.count
        } else {
            return viewModel.currentCheapestIndex
        }
    }
    
    // Centra el mapa en las gasolineras más económicas
    private func centerMapOnCheapestGasolineras() {
        // Pedimos la gasolinera a centrar al ViewModel
        guard let cheapestGas = viewModel.cycleCheapestGasolinera() else { return }

        let newRegion = MKCoordinateRegion(
            center: cheapestGas.coordinate,
            span: MKCoordinateSpan(
                latitudeDelta: region.span.latitudeDelta,
                longitudeDelta: region.span.longitudeDelta
            )
        )
        
        withAnimation {
            region = newRegion
            showNotification = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
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
        
        let currentDelta = region.span.latitudeDelta
        
        if currentDelta > 5.0 {
            // Si el usuario está MUY alejado, primero hacemos un salto rápido sin animación a un zoom intermedio
            region = MKCoordinateRegion(
                center: currentLocation,
                span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
            )
            // Luego, con un pequeño retardo, animamos hasta el zoom final:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    region = MKCoordinateRegion(
                        center: currentLocation,
                        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                    )
                }
            }
        } else {
            // Si el zoom no está tan alejado, se anima directamente
            withAnimation {
                region = MKCoordinateRegion(
                    center: currentLocation,
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                )
            }
        }
    }
}
