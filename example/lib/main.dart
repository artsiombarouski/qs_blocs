import 'package:flutter/material.dart';
import 'package:qs_blocs_example/fetch.page.2.dart';
import 'package:qs_blocs_example/fetch.page.dart';
import 'package:qs_blocs_example/home.page.dart';
import 'package:qs_blocs_example/list.page.2.dart';
import 'package:qs_blocs_example/list.page.dart';
import 'package:qs_navigation/nav.dart';

final appRoutes = Nav(children: [
  Nav(
    name: 'home',
    path: '/',
    isHomePage: true,
    builder: (context) => const HomePage(),
  ),
  Nav(
    name: 'fetch',
    path: '/fetch',
    builder: (context) => const FetchPage(),
  ),
  Nav(
    name: 'fetch2',
    path: '/fetch2',
    builder: (context) => const FetchPage2(),
  ),
  Nav(
    name: 'list',
    path: '/list',
    builder: (context) => const ListPage(),
  ),
  Nav(
    name: 'list2',
    path: '/list2',
    builder: (context) => const ListPage2(),
  ),
]);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late NavDelegate delegate;

  @override
  void initState() {
    delegate = NavDelegate(context: context, nav: appRoutes);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: NavInformationParser(),
      routerDelegate: delegate,
    );
  }
}
