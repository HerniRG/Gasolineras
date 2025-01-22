import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct EstacionesDeServicioApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var viewModel = GasolinerasViewModel() // Crear una única instancia del ViewModel
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(viewModel) // Pasar el ViewModel al entorno
        }
    }
}
