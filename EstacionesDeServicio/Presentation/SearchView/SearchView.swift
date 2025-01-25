import SwiftUI

struct SearchView: View {
    @EnvironmentObject var viewModel: GasolinerasViewModel
    @Environment(\.dismiss) var dismiss
    @State private var searchText: String = ""
    
    // Declarar una propiedad de enfoque
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        NavigationStack { // Recomendado para iOS 16+
            VStack {
                // Barra de Búsqueda
                HStack {
                    TextField("Buscar gasolineras o ubicación", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 16)
                        .focused($isSearchFieldFocused) // Vincular el enfoque
                        .onChange(of: searchText) { newValue in
                            viewModel.performGlobalSearch(query: newValue)
                        }
                        .submitLabel(.search) // Cambiar el botón de retorno a "Buscar"
                        .accessibilityLabel("Campo de búsqueda")
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            viewModel.performGlobalSearch(query: "")
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 16)
                        .accessibilityLabel("Limpiar búsqueda")
                    }
                }
                .padding(.top, 16)
                
                // Resultados de la Búsqueda
                if viewModel.globalSearchResults.isEmpty && !searchText.isEmpty {
                    Spacer()
                    Text("No se encontraron resultados.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .accessibilityIdentifier("NoResultsText")
                    Spacer()
                } else {
                    ListView(gasolineras: viewModel.globalSearchResults)
                        .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Buscar Gasolineras")
            .navigationBarItems(trailing: Button("Cerrar") {
                dismiss()
            })
            .onAppear {
                // Enfocar automáticamente el TextField cuando la vista aparece
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.isSearchFieldFocused = true
                }
            }
        }
    }
}
