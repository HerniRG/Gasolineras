import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject var viewModel: GasolinerasViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Depósito de Combustible")) {
                    VStack(alignment: .leading) {
                        Text("Litros del Depósito")
                        Slider(value: $viewModel.fuelTankLiters, in: 10...100, step: 1)
                        Text("\(Int(viewModel.fuelTankLiters)) Litros")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                Section(header: Text("Tipo de Combustible")) {
                    Picker("Tipo de Combustible", selection: $viewModel.selectedFuelType) {
                        ForEach(FuelType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
            }
            .navigationTitle("Preferencias")
            .navigationBarItems(trailing: Button("Cerrar") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
