import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qs_navigation/nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: () => context.nav('/fetch'),
            child: const Text('Fetch example'),
          ),
          ElevatedButton(
            onPressed: () => context.nav('/fetch2'),
            child: const Text('Fetch (with error)'),
          ),
          ElevatedButton(
            onPressed: () => context.nav('/list'),
            child: const Text('List example'),
          ),
          ElevatedButton(
            onPressed: () => context.nav('/list2'),
            child: const Text('List (with error)'),
          ),
        ],
      ),
    );
  }
}
