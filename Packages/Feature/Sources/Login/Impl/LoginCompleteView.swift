import SwiftUI
import Ui
import Model

/// ログイン完了画面。ログインボタンでの成功時のみ `LoginFlowView` から push される
/// （`onAppear` での復元セッションでは push しない）。
/// NiA 相当: feature:*:impl の Screen（`TopicScreen`）。
struct LoginCompleteView: View {
    let session: Session
    let onBack: () -> Void

    var body: some View {
        CustomNavigationBarView(
            title: L("login.complete.title"),
            showsBack: true,
            onBack: onBack
        ) {
            VStack(spacing: 16) {
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)
                    .foregroundStyle(Color.brand)
                Text(L("login.complete.message"))
                    .font(.headline)
                Text(session.email)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    LoginCompleteView(
        session: Session(email: "user@example.com", userID: "user-1"),
        onBack: {}
    )
}
