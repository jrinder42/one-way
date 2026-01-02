import Foundation
import CoreServices

class FileMonitor {
    private var streamRef: FSEventStreamRef?
    private let path: String
    private let callback: () -> Void
    
    init(path: String, callback: @escaping () -> Void) {
        self.path = path
        self.callback = callback
    }
    
    func start() {
        let pathsToWatch = [path] as CFArray
        
        var context = FSEventStreamContext(
            version: 0,
            info: Unmanaged.passUnretained(self).toOpaque(),
            retain: nil,
            release: nil,
            copyDescription: nil
        )
        
        streamRef = FSEventStreamCreate(
            nil,
            { (streamRef, clientCallBackInfo, numEvents, eventPaths, eventFlags, eventIds) in
                let monitor = Unmanaged<FileMonitor>.fromOpaque(clientCallBackInfo!).takeUnretainedValue()
                monitor.callback()
            },
            &context,
            pathsToWatch,
            FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
            1.0, // Latency in seconds
            FSEventStreamCreateFlags(kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagUseCFTypes)
        )
        
        if let stream = streamRef {
            FSEventStreamSetDispatchQueue(stream, DispatchQueue.main)
            FSEventStreamStart(stream)
        }
    }
    
    func stop() {
        if let stream = streamRef {
            FSEventStreamStop(stream)
            FSEventStreamInvalidate(stream)
            FSEventStreamRelease(stream)
            streamRef = nil
        }
    }
    
    deinit {
        stop()
    }
}
