import SwiftUI

/// 独自ナビゲーションバー（ブランドカラー背景＋白タイトル＋白の戻るボタン）を上部に持つ
/// SwiftUI 版の画面コンテナ。ObjC 側 CustomNavigationBar と同じ見た目を SwiftUI で再現する。
struct CustomNavigationBarView<Content: View>: View {
    private let title: String
    private let showsBack: Bool
    private let onBack: (() -> Void)?
    private let content: Content

    init(
        title: String,
        showsBack: Bool = false,
        onBack: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.showsBack = showsBack
        self.onBack = onBack
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .top) {
            // ステータスバー領域まで含めてブランドカラーで塗る。
            Color.brand.ignoresSafeArea()

            VStack(spacing: 0) {
                // バー（下 44pt）
                ZStack {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                    if showsBack {
                        HStack {
                            Button(action: { onBack?() }) {
                                Image(systemName: "chevron.backward")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: 44, height: 44)
                            }
                            Spacer()
                        }
                        .padding(.leading, 4)
                    }
                }
                .frame(height: 44)
                .frame(maxWidth: .infinity)

                // コンテンツ（バーの下・白背景）
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(uiColor: .systemBackground))
            }
        }
    }
}

#Preview {
    CustomNavigationBarView(title: "確認①", showsBack: true, onBack: {}) {
        VStack(spacing: 16) {
            Spacer()
            Text("コンテンツのプレビュー")
            Spacer()
        }
    }
}
