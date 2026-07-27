import SwiftUI
import Model

/// Music 詳細画面。アートワーク・曲情報・30秒試聴・iTunes リンク。
/// NiA 相当: feature:*:impl の Screen（`TopicScreen`）。
struct MusicDetailView: View {
    @StateObject private var viewModel: MusicDetailViewModel

    init(track: MusicTrack) {
        _viewModel = StateObject(wrappedValue: MusicDetailViewModel(track: track))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                AsyncImage(
                    url: (viewModel.track.artworkUrlLarge ?? viewModel.track.artworkUrl100)
                        .flatMap { URL(string: $0) }
                ) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color(uiColor: .systemGray5)
                }
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 40)

                Text(viewModel.track.trackName ?? L("music.detail.unknown_title"))
                    .font(.system(size: 22, weight: .bold))
                    .multilineTextAlignment(.center)

                Text(viewModel.track.artistName ?? "")
                    .font(.body)
                    .foregroundStyle(.secondary)

                Text(metaText)
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)

                if viewModel.canPreview {
                    Button(action: { viewModel.togglePreview() }) {
                        Text(viewModel.isPlaying ? L("music.detail.preview_stop") : L("music.detail.preview_play"))
                            .font(.headline)
                    }
                    .padding(.top, 12)
                }

                if let urlString = viewModel.track.trackViewUrl, let url = URL(string: urlString) {
                    Link(L("music.detail.open_itunes"), destination: url)
                        .padding(.top, 4)
                }
            }
            .padding(24)
        }
        .navigationTitle(L("music.detail.title"))
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { viewModel.stop() }
    }

    private var metaText: String {
        [
            viewModel.track.collectionName,
            viewModel.track.primaryGenreName,
            viewModel.track.releaseDateText,
            viewModel.track.durationText
        ]
        .compactMap { $0 }
        .filter { !$0.isEmpty }
        .joined(separator: " ・ ")
    }
}
