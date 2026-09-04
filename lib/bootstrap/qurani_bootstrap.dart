import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurani/app/qurani_app.dart';

class QuraniRoot extends StatelessWidget {
  const QuraniRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(child: QuraniApp());
  }
}

Future<void> bootstrapQurani() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QuraniRoot());
}
