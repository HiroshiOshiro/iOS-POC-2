import Foundation
import FactoryKit
import Model
import Domain

/// Music 一覧の ViewModel。iTunes Search API で楽曲を検索して保持する。
/// NiA 相当: feature:*:impl の ViewModel（`TopicViewModel`）。
@MainActor
final class MusicListViewModel: ObservableObject {
    @Published var searchTerm = "J-POP"
    @Published private(set) var tracks: [MusicTrack] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: MusicError?
    @Published private(set) var hasSearched = false

    @Injected(\.searchMusicUseCase) private var searchMusicUseCase

    /// 初回表示で既定語（J-POP）で検索する。
    func onAppear() {
        guard !hasSearched else { return }
        search()
    }

    func search() {
        let term = searchTerm.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else { return }
        isLoading = true
        error = nil
        Task { [weak self] in
            guard let self else { return }
            do {
                self.tracks = try await self.searchMusicUseCase.execute(term: term)
            } catch let failure as MusicFailure {
                // どの段で失敗したか（MusicFailure）で表示を切り替える。
                self.tracks = []
                self.error = switch failure {
                case .offline:  .offline
                case .network:  .network
                case .server:   .server
                case .decoding: .decoding
                }
            } catch {
                self.tracks = []
                self.error = .unknown
            }
            self.isLoading = false
            self.hasSearched = true
        }
    }

    func dismissError() {
        error = nil
    }
}
