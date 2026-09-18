import 'package:flutter/material.dart';
import 'package:tasbih_web/page/tasbih_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'yuk.Beramal',
      home: TasbihPage(),
    );
  }
}

