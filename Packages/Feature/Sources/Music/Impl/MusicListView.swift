import SwiftUI
import Model

/// Music 一覧画面。検索バー（`.searchable`）＋楽曲リスト。タップで詳細へ push。
/// NiA 相当: feature:*:impl の Screen（`TopicScreen`）。
struct MusicListView: View {
    @StateObject private var viewModel = MusicListViewModel()

    var body: some View {
        NavigationView {
            content
                .navigationTitle(L("music.title"))
                .navigationBarTitleDisplayMode(.inline)
                .searchable(text: $viewModel.searchTerm, prompt: Text(L("music.search_placeholder")))
                .onSubmit(of: .search) { viewModel.search() }
        }
        .navigationViewStyle(.stack)
        .onAppear { viewModel.onAppear() }
        .alert(
            L("error.title"),
            isPresented: Binding(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.dismissError() } }
            ),
            presenting: viewModel.error
        ) { _ in
            Button("OK", role: .cancel) {}
        } message: { error in
            Text(error.localizedDescription)
        }
    }

    @ViewBuilder private var content: some View {
        if viewModel.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.tracks.isEmpty && viewModel.hasSearched {
            Text(L("music.empty"))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List(viewModel.tracks) { track in
                NavigationLink {
                    MusicDetailView(track: track)
                } label: {
                    MusicRow(track: track)
                }
            }
            .listStyle(.plain)
        }
    }
}

/// 一覧の 1 行（アートワーク＋曲名＋アーティスト）。
private struct MusicRow: View {
    let track: MusicTrack

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: track.artworkUrl100.flatMap { URL(string: $0) }) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color(uiColor: .systemGray5)
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 2) {
                Text(track.trackName ?? "")
                    .font(.body)
                    .lineLimit(1)
                Text(track.artistName ?? "")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}
