import Foundation
import AVFoundation
import Model

/// Music 詳細の ViewModel。30秒試聴（`AVPlayer`）の再生/停止を管理する。
/// NiA 相当: feature:*:impl の ViewModel（`TopicViewModel`）。
final class MusicDetailViewModel: ObservableObject {
    // AVFoundation(AudioToolbox) にも `MusicTrack` があるため、モデル側を明示する。
    let track: Model.MusicTrack
    @Published private(set) var isPlaying = false

    private var player: AVPlayer?
    // MainActor でのみ更新し、deinit（nonisolated）から解除するため unsafe を明示する。
    nonisolated(unsafe) private var endObserver: NSObjectProtocol?

    init(track: Model.MusicTrack) {
        self.track = track
    }

    deinit {
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }
    }

    /// 試聴 URL があるか。
    var canPreview: Bool {
        !(track.previewUrl?.isEmpty ?? true)
    }

    func togglePreview() {
        if isPlaying {
            stop()
            return
        }
        guard let urlString = track.previewUrl, let url = URL(string: urlString) else { return }
        if player == nil {
            let newPlayer = AVPlayer(url: url)
            // 再生終了で停止状態へ戻す。
            endObserver = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: newPlayer.currentItem,
                queue: .main
            ) { [weak self] _ in
                Task { @MainActor in self?.isPlaying = false }
            }
            player = newPlayer
        }
        player?.seek(to: .zero)
        player?.play()
        isPlaying = true
    }

    /// 画面を離れる時などに試聴を止める。
    func stop() {
        player?.pause()
        isPlaying = false
    }
}
