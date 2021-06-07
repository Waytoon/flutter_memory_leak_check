# flutter_memory_leak_check

It is easy to know whether a variable is correctly reclaimed by memory.

### principle:
By using the reference as the key of the weak reference, when the GC is executed, if the reference can be recycled, it will be deleted from the weak reference.

### step 1：Add debugging options

--observatory-port=50443

### step 2：Run port forwarding tool
```shell
cd forwarding_tool
go run main.go
```

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
