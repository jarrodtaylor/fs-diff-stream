FSDiffStream
============
Watch for MacOS (v13+) file system changes from your Swift app.

Installation
------------
Add FSDiffStream as a dependency to your `Package.swift` manifest:

```swift
let package = Package(
  ...
  dependencies: [
    .package(url: "https://github.com/jarrodtaylor/fs-diff-stream.git", from: "1.0.0")
  ],
  ...
  targets: [
    .target(name: "...", dependencies: [
      .product(name: "FSDiffStream", package: "fs-diff-stream")
    ]),
  ]
  ...
)
```

Watching for Changes
--------------------

Import `FSDiffStream` and give it a local url to watch:

```swift
import FSDiffStream

let url = URL(string: "path/to/watch", relativeTo: URL.currentDirectory())!

FSDiffStream(url) { diff in print(diff) }

// Keep the process running while waiting for file system changes.
RunLoop.current.run()
```

Each time a file or folder is created, updated, or deleted under `path/to/watch`
an array of changes will stream back to your code.

Changes in the array are tuples containing a url and change status:

```swift
[
  (url: ..., status: .created),
  (url: ..., status: .updated),
  (url: ..., status: .deleted)
]
```