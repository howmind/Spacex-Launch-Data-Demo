import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spacex_launch/provider/launch_service.dart';
import './pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LaunchXProvider>(
            create: (_) => LaunchXProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter LaunchX',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(title: 'Flutter LaunchX'),
      ),
    );
  }
}
