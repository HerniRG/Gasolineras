import SwiftUI
import Lottie

struct GPSActivationView: View {
    @EnvironmentObject var viewModel: GasolinerasViewModel
    var onNext: () -> Void // Closure para avanzar a la siguiente página
    
    var body: some View {
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
                if viewModel.locationDenied {
                    // El usuario ya ha denegado permisos: ir a Ajustes
                    viewModel.openSettings()
                } else if viewModel.locationAuthorized {
                    // Permisos concedidos: avanzar a la siguiente página
                    onNext() // Llamada al closure
                } else {
                    // Pedir permisos
                    viewModel.requestLocationPermission()
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
        }
        .padding()
    }
}

struct GPSActivationView_Previews: PreviewProvider {
    static var previews: some View {
        GPSActivationView {
            print("Avanzar a la siguiente página")
        }
        .environmentObject(GasolinerasViewModel())
    }
}
