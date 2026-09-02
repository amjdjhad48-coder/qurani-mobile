import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qurani/p0_spikes/p0_06_saf_spike.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const P006SafHarnessApp());
}

class P006SafHarnessApp extends StatelessWidget {
  const P006SafHarnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: P006SafHarnessScreen(),
    );
  }
}

class P006SafHarnessScreen extends StatefulWidget {
  const P006SafHarnessScreen({super.key});

  @override
  State<P006SafHarnessScreen> createState() => _P006SafHarnessScreenState();
}

class _P006SafHarnessScreenState extends State<P006SafHarnessScreen> {
  final P006SafProbe _probe = P006SafProbe();

  bool _busy = false;
  String _status = 'P0-06 SAF harness ready.';

  Future<void> _saveXlsx() async {
    await _run(label: 'XLSX', action: _probe.saveReportXlsx);
  }

  Future<void> _saveQrb() async {
    await _run(label: 'QRB', action: _probe.saveQrbProbe);
  }

  Future<void> _cancelProbe() async {
    await _run(
      label: 'CANCEL',
      action: _probe.startCancellationProbe,
      expectCancellation: true,
    );
  }

  Future<void> _run({
    required String label,
    required Future<P006SafResult> Function() action,
    bool expectCancellation = false,
  }) async {
    if (_busy) {
      return;
    }

    setState(() {
      _busy = true;
      _status = 'Opening Android Storage Access Framework...';
    });

    String evidence;

    try {
      final result = await action();

      if (expectCancellation) {
        evidence = result.isCancelled
            ? 'P0_06_SAF_CANCEL=PASS\n'
                  'STATUS=cancelled\n'
                  'NAME=${result.suggestedName}'
            : 'P0_06_SAF_CANCEL=FAILED\n'
                  'STATUS=${result.status}\n'
                  'URI=${result.uri}';
      } else if (result.isSaved) {
        evidence =
            'P0_06_${label}_SAF_SAVE=PASS\n'
            'STATUS=saved\n'
            'URI=${result.uri}\n'
            'BYTES=${result.bytes}\n'
            'REOPENED_BYTES=${result.reopenedBytes}\n'
            'SHA256=${result.sha256}\n'
            'REOPENED_SHA256=${result.reopenedSha256}\n'
            'ROUND_TRIP_MATCHES=${result.roundTripMatches}\n'
            'NAME=${result.suggestedName}\n'
            'MIME=${result.mimeType}';
      } else {
        evidence =
            'P0_06_${label}_SAF_SAVE=CANCELLED\n'
            'STATUS=cancelled\n'
            'NAME=${result.suggestedName}';
      }
    } catch (error, stackTrace) {
      evidence = 'P0_06_${label}_SAF_ERROR=$error\n$stackTrace';
    }

    await _appendEvidence(evidence);
    debugPrint(evidence);

    if (!mounted) {
      return;
    }

    setState(() {
      _busy = false;
      _status = evidence;
    });
  }

  Future<void> _appendEvidence(String evidence) async {
    final support = await getApplicationSupportDirectory();
    final file = File(
      '${support.path}${Platform.pathSeparator}p0_06_saf_proof.txt',
    );

    await file.writeAsString(
      '$evidence\n---\n',
      mode: FileMode.append,
      flush: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Qurani P0-06 SAF Spike')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '1) Save report.xlsx and choose Downloads.\n'
                '2) Save probe.qrb and choose Documents.\n'
                '3) Start cancellation test and press Back in the picker.',
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _busy ? null : _saveXlsx,
                child: const Text('1. Save report.xlsx'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _busy ? null : _saveQrb,
                child: const Text('2. Save probe.qrb'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _busy ? null : _cancelProbe,
                child: const Text('3. Test picker cancellation'),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(child: SelectableText(_status)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
