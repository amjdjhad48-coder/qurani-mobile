import 'package:flutter/material.dart';
import 'package:qurani/app/widgets/developer_footer.dart';
import 'package:qurani/features/setup/presentation/initial_setup_gate.dart';

class QuraniApp extends StatelessWidget {
  const QuraniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'قرآني',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF176B35)),
        scaffoldBackgroundColor: const Color(0xFFF8FAF9),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: <Widget>[
              Expanded(child: child ?? const SizedBox.shrink()),
              const DeveloperFooter(),
            ],
          ),
        );
      },
      home: const InitialSetupGate(),
    );
  }
}
