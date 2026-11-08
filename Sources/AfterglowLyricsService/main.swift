import Foundation
import AfterglowCore

// One bounded JSON request on stdin; one JSON result on stdout. No shell, sockets or executable lyrics.
struct Request: Decodable {
    let command: String
    let track: Track?
    let text: String?
    let fileExtension: String?
    let allowPlainFallback: Bool?
    let allowTimedFallback: Bool?
    let bypassCache: Bool?
}
struct Response: Encodable {
    let document: LyricDocument?
    let error: String?
}
let input = FileHandle.standardInput.readData(ofLength: 600_001)
var response: Response
do {
    guard input.count <= 600_000 else { throw CocoaError(.fileReadTooLarge) }
    let request = try JSONDecoder().decode(Request.self, from: input)
    switch request.command {
    case "resolve":
        guard let track = request.track, track.duration.isFinite, track.duration >= 0,
              track.title.count <= 10_000, track.artist.count <= 10_000 else {
            throw CocoaError(.coderInvalidValue)
        }
        let document = try await LyricsResolver().fetch(track,
            allowPlainFallback: request.allowPlainFallback ?? true,
            allowTimedFallback: request.allowTimedFallback ?? true,
            bypassCache: request.bypassCache ?? false)
        response = Response(document: document, error: nil)
    case "import":
        let text = request.text ?? "", ext = request.fileExtension ?? "lrc"
        let document: LyricDocument?
        if ext.lowercased() == "lrc", text.contains("<"), !EnhancedLRC.parse(text).isEmpty {
            document = .init(lines: EnhancedLRC.parse(text), source: .local)
        } else { document = ImportedLyrics.parse(text, extension: ext) }
        response = Response(document: document, error: document == nil ? "No valid lyrics in this file." : nil)
    case "demo":
        response = Response(document: .init(lines: Demo.wordTimedLines, source: .local), error: nil)
    default:
        response = Response(document: nil, error: "Unknown lyrics command.")
    }
} catch { response = Response(document: nil, error: error.localizedDescription) }
FileHandle.standardOutput.write(try JSONEncoder().encode(response))
FileHandle.standardOutput.write(Data([10]))
