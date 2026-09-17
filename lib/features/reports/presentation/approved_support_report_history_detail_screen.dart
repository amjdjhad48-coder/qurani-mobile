import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurani/features/reports/application/support_report_history_detail.dart';
import 'package:qurani/features/reports/application/support_reports_runtime_providers.dart';
import 'package:qurani/features/reports/domain/approved_monthly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/approved_weekly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/support_reports_review.dart';
import 'package:qurani/features/reports/domain/weekly_support_report_projection.dart';

class ApprovedSupportReportHistoryDetailScreen extends ConsumerWidget {
  const ApprovedSupportReportHistoryDetailScreen({
    required this.item,
    super.key,
  });

  final SupportReportHistoryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(supportReportHistoryDetailProvider(item));

    return Scaffold(
      key: const Key('approved_support_report_history_detail_screen'),
      appBar: AppBar(
        title: Text(
          item.kind == SupportReportHistoryKind.weekly
              ? 'تقرير أسبوعي معتمد'
              : 'تقرير شهري معتمد',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: detail.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'تعذر تحميل النسخة المعتمدة.',
                    key: Key('approved_history_detail_error'),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: () {
                      ref.invalidate(supportReportHistoryDetailProvider(item));
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          ),
          data: (value) => _HistoryDetailBody(detail: value),
        ),
      ),
    );
  }
}

class _HistoryDetailBody extends StatelessWidget {
  const _HistoryDetailBody({required this.detail});

  final SupportReportHistoryDetail detail;

  @override
  Widget build(BuildContext context) {
    final item = detail.item;

    return ListView(
      key: const Key('approved_history_detail_list'),
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Card(
          key: const Key('approved_history_identity_card'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  item.kind == SupportReportHistoryKind.weekly
                      ? 'نسخة أسبوعية معتمدة للقراءة فقط'
                      : 'نسخة شهرية معتمدة للقراءة فقط',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'الفترة: ${_date(item.periodStart)}'
                  ' - ${_date(item.periodEnd)}',
                ),
                Text('المعلم: ${item.header.teacherName}'),
                Text('الحلقة: ${item.header.halaqahName}'),
                Text('الجهة: ${item.header.organizationName}'),
                Text('إصدار السياسة: ${item.header.policyVersion}'),
                Text('إصدار القالب: ${item.header.templateVersion}'),
                Text('وقت الاعتماد UTC: ${_utc(item.approvedAtUtc)}'),
                const SizedBox(height: 8),
                SelectableText(
                  'البصمة: ${item.sourceFingerprint}',
                  key: const Key('approved_history_fingerprint'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Card(
          key: Key('approved_history_read_only_notice'),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'هذه Snapshot معتمدة وغير قابلة للتعديل من شاشة التقارير. '
              'أي تصحيح جديد يتم في مصدر البيانات ثم يظهر في تقرير جارٍ '
              'أو إعادة اعتماد لاحقة وفق بوابة الاعتماد.',
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (detail.weeklySnapshot != null)
          _WeeklySnapshotBody(snapshot: detail.weeklySnapshot!)
        else
          _MonthlySnapshotBody(snapshot: detail.monthlySnapshot!),
      ],
    );
  }

  static String _date(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  static String _utc(DateTime value) {
    final utc = value.toUtc();

    return '${_date(utc)} '
        '${utc.hour.toString().padLeft(2, '0')}:'
        '${utc.minute.toString().padLeft(2, '0')}Z';
  }
}

class _WeeklySnapshotBody extends StatelessWidget {
  const _WeeklySnapshotBody({required this.snapshot});

  final ApprovedWeeklySupportReportSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('approved_weekly_history_snapshot'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'الطلاب والتفاصيل اليومية',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        ...snapshot.students.map(
          (student) => Card(
            key: Key(
              'approved_weekly_history_student_${student.sourceStudentId}',
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    student.studentName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'رقم الجهة: '
                    '${student.supportStudentNumber ?? 'غير مسجل'}',
                  ),
                  Text(
                    'الجزء الحالي: '
                    '${student.currentJuz?.toString() ?? 'غير مسجل'}',
                  ),
                  Text(
                    'الخطة اليومية: '
                    '${student.dailyPlanText ?? 'غير مسجلة'}',
                  ),
                  Text(
                    'الهدف الشهري: '
                    '${_faces(student.monthlyGoalQuarterFaces)}',
                  ),
                  if (student.note != null && student.note!.trim().isNotEmpty)
                    Text('ملاحظة: ${student.note}'),
                  const Divider(),
                  ...snapshot.days.map(
                    (day) => _dayForStudent(
                      day: day,
                      sourceStudentId: student.sourceStudentId,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dayForStudent({
    required ApprovedWeeklySupportReportDaySnapshot day,
    required int sourceStudentId,
  }) {
    final entries = day.entries
        .where((entry) => entry.sourceStudentId == sourceStudentId)
        .toList(growable: false);

    var achieved = 0;
    SupportReportAttendanceStatus? attendance;
    final ranges = <String>[];

    for (final entry in entries) {
      achieved += entry.achievedQuarterFaces;
      attendance ??= entry.attendanceStatus;

      if (entry.range != null) {
        ranges.add(_range(entry.range!));
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '${_date(day.localDate)} • ${_dayKind(day.dayKind)}\n'
        'الحضور: ${_attendance(attendance)}'
        ' • الإنجاز: ${_faces(achieved)}\n'
        'النطاق: ${ranges.isEmpty ? '—' : ranges.join('، ')}',
      ),
    );
  }

  String _dayKind(SupportReportDayKind kind) {
    return switch (kind) {
      SupportReportDayKind.normal => 'يوم عادي',
      SupportReportDayKind.holiday => 'إجازة',
      SupportReportDayKind.missing => 'بيانات مفقودة',
      SupportReportDayKind.notApplicable => 'غير منطبق',
    };
  }

  String _attendance(SupportReportAttendanceStatus? status) {
    return switch (status) {
      SupportReportAttendanceStatus.present => 'حاضر',
      SupportReportAttendanceStatus.absent => 'غائب',
      SupportReportAttendanceStatus.excusedAbsent => 'غائب بعذر',
      null => '—',
    };
  }

  String _range(SupportReportQuranRange range) {
    return '${range.startSurah}:${range.startAyah}'
        ' - ${range.endSurah}:${range.endAyah}';
  }

  String _faces(int quarterFaces) {
    final whole = quarterFaces ~/ 4;
    final rest = quarterFaces % 4;

    if (rest == 0) {
      return '$whole وجه';
    }

    if (whole == 0) {
      return '$rest/4 وجه';
    }

    return '$whole وجه و$rest/4';
  }

  String _date(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }
}

class _MonthlySnapshotBody extends StatelessWidget {
  const _MonthlySnapshotBody({required this.snapshot});

  final ApprovedMonthlySupportReportSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('approved_monthly_history_snapshot'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'الطلاب والنتيجة الشهرية',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        ...snapshot.students.map(
          (student) => Card(
            key: Key(
              'approved_monthly_history_student_${student.sourceStudentId}',
            ),
            child: ListTile(
              title: Text(student.studentName),
              subtitle: Text(
                'رقم الجهة: '
                '${student.supportStudentNumber ?? 'غير مسجل'}\n'
                'الجزء الحالي: '
                '${student.currentJuz?.toString() ?? 'غير مسجل'}\n'
                'الخطة اليومية: '
                '${student.dailyPlanText ?? 'غير مسجلة'}\n'
                'الهدف: ${_faces(student.monthlyGoalQuarterFaces)}'
                ' • الإنجاز: ${_faces(student.achievedQuarterFaces)}\n'
                'الغياب: ${student.absenceDays}'
                ' • إكمال الجزء: ${student.goalCompleted ? 'تم' : 'لم يتم'}'
                '${student.note == null || student.note!.trim().isEmpty ? '' : '\nملاحظة: ${student.note}'}',
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _faces(int quarterFaces) {
    final whole = quarterFaces ~/ 4;
    final rest = quarterFaces % 4;

    if (rest == 0) {
      return '$whole وجه';
    }

    if (whole == 0) {
      return '$rest/4 وجه';
    }

    return '$whole وجه و$rest/4';
  }
}
