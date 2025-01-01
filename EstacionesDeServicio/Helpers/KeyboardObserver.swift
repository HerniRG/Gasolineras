import SwiftUI
import Combine

final class KeyboardObserver: ObservableObject {
    @Published var isKeyboardVisible: Bool = false
    private var cancellables: Set<AnyCancellable> = []

    init() {
        let keyboardWillShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { _ in true }

        let keyboardWillHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in false }

        Publishers.Merge(keyboardWillShow, keyboardWillHide)
            .receive(on: RunLoop.main)
            .assign(to: \.isKeyboardVisible, on: self)
            .store(in: &cancellables)
    }
}
