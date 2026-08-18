import SwiftUI

/// SwiftUI 標準の `.alert` の代わりに、画面全体を覆うカスタムオーバーレイで警告を表示する。
/// API 形状は標準の `.alert(_:isPresented:presenting:actions:message:)` に合わせてあり、
/// `.alert` → `.customAlert` に置き換えるだけで移行できる。
/// `actions` が `Button` の ViewBuilder ではなく `CustomAlertAction` の配列を返す点だけが標準と違う
/// （どのボタンをタップしても自動で閉じる、という標準の挙動をこちらでも再現するため）。
public extension View {
    func customAlert<Item>(
        _ title: String,
        isPresented: Binding<Bool>,
        presenting item: Item?,
        actions: @escaping (Item) -> [CustomAlertAction],
        message: @escaping (Item) -> String
    ) -> some View {
        overlay {
            if let item, isPresented.wrappedValue {
                CustomAlertOverlay(
                    title: title,
                    message: message(item),
                    actions: actions(item),
                    isPresented: isPresented
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isPresented.wrappedValue)
    }
}

/// `customAlert` の1ボタン分の定義。タップすると自動でアラートを閉じてから `action` を実行する。
public struct CustomAlertAction {
    public enum Role {
        case `default`
        case cancel
    }

    let title: String
    let role: Role
    let action: () -> Void

    public init(_ title: String, role: Role = .default, action: @escaping () -> Void = {}) {
        self.title = title
        self.role = role
        self.action = action
    }
}

/// 画面全体を覆う背景（タップでは閉じない）＋中央カードで表示するアラート本体。
private struct CustomAlertOverlay: View {
    let title: String
    let message: String
    let actions: [CustomAlertAction]
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text(title)
                        .font(.headline)
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 8) {
                    ForEach(Array(actions.enumerated()), id: \.offset) { _, alertAction in
                        Button(alertAction.title) {
                            isPresented = false
                            alertAction.action()
                        }
                        .font(alertAction.role == .cancel ? .body : .body.weight(.semibold))
                        .foregroundStyle(alertAction.role == .cancel ? .secondary : Color.brand)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: 300)
            .background(Color(uiColor: .systemBackground), in: RoundedRectangle(cornerRadius: 14))
            .shadow(radius: 20)
            .padding(32)
        }
    }
}

#Preview {
    struct PreviewHost: View {
        @State private var isPresented = true
        var body: some View {
            Color.gray.opacity(0.2)
                .ignoresSafeArea()
                .customAlert(
                    "エラー",
                    isPresented: $isPresented,
                    presenting: isPresented ? "dummy" : nil
                ) { _ in
                    [
                        CustomAlertAction("リトライ") {},
                        CustomAlertAction("キャンセル", role: .cancel),
                    ]
                } message: { _ in
                    "通信に失敗しました。接続状況をご確認ください"
                }
        }
    }
    return PreviewHost()
}
