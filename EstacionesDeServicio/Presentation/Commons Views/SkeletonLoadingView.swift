import SwiftUI

import SwiftUI

struct SkeletonLoadingView: View {
    var body: some View {
        VStack {
            // Skeleton para FilterControlsView
            SkeletonFilterControlsView()
                .padding(.horizontal)
                .padding(.top, 8)
            
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
            
            // Skeleton para la TabBar
            SkeletonTabBar()
        }
        .edgesIgnoringSafeArea(.bottom) // Evita que la TabBar quede fuera de la pantalla
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
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 150, height: 20) // Simula el título
                Spacer()
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 20) // Simula la distancia
            }

            // Dirección
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 16) // Simula la dirección

            // Combustibles
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(0..<3, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 80, height: 40) // Simula un bloque de precio
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(.vertical, 8)
        .shimmerEffect()
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
        .padding(EdgeInsets(top: 12, leading: 0, bottom: 32, trailing: 0))
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 2)
        
    }
}
