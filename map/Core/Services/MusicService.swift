import Foundation
import MusicKit

enum MusicAuthorizationStatus {
    case authorized
    case denied
    case notDetermined
    case restricted
}

protocol MusicServiceProtocol {
    func requestAuthorization() async -> MusicAuthorizationStatus
    func checkAuthorizationStatus() -> MusicAuthorizationStatus
    func search(query: String) async -> [MusicItem]
    func playSong(title: String, artist: String) async
    func pause()
    func resume()
    func fetchLyrics(title: String, artist: String) async -> String?
    var isPlaying: Bool { get }
}

final class MusicService: MusicServiceProtocol {
    static let shared = MusicService()
    private let player = ApplicationMusicPlayer.shared
    private(set) var isPlaying = false
    private init() {}

    func checkAuthorizationStatus() -> MusicAuthorizationStatus {
        switch MusicAuthorization.currentStatus {
        case .authorized: return .authorized
        case .denied: return .denied
        case .notDetermined: return .notDetermined
        case .restricted: return .restricted
        @unknown default: return .notDetermined
        }
    }

    func requestAuthorization() async -> MusicAuthorizationStatus {
        let status = await MusicAuthorization.request()
        switch status {
        case .authorized: return .authorized
        case .denied: return .denied
        case .notDetermined: return .notDetermined
        case .restricted: return .restricted
        @unknown default: return .notDetermined
        }
    }

    func playSong(title: String, artist: String) async {
        let query = "\(title) \(artist)"
        var request = MusicCatalogSearchRequest(term: query, types: [Song.self])
        request.limit = 1

        do {
            let response = try await request.response()
            if let song = response.songs.first {
                player.queue = [song]
                player.state.repeatMode = .one
                try await player.play()
                isPlaying = true
            }
        } catch {
            isPlaying = false
        }
    }

    func pause() {
        player.pause()
        isPlaying = false
    }

    func resume() {
        Task {
            try? await player.play()
            isPlaying = true
        }
    }

    func search(query: String) async -> [MusicItem] {
        guard !query.isEmpty else { return [] }

        var request = MusicCatalogSearchRequest(term: query, types: [Song.self])
        request.limit = 20

        do {
            let response = try await request.response()
            return response.songs.map { song in
                let artworkURL = song.artwork?.url(width: 300, height: 300)
                return MusicItem(
                    id: song.id.rawValue,
                    title: song.title,
                    artistName: song.artistName,
                    artworkURL: artworkURL
                )
            }
        } catch {
            return []
        }
    }

    func fetchLyrics(title: String, artist: String) async -> String? {
        let query = "\(title) \(artist)"
        var searchRequest = MusicCatalogSearchRequest(term: query, types: [Song.self])
        searchRequest.limit = 1

        do {
            let response = try await searchRequest.response()
            guard let song = response.songs.first else { return nil }

            let url = URL(string: "https://api.music.apple.com/v1/catalog/jp/songs/\(song.id.rawValue)/lyrics")!
            let dataRequest = MusicDataRequest(urlRequest: URLRequest(url: url))
            let dataResponse = try await dataRequest.response()

            guard let ttml = String(data: dataResponse.data, encoding: .utf8) else { return nil }
            return parseTTML(ttml)
        } catch {
            return nil
        }
    }

    private func parseTTML(_ ttml: String) -> String? {
        let pattern = "<p[^>]*>(.*?)</p>"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]) else { return nil }
        let nsString = ttml as NSString
        let results = regex.matches(in: ttml, range: NSRange(location: 0, length: nsString.length))

        let lines = results.compactMap { result -> String? in
            guard result.numberOfRanges > 1 else { return nil }
            let content = nsString.substring(with: result.range(at: 1))
            let cleaned = content.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            let trimmed = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }

        guard !lines.isEmpty else { return nil }
        return lines.joined(separator: "\n")
    }
}

final class MockMusicService: MusicServiceProtocol {
    var isPlaying = false
    func checkAuthorizationStatus() -> MusicAuthorizationStatus { .authorized }
    func requestAuthorization() async -> MusicAuthorizationStatus { .authorized }
    func playSong(title: String, artist: String) async { isPlaying = true }
    func pause() { isPlaying = false }
    func resume() { isPlaying = true }
    func fetchLyrics(title: String, artist: String) async -> String? { "歌詞のサンプル\n二行目の歌詞\n三行目の歌詞" }

    func search(query: String) async -> [MusicItem] {
        [
            MusicItem(id: "1", title: "Shape of You", artistName: "Ed Sheeran", artworkURL: nil),
            MusicItem(id: "2", title: "Blinding Lights", artistName: "The Weeknd", artworkURL: nil),
            MusicItem(id: "3", title: "夜に駆ける", artistName: "YOASOBI", artworkURL: nil),
        ]
    }
}
