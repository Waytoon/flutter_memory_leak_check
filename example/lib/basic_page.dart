import 'package:flutter/material.dart';
import 'package:flutter_memory_leak_check/flutter_memory_leak_check.dart';

class BasicPage extends StatefulWidget {
  const BasicPage({Key? key}) : super(key: key);

  @override
  _BasicPageState createState() => _BasicPageState();
}

class _BasicPageState extends State<BasicPage> {
  int _counter = 0;
  List<String>? _memoryLeakList = [];

  _BasicPageState() {
    print("xxxxxx");
  }

  Future _incrementCounter() async {
    _counter++;

    switch(_counter) {
      case 1:
        print("add watch");
        globalChecker.addWatch(_memoryLeakList, remarks: "watch memoryLeakList note");
        break;
      case 2:
        print("start gc");
        globalChecker.forceGC();
        print("gc completed!");
        break;
      case 3:
        print("start check gc!");
        globalChecker.checkGC();
        break;
      case 4:
        print("Leave it empty to ensure normal memory recovery.");
        _memoryLeakList = null;
        globalChecker.forceGC();
        break;
      case 5:
        print("start check gc!");
        globalChecker.checkGC();
        _counter = 0;
        break;
    }

    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Basic tutorial"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
