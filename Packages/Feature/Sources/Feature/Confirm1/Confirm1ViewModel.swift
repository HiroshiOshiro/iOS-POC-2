import Foundation

/// 確認画面1 の ViewModel（表示のみの薄い State holder）。
@MainActor
final class Confirm1ViewModel: ObservableObject {
    let text: String

    init(text: String) {
        self.text = text
    }
}
