import 'package:example/basic_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_memory_leak_check/flutter_memory_leak_check.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Memory Leak Check Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  _MyHomePageState() {
    print("_MyHomePageState instance");
  }

  @override
  void initState() {
    globalChecker = MemoryChecker("192.168.80.144");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    globalChecker.addWatch(this,);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  new MaterialPageRoute(builder: (context) => new BasicPage()),
                );
              },
              child: const Text('Basic'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    print("_MyHomePageState dispose");
    super.dispose();
  }
}
