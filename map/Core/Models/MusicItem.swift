import Foundation

struct MusicItem: Identifiable, Equatable {
    let id: String
    let title: String
    let artistName: String
    let artworkURL: URL?
}
