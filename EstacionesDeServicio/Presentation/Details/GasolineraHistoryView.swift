//
//  GasolineraHistoryView.swift
//  EstacionesDeServicio
//
//  Created by Hernán Rodríguez on 12/3/25.
//

import SwiftUI
import Charts

struct GasolineraHistoryView: View {
    let gasolinera: Gasolinera
    @State private var selectedFuelType: FuelType?
    let historyData: [FuelHistory]

    var filteredData: [FuelHistory] {
        guard let selectedFuelType else { return [] }
        return historyData.filter { $0.fuelType == selectedFuelType }
    }

    init(gasolinera: Gasolinera) {
        self.gasolinera = gasolinera
        self.historyData = GasolineraHistoryView.generateHistoryData(for: gasolinera)
        self._selectedFuelType = State(initialValue: GasolineraHistoryView.getFirstAvailableFuel(from: gasolinera))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                
                // Selector de tipo de combustible
                if let availableFuels = GasolineraHistoryView.getAvailableFuels(from: gasolinera), !availableFuels.isEmpty {
                    Picker("Tipo de Combustible", selection: $selectedFuelType) {
                        ForEach(availableFuels, id: \.self) { fuel in
                            Text(fuel.displayName).tag(fuel as FuelType?)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                } else {
                    Text("No hay precios disponibles en esta gasolinera")
                        .foregroundColor(.gray)
                        .padding()
                }

                // Gráfica de precios
                if let selectedFuelType {
                    Chart {
                        ForEach(filteredData) { entry in
                            LineMark(
                                x: .value("Fecha", entry.date),
                                y: .value("Precio", entry.price)
                            )
                            .foregroundStyle(color(for: entry.fuelType))
                            .lineStyle(StrokeStyle(lineWidth: 3))
                        }
                    }
                    .frame(height: 250)
                    .padding()
                }


                // Lista de precios recientes
                if let selectedFuelType {
                    List(filteredData) { entry in
                        HStack {
                            Text(entry.date, style: .date)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Spacer()
                            Text("\(entry.price, specifier: "%.3f") €/L")
                                .font(.headline)
                                .foregroundColor(color(for: entry.fuelType))
                        }
                    }
                    .listStyle(PlainListStyle())
                }

            }
            .navigationTitle("Historial de Precios")
            .navigationBarTitleDisplayMode(.inline)
            .padding()
        }
    }

    // MARK: - Generación de datos de prueba basados en la gasolinera real
    static func generateHistoryData(for gasolinera: Gasolinera) -> [FuelHistory] {
        let today = Date()
        var history: [FuelHistory] = []

        for fuelType in FuelType.allCases {
            if let price = gasolinera.price(for: fuelType) {
                for dayOffset in 0..<7 {
                    if let date = Calendar.current.date(byAdding: .day, value: -dayOffset, to: today) {
                        history.append(FuelHistory(fuelType: fuelType, date: date, price: price - Double.random(in: 0.01...0.05)))
                    }
                }
            }
        }
        return history.sorted { $0.date < $1.date }
    }

    // Devuelve el primer tipo de combustible disponible en la gasolinera
    static func getFirstAvailableFuel(from gasolinera: Gasolinera) -> FuelType? {
        return FuelType.allCases.first(where: { gasolinera.price(for: $0) != nil })
    }

    // Obtiene una lista de tipos de combustible disponibles en esta gasolinera
    static func getAvailableFuels(from gasolinera: Gasolinera) -> [FuelType]? {
        return FuelType.allCases.filter { gasolinera.price(for: $0) != nil }
    }
}

// Modelo de historial de precios
struct FuelHistory: Identifiable {
    let id = UUID()
    let fuelType: FuelType
    let date: Date
    let price: Double
}

// Función para asignar colores a cada tipo de combustible
func color(for fuel: FuelType) -> Color {
    switch fuel {
    case .gasolina95:
        return Color.green // Combustible fósil
    case .gasolina98:
        return Color.blue // Combustible fósil
    case .gasoleoA:
        return Color.orange // Combustible fósil
    case .gasoleoPremium:
        return Color.yellow // Combustible fósil
    case .glp:
        return Color.purple // GLP
    case .gnc:
        return Color.teal // Gas Natural Comprimido
    case .gnl:
        return Color.teal // Gas Natural Licuado
    case .hidrogeno:
        return Color.blue // Hidrógeno
    case .bioetanol:
        return Color.purple // Bioetanol
    case .biodiesel:
        return Color.purple // Biodiesel
    case .esterMetilico:
        return Color.teal // Éster Metílico
    }
}
