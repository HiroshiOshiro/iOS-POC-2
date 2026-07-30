import Testing
import Model

/// `MusicTrack` の派生プロパティ（純粋ロジック）を検証する。
struct MusicTrackTests {

    private func track(
        artworkUrl100: String? = nil,
        releaseDate: String? = nil,
        trackTimeMillis: Int = 0
    ) -> MusicTrack {
        MusicTrack(
            id: 1,
            trackName: "t",
            artistName: "a",
            collectionName: nil,
            primaryGenreName: nil,
            artworkUrl100: artworkUrl100,
            previewUrl: nil,
            trackViewUrl: nil,
            releaseDate: releaseDate,
            trackTimeMillis: trackTimeMillis
        )
    }

    // MARK: - artworkUrlLarge

    @Test("Given a 100x100 artwork URL, when artworkUrlLarge is read, then 100x100 is replaced with 600x600")
    func upgradesArtworkResolution() {
        let sut = track(artworkUrl100: "https://example.com/a/100x100bb.jpg")
        #expect(sut.artworkUrlLarge == "https://example.com/a/600x600bb.jpg")
    }

    @Test("Given nil or empty artwork, when artworkUrlLarge is read, then it is nil")
    func artworkLargeIsNilWhenMissing() {
        #expect(track(artworkUrl100: nil).artworkUrlLarge == nil)
        #expect(track(artworkUrl100: "").artworkUrlLarge == nil)
    }

    // MARK: - releaseDateText

    @Test("Given an ISO8601 release date, when releaseDateText is read, then only yyyy-MM-dd is returned")
    func trimsReleaseDate() {
        let sut = track(releaseDate: "2018-03-14T12:00:00Z")
        #expect(sut.releaseDateText == "2018-03-14")
    }

    @Test("Given a nil or too-short release date, when releaseDateText is read, then it is nil")
    func releaseDateTextIsNilWhenInvalid() {
        #expect(track(releaseDate: nil).releaseDateText == nil)
        #expect(track(releaseDate: "2018").releaseDateText == nil)
    }

    // MARK: - durationText

    @Test("Given a duration in millis, when durationText is read, then it is formatted as m:ss with zero-padded seconds")
    func formatsDuration() {
        #expect(track(trackTimeMillis: 255000).durationText == "4:15") // 4分15秒
        #expect(track(trackTimeMillis: 61000).durationText == "1:01")  // 秒はゼロ埋め
        #expect(track(trackTimeMillis: 5000).durationText == "0:05")
    }

    @Test("Given zero duration, when durationText is read, then it is nil")
    func durationTextIsNilWhenZero() {
        #expect(track(trackTimeMillis: 0).durationText == nil)
    }
}
