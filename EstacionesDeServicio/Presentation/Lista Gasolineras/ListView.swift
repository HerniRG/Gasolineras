import SwiftUI

struct ListView: View {
    let gasolineras: [Gasolinera]

    var body: some View {
        List(gasolineras) { gasolinera in
            NavigationLink(destination: GasolineraDetailView(gasolinera: gasolinera)) {
                GasolineraRow(gasolinera: gasolinera)
            }
        }
        .listStyle(PlainListStyle())
    }
}
