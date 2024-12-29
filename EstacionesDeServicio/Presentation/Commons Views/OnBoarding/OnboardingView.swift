import SwiftUI
import Lottie
import CoreLocation

struct OnboardingView: View {
    @EnvironmentObject var viewModel: GasolinerasViewModel
    
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    
    @State private var selectedPage = 0
    @State private var selectedFuelType: FuelType? = nil
    
    var body: some View {
        VStack {
            TabView(selection: $selectedPage) {
                
                // 1) Primera pantalla: Introducción
                VStack(spacing: 20) {
                    Text("Bienvenido a Tu Gasolinera")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Encuentra las gasolineras más cercanas y ahorra en cada repostaje.")
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    LottieView(animation: .named("welcome"))
                        .looping()
                        .frame(height: 300)
                    
                    Spacer()
                    Button(action: {
                        withAnimation {
                            selectedPage += 1
                        }
                    }) {
                        Text("Siguiente")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
                .tag(0)
                .padding()
                
                // 2) Pantalla de Activación de GPS
                VStack(spacing: 20) {
                    Text("Activa el GPS")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Esta aplicación requiere acceso a tu ubicación para mostrar las gasolineras más cercanas.")
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    LottieView(animation: .named("gps"))
                        .looping()
                        .frame(height: 300)
                    
                    Spacer()
                    
                    if viewModel.locationDenied {
                        Text("Permisos denegados. Actívalos desde Configuración.")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    
                    Button(action: {
                        withAnimation {
                            if viewModel.locationDenied {
                                // El usuario ya ha denegado permisos: ir a Ajustes
                                viewModel.openSettings()
                            } else if viewModel.locationAuthorized {
                                // Permisos concedidos: avanzar a la siguiente página
                                selectedPage += 1
                            } else {
                                // Pedir permisos
                                viewModel.requestLocationPermission()
                            }
                        }
                    }) {
                        Text(
                            viewModel.locationAuthorized
                            ? "Permiso Concedido ✅"
                            : (viewModel.locationDenied ? "Abrir Configuración" : "Activar GPS")
                        )
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(viewModel.locationAuthorized ? Color.green : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    // Elimina el modificador .disabled(viewModel.locationAuthorized)
                }
                .tag(1)
                .padding()
                
                // 3) Pantalla de Selección de Combustible
                VStack(spacing: 20) {
                    Text("Selecciona tu combustible")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Elige el tipo de combustible que usas más frecuentemente.")
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    // Nueva implementación: Cuadrícula de Selección
                    FuelSelectionGrid(selectedFuelType: $selectedFuelType)
                        .padding()
                    
                    Spacer()
                    Button(action: {
                        if let fuelType = selectedFuelType {
                            viewModel.selectedFuelType = fuelType
                            onboardingCompleted = true
                        }
                    }) {
                        Text("Finalizar")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(selectedFuelType != nil ? Color.green : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .disabled(selectedFuelType == nil)
                }
                .tag(2)
                .padding()
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Ocultar los indicadores de página por defecto
            
            // Indicadores de Página Personalizados
            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(index == selectedPage ? Color.blue : Color.gray.opacity(0.5))
                        .frame(width: 10, height: 10)
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 20) // Añade padding para separar de los botones
        }
        .onAppear {
            // Chequeamos estado de permisos
            viewModel.checkAuthorizationStatus()
            
            // Si vuelves de Ajustes, refrescar de nuevo
            NotificationCenter.default.addObserver(
                forName: UIApplication.willEnterForegroundNotification,
                object: nil,
                queue: .main
            ) { _ in
                viewModel.checkAuthorizationStatus()
            }
        }
        
        // Bloqueamos avanzar si no hay permisos
        .onChange(of: selectedPage) { newPage in
            if newPage > 1 && !viewModel.locationAuthorized {
                withAnimation {
                    selectedPage = 1
                }
            }
        }
        
        // Si acaban de concederse permisos, avanzar automáticamente
        .onChange(of: viewModel.locationAuthorized) { authorized in
            if authorized && selectedPage < 2 {
                withAnimation {
                    selectedPage = 2
                }
            }
        }
    }
}
