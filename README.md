# flutter_memory_leak_check

step 1：Add debugging options
--observatory-port=50443

step 2：Run port forwarding tool
cd forwarding_tool
go run main.go

## Getting Started
```dart
// Flutter memory leak detection toolkit.

late MemoryChecker globalChecker = MemoryChecker("192.168.80.144");

let List memoryLeakList = [];
globalChecker.addWatch(memoryLeakList, remarks: "watch memoryLeakList note");

globalChecker.forceGC();

/// Will print `memoryLeakList` failed to recycle
globalChecker.checkGC();
```