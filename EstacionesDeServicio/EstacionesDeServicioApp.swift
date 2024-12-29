import SwiftUI

@main
struct EstacionesDeServicioApp: App {
    @StateObject var viewModel = GasolinerasViewModel() // Crear una única instancia del ViewModel
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(viewModel) // Pasar el ViewModel al entorno
        }
    }
}
