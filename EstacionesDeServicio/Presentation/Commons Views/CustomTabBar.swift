import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: GasolinerasView.Tab
    let tabs: [GasolinerasView.Tab]
    
    var body: some View {
        HStack {
            ForEach(tabs, id: \.self) { tab in
                Button(action: { selectedTab = tab }) {
                    VStack {
                        Image(systemName: tab == .list ? "list.bullet" : "map")
                        Text(tab == .list ? "Lista" : "Mapa")
                            .font(.caption)
                    }
                    .padding()
                    .background(selectedTab == tab ? Color.blue.opacity(0.2) : Color.clear)
                    .cornerRadius(10)
                }
                .foregroundColor(selectedTab == tab ? .blue : .primary)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 8)
        .background(Color(UIColor.systemGray6))
        .shadow(radius: 2)
    }
}
