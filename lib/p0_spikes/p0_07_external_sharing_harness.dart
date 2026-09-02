import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qurani/p0_spikes/p0_07_external_sharing_spike.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const P007ExternalSharingHarnessApp());
}

class P007ExternalSharingHarnessApp extends StatelessWidget {
  const P007ExternalSharingHarnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: P007ExternalSharingHarnessPage(),
    );
  }
}

class P007ExternalSharingHarnessPage extends StatefulWidget {
  const P007ExternalSharingHarnessPage({super.key});

  @override
  State<P007ExternalSharingHarnessPage> createState() =>
      _P007ExternalSharingHarnessPageState();
}

class _P007ExternalSharingHarnessPageState
    extends State<P007ExternalSharingHarnessPage>
    with WidgetsBindingObserver {
  final P007ExternalSharingSpike _spike = P007ExternalSharingSpike();

  final Set<String> _writtenMarkers = <String>{};

  String _status = 'P0-07 جاهز. نفذ الأزرار بالترتيب.';

  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_refreshExternalState());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(
        Future<void>.delayed(
          const Duration(milliseconds: 350),
          _refreshExternalState,
        ),
      );
    }
  }

  Future<File> _proofFile() async {
    final directory = await getApplicationSupportDirectory();

    return File('${directory.path}/p0_07_external_sharing_proof.txt');
  }

  Future<void> _appendProofBlock(String marker, List<String> lines) async {
    if (_writtenMarkers.contains(marker)) {
      return;
    }

    final file = await _proofFile();

    await file.writeAsString(
      <String>[marker, ...lines, '---', ''].join('\n'),
      mode: FileMode.append,
      flush: true,
    );

    _writtenMarkers.add(marker);
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) {
      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      await action();
    } catch (error, stackTrace) {
      debugPrint('P0_07_HARNESS_ERROR=$error\n$stackTrace');

      if (mounted) {
        setState(() {
          _status = 'FAILED: $error';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _shareImoProbe() async {
    final result = await _spike.shareImoProbe();

    final pass =
        result.isNarrowContentShare &&
        result.bytes > 0 &&
        result.sha256.length == 64;

    await _appendProofBlock(
      pass
          ? 'P0_07_IMO_FILEPROVIDER_LAUNCH=PASS'
          : 'P0_07_IMO_FILEPROVIDER_LAUNCH=FAILED',
      <String>[
        'KIND=${result.kind}',
        'URI=${result.uri}',
        'AUTHORITY=${result.authority}',
        'SCHEME=${result.scheme}',
        'FILE_NAME=${result.fileName}',
        'BYTES=${result.bytes}',
        'SHA256=${result.sha256}',
        'DEDICATED_SHARE_CACHE=${result.dedicatedShareCache}',
        'CACHE_ROOT=${result.cacheRoot}',
        'NARROW_CONTENT_SHARE=${result.isNarrowContentShare}',
      ],
    );

    setState(() {
      _status = pass
          ? 'تم فتح المشاركة. اختر imo فقط، ثم ارجع إلى قرآني.'
          : 'فشل تحقق FileProvider قبل اختيار imo.';
    });
  }

  Future<void> _shareWhatsAppText() async {
    final result = await _spike.shareWhatsAppText();

    final pass =
        result.launched &&
        result.kind == 'whatsapp' &&
        result.action == 'android.intent.action.SEND' &&
        result.mime == 'text/plain';

    await _appendProofBlock(
      pass
          ? 'P0_07_WHATSAPP_INTENT_LAUNCH=PASS'
          : 'P0_07_WHATSAPP_INTENT_LAUNCH=FAILED',
      <String>[
        'KIND=${result.kind}',
        'ACTION=${result.action}',
        'MIME=${result.mime}',
      ],
    );

    setState(() {
      _status = pass
          ? 'تم فتح المشاركة. اختر WhatsApp فقط، ثم ارجع إلى قرآني.'
          : 'فشل إطلاق WhatsApp Intent probe.';
    });
  }

  Future<void> _openSmsComposer() async {
    final result = await _spike.openSmsComposer();

    final pass =
        result.launched &&
        result.kind == 'sms' &&
        result.action == 'android.intent.action.SENDTO' &&
        result.uriScheme == 'smsto' &&
        !result.directSendPermissionRequired;

    await _appendProofBlock(
      pass ? 'P0_07_SMS_INTENT_LAUNCH=PASS' : 'P0_07_SMS_INTENT_LAUNCH=FAILED',
      <String>[
        'KIND=${result.kind}',
        'ACTION=${result.action}',
        'URI_SCHEME=${result.uriScheme}',
        'DIRECT_SEND_PERMISSION_REQUIRED=${result.directSendPermissionRequired}',
      ],
    );

    setState(() {
      _status = pass
          ? 'افتح شاشة الرسالة فقط. لا ترسل الرسالة. ثم ارجع إلى قرآني.'
          : 'فشل إطلاق SMS Intent probe.';
    });
  }

  Future<void> _refreshExternalState() async {
    try {
      final state = await _spike.getState();

      if (state.imo.returned && state.imo.chosenComponent != null) {
        await _appendProofBlock('P0_07_IMO_RETURN=PASS', <String>[
          'RETURNED=${state.imo.returned}',
          'PAUSE_SEEN=${state.imo.pauseSeen}',
          'LAUNCH_COUNT=${state.imo.launchCount}',
          'CHOSEN_COMPONENT=${state.imo.chosenComponent}',
        ]);
      }

      if (state.whatsapp.returned && state.whatsapp.chosenComponent != null) {
        await _appendProofBlock('P0_07_WHATSAPP_RETURN=PASS', <String>[
          'RETURNED=${state.whatsapp.returned}',
          'PAUSE_SEEN=${state.whatsapp.pauseSeen}',
          'LAUNCH_COUNT=${state.whatsapp.launchCount}',
          'CHOSEN_COMPONENT=${state.whatsapp.chosenComponent}',
        ]);
      }

      if (state.sms.returned) {
        await _appendProofBlock('P0_07_SMS_RETURN=PASS', <String>[
          'RETURNED=${state.sms.returned}',
          'PAUSE_SEEN=${state.sms.pauseSeen}',
          'LAUNCH_COUNT=${state.sms.launchCount}',
        ]);
      }

      if (mounted) {
        setState(() {
          _status =
              'imo return=${state.imo.returned}, '
              'WhatsApp return=${state.whatsapp.returned}, '
              'SMS return=${state.sms.returned}';
        });
      }
    } catch (error) {
      debugPrint('P0_07_STATE_REFRESH_ERROR=$error');
    }
  }

  Future<void> _cleanupProbe() async {
    final result = await _spike.cleanupShareProbe();

    await _appendProofBlock(
      result.cleaned
          ? 'P0_07_SHARE_CACHE_CLEANUP=PASS'
          : 'P0_07_SHARE_CACHE_CLEANUP=FAILED',
      <String>[
        'EXISTED_BEFORE=${result.existedBefore}',
        'FILES_BEFORE=${result.filesBefore}',
        'DELETED=${result.deleted}',
        'EXISTS_AFTER=${result.existsAfter}',
      ],
    );

    setState(() {
      _status = result.cleaned
          ? 'تم تنظيف cache المشاركة التجريبية.'
          : 'فشل تنظيف cache المشاركة التجريبية.';
    });
  }

  Future<void> _showProof() async {
    final file = await _proofFile();
    final text = await file.exists()
        ? await file.readAsString()
        : 'NO_PROOF_YET';

    debugPrint(
      '--- P0-07 INTERNAL PROOF ---\n'
      '$text'
      '--- END P0-07 INTERNAL PROOF ---',
    );

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('P0-07 Proof'),
          content: SingleChildScrollView(child: SelectableText(text)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Qurani P0-07 External Sharing')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Text(
            'نفذ بالترتيب. لا ترسل SMS فعليًا. '
            'في نوافذ المشاركة اختر التطبيق المطلوب بالاسم.',
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : () => _run(_shareImoProbe),
            child: const Text('1. Share file — اختر imo'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _busy ? null : () => _run(_shareWhatsAppText),
            child: const Text('2. Share text — اختر WhatsApp'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _busy ? null : () => _run(_openSmsComposer),
            child: const Text('3. Open SMS — لا ترسل'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _busy ? null : () => _run(_refreshExternalState),
            child: const Text('4. Refresh return state'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _busy ? null : () => _run(_cleanupProbe),
            child: const Text('5. Cleanup share cache'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _busy ? null : () => _run(_showProof),
            child: const Text('6. Show proof'),
          ),
          const SizedBox(height: 24),
          SelectableText(_status),
        ],
      ),
    );
  }
}
