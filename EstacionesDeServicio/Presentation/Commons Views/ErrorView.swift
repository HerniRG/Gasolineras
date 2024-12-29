import SwiftUI

struct ErrorView: View {
    let error: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text("Algo salió mal")
                .font(.headline)
                .foregroundColor(.primary) // Adapta el texto al modo light/dark
            Text(error)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button(action: retryAction) {
                Text("Reintentar")
                    .padding()
                    .frame(maxWidth: .infinity) // Botón más grande
                    .background(Color.accentColor) // Usa el color de acento
                    .foregroundColor(.white) // Blanco sobre color de acento
                    .cornerRadius(10)
            }
            .padding(.horizontal) // Añade un poco de espacio a los lados
        }
        .padding()
        .background(Color(UIColor.systemBackground)) // Fondo adaptable
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4) // Sombra sutil
        .padding()
    }
}
