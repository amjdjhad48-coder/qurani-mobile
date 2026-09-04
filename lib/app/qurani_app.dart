import 'package:flutter/material.dart';

class QuraniApp extends StatelessWidget {
  const QuraniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'قرآني',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(child: Center(child: Text('قرآني'))),
      ),
    );
  }
}
