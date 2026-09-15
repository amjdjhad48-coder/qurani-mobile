import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qurani/features/daily_halaqah/application/daily_halaqah_runtime_providers.dart';
import 'package:qurani/features/daily_halaqah/domain/daily_halaqah.dart';
import 'package:qurani/features/daily_halaqah/presentation/attendance_status_selector.dart';
import 'package:qurani/features/parent_follow_up/application/parent_follow_up_recipient_policy.dart';
import 'package:qurani/features/parent_follow_up/domain/parent_follow_up.dart';
import 'package:qurani/features/parent_follow_up/domain/parent_follow_up_dispatch.dart';
import 'package:qurani/features/students/domain/student.dart';
import 'package:qurani/features/students/presentation/student_form_screen.dart';

class HalaqahDaySummaryScreen extends StatefulWidget {
  const HalaqahDaySummaryScreen({
    required this.runtimeContext,
    required this.dayId,
    super.key,
  });

  final DailyHalaqahRuntimeContext runtimeContext;
  final int dayId;

  @override
  State<HalaqahDaySummaryScreen> createState() =>
      _HalaqahDaySummaryScreenState();
}

class _HalaqahDaySummaryScreenState extends State<HalaqahDaySummaryScreen>
    with WidgetsBindingObserver {
  HalaqahDaySummary? _summary;
  List<_ParentFollowUpView> _followUps = const <_ParentFollowUpView>[];

  String? _errorText;

  var _loading = true;
  var _busy = false;
  int? _busyFollowUpId;

  ParentFollowUpDispatchSession? _pendingDispatchSession;
  var _launchInProgress = false;
  var _externalBackgroundSeen = false;
  var _returnPromptVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future<void>.microtask(_load);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _load({bool showSpinner = true}) async {
    if (mounted) {
      setState(() {
        if (showSpinner) {
          _loading = true;
        }

        _errorText = null;
      });
    }

    try {
      final summary = await widget.runtimeContext.readService.summary(
        halaqahId: widget.runtimeContext.halaqahId,
        dayId: widget.dayId,
      );

      final followUps = await _loadFollowUps(summary);

      if (!mounted) {
        return;
      }

      setState(() {
        _summary = summary;
        _followUps = followUps;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _errorText = 'تعذر تحميل ملخص اليوم.';
      });
    }
  }

  Future<List<_ParentFollowUpView>> _loadFollowUps(
    HalaqahDaySummary summary,
  ) async {
    final service = widget.runtimeContext.parentFollowUpService;

    if (service == null) {
      return const <_ParentFollowUpView>[];
    }

    final records = await service.listForDay(widget.dayId);
    final studentService = widget.runtimeContext.studentService;

    if (studentService == null) {
      return const <_ParentFollowUpView>[];
    }

    final students = await studentService.search(
      halaqahId: widget.runtimeContext.halaqahId,
      includeArchived: true,
    );

    final summaryStudentIds = summary.students
        .map((item) => item.student.id)
        .toSet();

    final studentsById = <int, StudentRecord>{
      for (final student in students)
        if (summaryStudentIds.contains(student.id)) student.id: student,
    };

    const policy = ParentFollowUpRecipientPolicy();

    final views = <_ParentFollowUpView>[];

    for (final record in records) {
      final student = studentsById[record.studentId];

      if (student == null) {
        continue;
      }

      final preview = await service.previewMessage(record.id);

      final recipient = policy.resolve(
        studentId: student.id,
        countryCode: student.guardianCountryCode,
        nationalNumber: student.guardianNationalNumber,
      );

      views.add(
        _ParentFollowUpView(
          record: record,
          student: student,
          preview: preview,
          recipient: recipient,
        ),
      );
    }

    views.sort((left, right) {
      if (left.record.isPending != right.record.isPending) {
        return left.record.isPending ? -1 : 1;
      }

      return left.record.id.compareTo(right.record.id);
    });

    return views;
  }

  Future<void> _setAttendance(int studentId, AttendanceStatus status) async {
    if (_busy) {
      return;
    }

    setState(() {
      _busy = true;
      _errorText = null;
    });

    try {
      final parentFollowUpService = widget.runtimeContext.parentFollowUpService;

      if (parentFollowUpService != null) {
        await parentFollowUpService.setAttendanceAndReconcileCorrection(
          halaqahId: widget.runtimeContext.halaqahId,
          dayId: widget.dayId,
          studentId: studentId,
          status: status,
        );
      } else {
        await widget.runtimeContext.service.setAttendance(
          halaqahId: widget.runtimeContext.halaqahId,
          dayId: widget.dayId,
          studentId: studentId,
          status: status,
        );
      }

      await _load(showSpinner: false);

      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _errorText = 'تعذر تعديل حالة الحضور.';
      });
    }
  }

  Future<void> _sendFollowUp(
    _ParentFollowUpView view,
    ParentFollowUpChannel channel,
  ) async {
    if (_busy) {
      return;
    }

    if (view.recipient.requiresPhoneFix) {
      await _openPhoneFix(view.student);
      return;
    }

    final dispatch = widget.runtimeContext.parentFollowUpDispatchService;

    if (dispatch == null) {
      setState(() {
        _errorText = 'خدمة إرسال متابعة الأسرة غير متاحة.';
      });
      return;
    }

    setState(() {
      _busy = true;
      _busyFollowUpId = view.record.id;
      _errorText = null;
    });

    _launchInProgress = true;
    _externalBackgroundSeen = false;

    try {
      final session = await dispatch.open(
        followUpId: view.record.id,
        student: view.student,
        channel: channel,
      );

      _launchInProgress = false;

      if (!mounted) {
        return;
      }

      setState(() {
        _pendingDispatchSession = session;
        _busy = false;
        _busyFollowUpId = null;
      });

      if (_externalBackgroundSeen &&
          WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
        unawaited(_handleExternalReturn());
      }
    } on ParentFollowUpPhoneFixRequiredException {
      _launchInProgress = false;

      if (mounted) {
        setState(() {
          _busy = false;
          _busyFollowUpId = null;
        });
      }

      await _openPhoneFix(view.student);
    } on ParentFollowUpChannelNotAllowedException {
      _launchInProgress = false;

      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _busyFollowUpId = null;
        _errorText = 'قناة الإرسال المختارة غير متاحة لهذا الرقم.';
      });
    } catch (_) {
      _launchInProgress = false;

      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _busyFollowUpId = null;
        _errorText = 'تعذر فتح تطبيق الإرسال.';
      });
    }
  }

  Future<void> _openPhoneFix(StudentRecord student) async {
    if (_busy) {
      return;
    }

    final studentService = widget.runtimeContext.studentService;

    if (studentService == null) {
      setState(() {
        _errorText = 'خدمة تعديل بيانات الطالب غير متاحة.';
      });
      return;
    }

    setState(() {
      _busy = true;
      _errorText = null;
    });

    String supportStatus;

    try {
      supportStatus = await studentService.supportStatusForHalaqah(
        widget.runtimeContext.halaqahId,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _errorText = 'تعذر فتح تعديل رقم ولي الأمر.';
      });

      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _busy = false;
    });

    final saved = await Navigator.of(context).push<StudentRecord>(
      MaterialPageRoute<StudentRecord>(
        builder: (_) => StudentFormScreen(
          service: studentService,
          halaqahId: widget.runtimeContext.halaqahId,
          supportStatus: supportStatus,
          student: student,
        ),
      ),
    );

    if (!mounted || saved == null) {
      return;
    }

    await _load(showSpinner: false);
  }

  Future<void> _handleExternalReturn() async {
    if (!mounted || _returnPromptVisible || !_externalBackgroundSeen) {
      return;
    }

    final session = _pendingDispatchSession;

    if (session == null) {
      return;
    }

    final dispatch = widget.runtimeContext.parentFollowUpDispatchService;

    if (dispatch == null) {
      return;
    }

    _returnPromptVisible = true;

    final didSend = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            key: const Key('parent_follow_up_return_confirmation_dialog'),
            title: const Text('تأكيد الإرسال'),
            content: const Text('هل أتممت إرسال الرسالة؟'),
            actions: <Widget>[
              TextButton(
                key: const Key('parent_follow_up_return_no_button'),
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text('لا'),
              ),
              FilledButton(
                key: const Key('parent_follow_up_return_yes_button'),
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
                child: const Text('نعم'),
              ),
            ],
          ),
        );
      },
    );

    _returnPromptVisible = false;

    if (!mounted || didSend == null) {
      return;
    }

    setState(() {
      _busy = true;
      _busyFollowUpId = session.payload.followUpId;
      _errorText = null;
    });

    try {
      await dispatch.confirmReturn(session: session, didSend: didSend);

      _pendingDispatchSession = null;
      _externalBackgroundSeen = false;

      await _load(showSpinner: false);

      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _busyFollowUpId = null;
      });
    } catch (_) {
      _pendingDispatchSession = null;
      _externalBackgroundSeen = false;

      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _busyFollowUpId = null;
        _errorText = 'تعذر تسجيل نتيجة الإرسال. بقيت المتابعة دون تأكيد.';
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (_externalBackgroundSeen && _pendingDispatchSession != null) {
          unawaited(_handleExternalReturn());
        }
        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (_launchInProgress || _pendingDispatchSession != null) {
          _externalBackgroundSeen = true;
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('halaqah_day_summary_screen'),
      appBar: AppBar(title: const Text('ملخص اليوم'), centerTitle: true),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(key: Key('day_summary_loading')),
      );
    }

    final summary = _summary;

    if (summary == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                _errorText ?? 'تعذر تحميل ملخص اليوم.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: _load,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    final counts = summary.attendance;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: <Widget>[
        Text(
          summary.day.dayDate,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          _dayStatusLabel(summary.day),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: <Widget>[
                Text('الإجمالي: ${counts.totalStudents}'),
                Text('حاضر: ${counts.presentCount}'),
                Text('غائب: ${counts.absentCount}'),
                Text('بعذر: ${counts.excusedAbsentCount}'),
                if (counts.unsetCount > 0)
                  Text('غير محدد: ${counts.unsetCount}'),
              ],
            ),
          ),
        ),
        if (_errorText != null) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            _errorText!,
            key: const Key('day_summary_error'),
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        ..._buildParentFollowUpSection(),
        const SizedBox(height: 12),
        if (summary.day.isHoliday)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'هذا اليوم إجازة، ولا يُحسب أي طالب غائبًا.',
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ...summary.students.map(
            (item) => Card(
              key: ValueKey<String>('day_summary_student_${item.student.id}'),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      item.student.studentName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    AttendanceStatusSelector(
                      value: item.attendanceStatus,
                      keyPrefix: 'summary_student_${item.student.id}',
                      onChanged: _busy
                          ? null
                          : (status) {
                              unawaited(
                                _setAttendance(item.student.id, status),
                              );
                            },
                    ),
                    if (item.isAttendanceUnset) ...<Widget>[
                      const SizedBox(height: 8),
                      const Text('لم تحدد حالة الحضور بعد.'),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildParentFollowUpSection() {
    if (widget.runtimeContext.parentFollowUpService == null) {
      return const <Widget>[];
    }

    return <Widget>[
      const SizedBox(height: 20),
      Text(
        'متابعة الأسرة',
        key: const Key('parent_follow_up_section_title'),
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 8),
      if (_followUps.isEmpty)
        const Card(
          key: Key('parent_follow_up_empty'),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'لا توجد متابعات أسرية لهذا اليوم.',
              textAlign: TextAlign.center,
            ),
          ),
        )
      else
        ..._followUps.map(_buildParentFollowUpCard),
    ];
  }

  Widget _buildParentFollowUpCard(_ParentFollowUpView view) {
    final record = view.record;
    final snapshot = record.handledSnapshot;

    return Card(
      key: ValueKey<String>('parent_follow_up_card_${record.id}'),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    view.student.studentName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  record.isHandled ? 'تمت المعالجة' : 'بانتظار الإرسال',
                  key: ValueKey<String>(
                    record.isHandled
                        ? 'parent_follow_up_handled_${record.id}'
                        : 'parent_follow_up_pending_${record.id}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(_followUpTypeLabel(record.type)),
            const SizedBox(height: 10),
            SelectableText(
              view.preview,
              key: ValueKey<String>('parent_follow_up_preview_${record.id}'),
            ),
            if (record.isHandled && snapshot != null) ...<Widget>[
              const SizedBox(height: 12),
              Text('القناة: ${_channelLabel(snapshot.channel)}'),
              const SizedBox(height: 4),
              Text(
                'المستلم: ${snapshot.recipient}',
                textDirection: TextDirection.ltr,
              ),
            ],
            if (record.isPending) ...<Widget>[
              const SizedBox(height: 14),
              if (view.recipient.requiresPhoneFix) ...<Widget>[
                const Text(
                  'رقم ولي الأمر يحتاج إلى تصحيح قبل الإرسال.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  key: ValueKey<String>(
                    'parent_follow_up_fix_phone_${record.id}',
                  ),
                  onPressed: _busy
                      ? null
                      : () {
                          unawaited(_openPhoneFix(view.student));
                        },
                  child: const Text('إصلاح رقم ولي الأمر'),
                ),
              ] else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: <Widget>[
                    for (final channel in view.recipient.allowedChannels)
                      FilledButton.tonal(
                        key: ValueKey<String>(
                          'parent_follow_up_send_'
                          '${_channelKey(channel)}_'
                          '${record.id}',
                        ),
                        onPressed: _busy
                            ? null
                            : () {
                                unawaited(_sendFollowUp(view, channel));
                              },
                        child: Text(
                          _busyFollowUpId == record.id
                              ? 'جارٍ الفتح...'
                              : 'إرسال عبر '
                                    '${_channelLabel(channel)}',
                        ),
                      ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }

  String _followUpTypeLabel(ParentFollowUpType type) {
    return switch (type) {
      ParentFollowUpType.daily => 'متابعة يومية',
      ParentFollowUpType.attendanceCorrection => 'تصحيح حضور',
    };
  }

  String _channelLabel(ParentFollowUpChannel channel) {
    return switch (channel) {
      ParentFollowUpChannel.sms => 'SMS',
      ParentFollowUpChannel.whatsapp => 'واتساب',
    };
  }

  String _channelKey(ParentFollowUpChannel channel) {
    return switch (channel) {
      ParentFollowUpChannel.sms => 'sms',
      ParentFollowUpChannel.whatsapp => 'whatsapp',
    };
  }

  String _dayStatusLabel(HalaqahDayRecord day) {
    if (day.isHoliday) {
      return 'إجازة';
    }

    if (day.isClosed) {
      return 'يوم منتهٍ';
    }

    return 'يوم جارٍ';
  }
}

final class _ParentFollowUpView {
  const _ParentFollowUpView({
    required this.record,
    required this.student,
    required this.preview,
    required this.recipient,
  });

  final ParentFollowUpRecord record;
  final StudentRecord student;
  final String preview;
  final ParentFollowUpRecipientResolution recipient;
}
