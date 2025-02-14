import Foundation

public enum Status: String
  {case created, updated, deleted}

public typealias Callback = ([(url: URL, status: Status)]) -> Void

typealias Diff = (url: URL, since: Date, callback: Callback)

public struct FSDiffStream {
  nonisolated(unsafe) static var diffs: [ConstFSEventStreamRef: Diff] = [:]

  let callback: FSEventStreamCallback = {(streamRef, _, numEvents, eventPaths, _, _) in
    guard let diff = FSDiffStream.diffs[streamRef] else {return}

    let bufferPointer = UnsafeBufferPointer(
      start: eventPaths.assumingMemoryBound(to: UnsafePointer<CChar>.self),
      count: numEvents)

    let diffs = (0..<numEvents)
      .map {
        URL(fileURLWithFileSystemRepresentation: bufferPointer[$0],
          isDirectory: false, relativeTo: nil)}
      .unique
      .filter {$0.lastPathComponent != ".DS_Store"}
      .map {
        var isDir: ObjCBool = true
        guard FileManager.default.fileExists(atPath: $0.path(), isDirectory: &isDir) else
          {return (url: $0, status: Status.deleted)}

        if let creationDate = $0.creationDate, creationDate > diff.since
          {return (url: $0, status: Status.created)}

        return (url: $0, status: Status.updated)}

    diff.callback(diffs)

    FSDiffStream.diffs[streamRef]!.since = Date.now
  }

  @discardableResult public init(_ url: URL, continuation: @escaping Callback) {
    let stream = FSEventStreamCreate(nil, callback, nil,
      [url.path() as NSString] as NSArray, UInt64(kFSEventStreamEventIdSinceNow), 1.0,
      FSEventStreamCreateFlags(kFSEventStreamCreateFlagFileEvents))!

    Self.diffs[stream] = (url: url, since: Date.now, callback: continuation)

    FSEventStreamSetDispatchQueue(stream, DispatchQueue.main)
    FSEventStreamStart(stream)
  }
}

extension Array where Element: Hashable {
  var unique: [Element] {Array(Set(self))}
}

extension URL {
  var creationDate: Date? {
    do { return try FileManager.default
      .attributesOfItem(atPath: path())[FileAttributeKey.creationDate] as? Date
    } catch {return nil}
  }
}