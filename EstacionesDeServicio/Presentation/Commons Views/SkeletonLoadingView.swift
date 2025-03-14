import SwiftUI

struct SkeletonLoadingView: View {
    var body: some View {
        ZStack {
            VStack(spacing: 8) {
                // Skeleton para el campo de búsqueda
                SkeletonSearchBar()
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // Skeleton para FilterControlsView
                SkeletonFilterControlsView()
                    .padding(.horizontal)
                
                // Skeleton para el contenido principal (lista de gasolineras)
                List {
                    ForEach(0..<10, id: \.self) { _ in
                        SkeletonRow()
                            .listRowSeparator(.visible)
                            .listRowSeparatorTint(Color.gray.opacity(0.5))
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                }
                .listStyle(.plain)
            }
            .edgesIgnoringSafeArea(.bottom)
            
            // Reemplazo del SkeletonTabBar por el botón flotante
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {}) {
                        Label(
                            title: {
                                Text("Mapa")
                                    .font(.caption)
                            },
                            icon: {
                                Image(systemName: "map.fill")
                                    .font(.caption)
                            }
                        )
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .clipShape(Capsule())
                        .shadow(radius: 5)
                    }
                    .disabled(true) // Deshabilitado para que no sea interactivo en modo loading
                    Spacer()
                }
            }
        }
    }
}


struct SkeletonSearchBar: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.gray.opacity(0.3))
            .frame(height: 36)
            .frame(maxWidth: .infinity)
            .shimmerEffect()
    }
}

struct SkeletonFilterControlsView: View {
    var body: some View {
        VStack(spacing: 10) {
            // Placeholder para el Picker
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 30)
                .shimmerEffect()

            // Placeholder para el Slider y su etiqueta
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 15)
                    .shimmerEffect()

                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 20)
                    .shimmerEffect()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

struct SkeletonRow: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Cabecera
            HStack {
                // Simula el título (rotulo)
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 150, height: 20)
                
                Spacer()
                
                // Simula la distancia
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 20)
            }
            
            // Dirección
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 16) // Simula la dirección
            
            // Combustible seleccionado + Costo de llenado
            HStack(spacing: 8) {
                // Simula el bloque de precio
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 140, height: 40)
                VStack(alignment: .leading, spacing: 8) {
                    // Simula el texto de costo de llenado
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 120, height: 12)
                    // Simula el texto de del promedio en el radio
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 140, height: 12)
                }
            }
            .padding(.top, 8)
        }
        .padding(.vertical, 8)
        .shimmerEffect()  // Aplicar tu efecto shimmer si lo deseas
    }
}

struct SkeletonTabBar: View {
    var body: some View {
        HStack {
            ForEach(0..<2, id: \.self) { _ in
                VStack(spacing: 8) {
                    // Placeholder para el ícono
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .shimmerEffect()

                    // Placeholder para el texto del tab
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 50, height: 20)
                        .shimmerEffect()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(EdgeInsets(top: 12, leading: 0, bottom: 28, trailing: 0))
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
