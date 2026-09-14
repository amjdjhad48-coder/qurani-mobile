import 'package:flutter/material.dart';
import 'package:qurani/features/students/application/support_program_service.dart';
import 'package:qurani/features/students/domain/support_program.dart';

class SupportProgramScreen extends StatefulWidget {
  const SupportProgramScreen({
    required this.service,
    required this.halaqahId,
    super.key,
  });

  final SupportProgramService service;
  final int halaqahId;

  @override
  State<SupportProgramScreen> createState() => _SupportProgramScreenState();
}

class _SupportProgramScreenState extends State<SupportProgramScreen> {
  final TextEditingController _organizationController = TextEditingController();

  SupportProgramState? _state;
  SupportActivationCheck? _activationCheck;

  var _loading = true;
  var _busy = false;

  String? _errorText;

  @override
  void initState() {
    super.initState();

    Future<void>.microtask(_load);
  }

  @override
  void dispose() {
    _organizationController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final state = await widget.service.getState(widget.halaqahId);

      SupportActivationCheck? check;

      if (state.isPendingActivation) {
        check = await widget.service.checkActivation(widget.halaqahId);
      }

      if (!mounted) {
        return;
      }

      _organizationController.text = state.organizationName ?? '';

      setState(() {
        _state = state;
        _activationCheck = check;
        _loading = false;
        _errorText = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _errorText = 'تعذر تحميل حالة برنامج الدعم.';
      });
    }
  }

  Future<void> _beginActivation() async {
    if (_busy) {
      return;
    }

    final organization = _organizationController.text.trim();

    if (organization.isEmpty) {
      setState(() {
        _errorText = 'اسم الجهة الداعمة مطلوب لبدء التفعيل.';
      });

      return;
    }

    setState(() {
      _busy = true;
      _errorText = null;
    });

    try {
      final state = await widget.service.beginActivation(
        halaqahId: widget.halaqahId,
        organizationName: organization,
      );

      final check = await widget.service.checkActivation(widget.halaqahId);

      if (!mounted) {
        return;
      }

      setState(() {
        _state = state;
        _activationCheck = check;
        _busy = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _errorText = 'تعذر بدء تفعيل برنامج الدعم.';
      });
    }
  }

  Future<void> _refreshActivationCheck() async {
    if (_busy) {
      return;
    }

    setState(() {
      _busy = true;
      _errorText = null;
    });

    try {
      final check = await widget.service.checkActivation(widget.halaqahId);

      if (!mounted) {
        return;
      }

      setState(() {
        _activationCheck = check;
        _state = check.state;
        _busy = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _errorText = 'تعذر فحص متطلبات تفعيل الدعم.';
      });
    }
  }

  Future<bool> _confirmActivation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          key: const Key('activate_support_dialog'),
          title: const Text('تفعيل برنامج الدعم'),
          content: const Text(
            'سيتم تفعيل برنامج الدعم وفتح فترة دعم جديدة. هل تريد المتابعة؟',
          ),
          actions: <Widget>[
            TextButton(
              key: const Key('cancel_activate_support_button'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('إلغاء'),
            ),
            FilledButton(
              key: const Key('confirm_activate_support_button'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('تأكيد التفعيل'),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  Future<void> _activate() async {
    final check = _activationCheck;

    if (_busy || check == null || !check.canActivate) {
      return;
    }

    final confirmed = await _confirmActivation();

    if (!confirmed || !mounted) {
      return;
    }

    setState(() {
      _busy = true;
      _errorText = null;
    });

    try {
      final state = await widget.service.activate(
        halaqahId: widget.halaqahId,
        confirmed: true,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _state = state;
        _activationCheck = null;
        _busy = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _errorText = 'تعذر تفعيل برنامج الدعم.';
      });
    }
  }

  Future<bool> _confirmDisable() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          key: const Key('disable_support_dialog'),
          title: const Text('تعطيل برنامج الدعم'),
          content: const Text(
            'سيتم تعطيل برنامج الدعم وإغلاق فترة الدعم الحالية. هل تريد المتابعة؟',
          ),
          actions: <Widget>[
            TextButton(
              key: const Key('cancel_disable_support_button'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('إلغاء'),
            ),
            FilledButton(
              key: const Key('confirm_disable_support_button'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('تأكيد التعطيل'),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  Future<void> _disable() async {
    if (_busy) {
      return;
    }

    final confirmed = await _confirmDisable();

    if (!confirmed || !mounted) {
      return;
    }

    setState(() {
      _busy = true;
      _errorText = null;
    });

    try {
      final state = await widget.service.disable(widget.halaqahId);

      if (!mounted) {
        return;
      }

      _organizationController.clear();

      setState(() {
        _state = state;
        _activationCheck = null;
        _busy = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _errorText = 'تعذر تعطيل برنامج الدعم.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('support_program_screen'),
      appBar: AppBar(title: const Text('برنامج الدعم'), centerTitle: true),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  key: Key('support_program_loading'),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  _buildStateCard(context),
                  const SizedBox(height: 12),
                  _buildStateActions(context),
                  if (_errorText != null) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(
                      _errorText!,
                      key: const Key('support_program_error'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildStateCard(BuildContext context) {
    final state = _state;

    if (state == null) {
      return const SizedBox.shrink();
    }

    return Card(
      key: const Key('support_program_state_card'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'حالة برنامج الدعم',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(_stateLabel(state), key: const Key('support_program_status')),
            if (state.organizationName != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                'الجهة الداعمة: '
                '${state.organizationName}',
                key: const Key('support_program_organization'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStateActions(BuildContext context) {
    final state = _state;

    if (state == null) {
      return const SizedBox.shrink();
    }

    if (state.isDisabled) {
      return Card(
        key: const Key('support_disabled_actions'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                key: const Key('support_organization_field'),
                controller: _organizationController,
                enabled: !_busy,
                decoration: const InputDecoration(
                  labelText: 'اسم الجهة الداعمة',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                key: const Key('begin_support_activation_button'),
                onPressed: _busy ? null : _beginActivation,
                icon: const Icon(Icons.play_arrow_outlined),
                label: Text(_busy ? 'جارٍ التنفيذ...' : 'بدء التفعيل'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.isPendingActivation) {
      final check = _activationCheck;

      return Card(
        key: const Key('support_pending_actions'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'متطلبات التفعيل',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              if (check == null)
                const Text('لم يتم فحص المتطلبات بعد.')
              else if (check.missingStudentNumbers.isEmpty)
                const Text(
                  'جميع الطلاب النشطين لديهم أرقام الجهة الداعمة.',
                  key: Key('support_activation_ready'),
                )
              else ...<Widget>[
                const Text(
                  'يجب استكمال أرقام الجهة الداعمة للطلاب التاليين:',
                  key: Key('support_activation_missing_title'),
                ),
                const SizedBox(height: 8),
                ...check.missingStudentNumbers.map(
                  (gap) => ListTile(
                    key: ValueKey<String>('support_gap_${gap.studentId}'),
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.warning_amber_outlined),
                    title: Text(gap.studentName),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: const Key('refresh_support_activation_check'),
                onPressed: _busy ? null : _refreshActivationCheck,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة فحص المتطلبات'),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                key: const Key('activate_support_button'),
                onPressed: _busy || check == null || !check.canActivate
                    ? null
                    : _activate,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('تفعيل برنامج الدعم'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      key: const Key('support_enabled_actions'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text('برنامج الدعم مفعل حاليًا.'),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              key: const Key('disable_support_button'),
              onPressed: _busy ? null : _disable,
              icon: const Icon(Icons.pause_circle_outline),
              label: const Text('تعطيل برنامج الدعم'),
            ),
          ],
        ),
      ),
    );
  }

  String _stateLabel(SupportProgramState state) {
    if (state.isDisabled) {
      return 'غير مفعل';
    }

    if (state.isPendingActivation) {
      return 'بانتظار استكمال التفعيل';
    }

    return 'مفعل';
  }
}
