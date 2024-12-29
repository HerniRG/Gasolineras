// OnboardingView.swift
import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var viewModel: GasolinerasViewModel
    
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    
    @State private var selectedPage = 0
    @State private var selectedFuelType: FuelType? = nil
    
    var body: some View {
        VStack {
            TabView(selection: $selectedPage) {
                
                // 1) Primera pantalla: Introducción
                IntroductionView {
                    withAnimation {
                        selectedPage += 1
                    }
                }
                .tag(0)
                
                // 2) Pantalla de Activación de GPS
                GPSActivationView {
                    withAnimation {
                        selectedPage += 1
                    }
                }
                .tag(1)
                
                // 3) Pantalla de Selección de Combustible
                FuelSelectionView(selectedFuelType: $selectedFuelType) {
                    if let fuelType = selectedFuelType {
                        viewModel.selectedFuelType = fuelType
                        onboardingCompleted = true
                    }
                }
                .tag(2)
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

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(GasolinerasViewModel())
    }
}
