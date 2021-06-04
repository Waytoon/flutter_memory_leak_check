# flutter_memory_leak_check

A new Flutter package.

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