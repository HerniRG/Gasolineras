import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "Buscar"

    var body: some View {
        TextField(placeholder, text: $text)
            .padding(8)
            .background(Color.white)
            .cornerRadius(8)
            .padding(.horizontal, 8)
    }
}
