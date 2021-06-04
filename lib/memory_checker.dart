import 'dart:developer';

import 'package:vm_service/utils.dart';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';

import 'memory_checker_temp_prohibited_open.dart';

/// step 1：Add debugging options
/// --observatory-port=50443
///
/// step 2：Run port forwarding tool
///
class MemoryChecker {
  static MemoryChecker? _instance;

  late VmService _vmService;
  late VM vm;
  late String _mainIsolateID;
  late String _libraryID;
  late bool inProduction;

  /// ____MemoryCheckerData1, CodeLine
  Map<String, CodeLine> _checkerCodeLineMap = Map();
  int _checkerClassIndex = 0;

  Expando expando = Expando("_memory_checker_expando");

  String host;
  MemoryChecker._inner(this.host) {
    _initial();
  }

  factory MemoryChecker(String host) {
    if(_instance == null) {
      _instance = MemoryChecker._inner(host);
    }
    return _instance!;
  }

  void _initial() {
    inProduction = const bool.fromEnvironment("dart.vm.product");

    MemoryChecker._instance = this;
    Service.getInfo().then((serviceProtocolInfo) {
      Uri uri = serviceProtocolInfo.serverUri!;
      uri = uri.replace(host: host);

      String url = convertToWebSocketUrl(serviceProtocolUrl: uri).toString();
      vmServiceConnectUri(url).then((VmService vmService) async {
        //拿到vmService对象
        _vmService = vmService;
        vm = await _vmService.getVM();

        _initMainIsolateID();
        await _initLibraryID();
        print("get vm service successfully");

        // _vmService.streamListen("GC").then((event) {
        //   print("GC监听注册完毕");
        // });
        //
        // _vmService.onGCEvent
        //     .listen(onData, onDone: onDone, onError: onError, cancelOnError: false);
      });
    });
  }

  void _initMainIsolateID() {
    List<IsolateRef> isolates = vm.isolates!;
    late IsolateRef ref;

    for (var i = 0; i < isolates.length; ++i) {
      IsolateRef t = isolates[i];
      if(t.name!.contains('main')) {
        ref = t;
        break;
      }
    }
    _mainIsolateID = ref.id!;
  }

  Future<void> _initLibraryID() async {
    final Isolate isolate = await _vmService.getIsolate(_mainIsolateID);
    var libraries = isolate.libraries!;
    for (LibraryRef ref in libraries) {
      if(ref.uri!.endsWith('/memory_checker.dart')) {
        _libraryID = ref.id!;
      }
    }
  }

  Future<Instance> getExpandoDataInstance() async {
    late BoundField _dataField;
    Instance instance = await _getExpandoInstance();
    for (BoundField field in instance.fields!) {
      if (field.decl!.name == "_data") {
        _dataField = field;
        break;
      }
    }

    InstanceRef instanceRef = _dataField.value;
    Instance? dataInstance = await _getObjectByObjectId(instanceRef.id!);
    return dataInstance!;
  }

  void addWatch(dynamic value, {String? remarks}) async {
    if (inProduction) return;

    try {
      var v;
      print(v.as);
    }catch(e, s) {
      String c = "$s";
      print(c);
    }

    var codeLine = CodeLine('lib/main.dart', 69, remarks: remarks);
    var c = MemoryCheckerInstanceData.getInstance(_checkerClassIndex++);
    var className = _getClassName(c);
    _checkerCodeLineMap[className] = codeLine;

    expando[value] = c;
  }

  String _getClassName(value) {
    var v = "$value";
    RegExp reg = RegExp(r"Instance of \'([^']+)\'");
    Iterable<Match> matches = reg.allMatches(v);
    for (Match m in matches) {
      String? before = m.group(1);
      return before!;
    }
    return '';
  }

  Future<void> forceGC() async {
    String _collectAllGarbageMethodName = '_collectAllGarbage';
    await _vmService.callMethod(_collectAllGarbageMethodName, isolateId: _mainIsolateID);
  }

  Future checkGC() async {
    bool contains = false;
    var expandoDataInstance = await getExpandoDataInstance();
    List instanceRefs = expandoDataInstance.elements!;
    for (InstanceRef? instanceRef in instanceRefs) {
      if (instanceRef != null) {
        var instance = await _getObjectByObjectId(instanceRef.id);
        InstanceRef propertyValue = instance!.propertyValue!;
        if(propertyValue.valueAsString != "null") {
          contains = true;
           String className = propertyValue.classRef!.name!;
           var codeLine = _checkerCodeLineMap[className];
           print(codeLine);
        }
      }
    }
    if(contains == false) {
      print("Congratulations on the success of all recycling!");
    }
  }

  Future<Instance?> _getObjectByObjectId(String? objectId) async {
    var value = await _vmService.getObject(_mainIsolateID, objectId!);
    return value as Instance?;
  }

  Future<Instance> _getExpandoInstance() async {
    InstanceRef valueRef = await _vmService.invoke(
        _mainIsolateID,
        _libraryID,
        "getMemoryCheckerExpando",
        []
    ) as InstanceRef;
    // 这里的 id 就是 obj 对应的 id
    String? objectId = valueRef.id;
    return (await _getObjectByObjectId(objectId))!;
  }
}

class CodeLine {
  String filePath;
  int line;
  String? remarks;

  CodeLine(this.filePath, this.line, {this.remarks});

  @override
  String toString() {
    return 'Memory Leak： {filePath: `$filePath`, line: $line, remarks: $remarks}';
  }
}

Expando getMemoryCheckerExpando() {
  return MemoryChecker("").expando;
}