import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurani/features/daily_halaqah/application/daily_halaqah_runtime_providers.dart';
import 'package:qurani/features/daily_halaqah/presentation/halaqah_day_history_screen.dart';
import 'package:qurani/features/reports/application/monthly_support_report_approval_service.dart';
import 'package:qurani/features/reports/application/monthly_support_report_review.dart';
import 'package:qurani/features/reports/application/support_reports_runtime_providers.dart';
import 'package:qurani/features/reports/domain/support_report_policy.dart';
import 'package:qurani/features/students/application/student_runtime_providers.dart';
import 'package:qurani/features/students/domain/student.dart';
import 'package:qurani/features/students/presentation/student_form_screen.dart';
import 'package:qurani/features/students/presentation/student_progress_plan_screen.dart';

class MonthlySupportReportReviewScreen extends ConsumerStatefulWidget {
  const MonthlySupportReportReviewScreen({
    required this.actionsEnabled,
    super.key,
  });

  final bool actionsEnabled;

  @override
  ConsumerState<MonthlySupportReportReviewScreen> createState() =>
      _MonthlySupportReportReviewScreenState();
}

class _MonthlySupportReportReviewScreenState
    extends ConsumerState<MonthlySupportReportReviewScreen> {
  Future<StudentRecord> _loadStudent(
    StudentRuntimeContext runtimeContext,
    int studentId,
  ) async {
    final students = await runtimeContext.service.search(
      halaqahId: runtimeContext.halaqahId,
      includeArchived: true,
    );

    for (final student in students) {
      if (student.id == studentId) {
        return student;
      }
    }

    throw StateError('Student $studentId was not found.');
  }

  Future<void> _fixStudentProfile(int studentId) async {
    try {
      final runtimeContext = await ref.read(
        studentRuntimeContextProvider.future,
      );

      final student = await _loadStudent(runtimeContext, studentId);

      final supportStatus = await runtimeContext.service
          .supportStatusForHalaqah(runtimeContext.halaqahId);

      if (!mounted) {
        return;
      }

      await Navigator.of(context).push<StudentRecord>(
        MaterialPageRoute<StudentRecord>(
          builder: (context) => StudentFormScreen(
            service: runtimeContext.service,
            halaqahId: runtimeContext.halaqahId,
            supportStatus: supportStatus,
            student: student,
          ),
        ),
      );

      if (mounted) {
        _refresh();
      }
    } catch (_) {
      _showError('تعذر فتح بيانات الطالب للتصحيح.');
    }
  }

  Future<void> _fixProgressPlan(int studentId) async {
    try {
      final runtimeContext = await ref.read(
        studentRuntimeContextProvider.future,
      );

      final initialPlan = await runtimeContext.service.getProgressPlan(
        studentId,
      );

      if (!mounted) {
        return;
      }

      await Navigator.of(context).push<StudentProgressPlanRecord>(
        MaterialPageRoute<StudentProgressPlanRecord>(
          builder: (context) => StudentProgressPlanScreen(
            service: runtimeContext.service,
            studentId: studentId,
            initialPlan: initialPlan,
          ),
        ),
      );

      if (mounted) {
        _refresh();
      }
    } catch (_) {
      _showError('تعذر فتح خطة تقدم الطالب للتصحيح.');
    }
  }

  Future<void> _openAttendanceSource() async {
    try {
      final runtimeContext = await ref.read(
        dailyHalaqahRuntimeContextProvider.future,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'صحح الحضور في مصدر يوم الحلقة، ثم أعد اعتماد الأسبوع '
            'المتأثر قبل إعادة بناء التقرير الشهري.',
          ),
        ),
      );

      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (context) =>
              HalaqahDayHistoryScreen(runtimeContext: runtimeContext),
        ),
      );

      if (mounted) {
        _refresh();
      }
    } catch (_) {
      _showError('تعذر فتح سجل أيام الحلقة.');
    }
  }

  void _refresh() {
    ref.invalidate(monthlySupportReportReviewProvider);
    ref.invalidate(supportReportsRuntimeContextProvider);
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final review = ref.watch(monthlySupportReportReviewProvider);

    return Scaffold(
      key: const Key('monthly_support_report_review_screen'),
      appBar: AppBar(
        title: const Text('التقرير الشهري'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            key: const Key('monthly_report_refresh_button'),
            tooltip: 'تحديث من الأسابيع المعتمدة',
            onPressed: widget.actionsEnabled
                ? () {
                    ref.invalidate(monthlySupportReportReviewProvider);
                  }
                : null,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: review.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'لا يمكن بناء التقرير الشهري حتى توجد أسابيع معتمدة '
                    'تسهم بأيام فعلية داخل الشهر.',
                    key: Key('monthly_report_source_unavailable'),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    key: const Key('monthly_report_retry_button'),
                    onPressed: () {
                      ref.invalidate(monthlySupportReportReviewProvider);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          ),
          data: (value) => _MonthlyReviewBody(
            review: value,
            actionsEnabled: widget.actionsEnabled,
            onFixStudentProfile: _fixStudentProfile,
            onFixProgressPlan: _fixProgressPlan,
            onOpenAttendanceSource: _openAttendanceSource,
          ),
        ),
      ),
    );
  }
}

class _MonthlyReviewBody extends StatelessWidget {
  const _MonthlyReviewBody({
    required this.review,
    required this.actionsEnabled,
    required this.onFixStudentProfile,
    required this.onFixProgressPlan,
    required this.onOpenAttendanceSource,
  });

  final MonthlySupportReportReview review;
  final bool actionsEnabled;
  final Future<void> Function(int studentId) onFixStudentProfile;
  final Future<void> Function(int studentId) onFixProgressPlan;
  final Future<void> Function() onOpenAttendanceSource;

  @override
  Widget build(BuildContext context) {
    final projection = review.projection;

    return ListView(
      key: const Key('monthly_support_report_review_list'),
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Card(
          key: const Key('monthly_report_period_card'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'الفترة: ${_date(projection.period.monthStart)}'
                  ' - ${_date(projection.period.monthEnd)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text('المعلم: ${projection.header.teacherName}'),
                Text('الحلقة: ${projection.header.halaqahName}'),
                Text('الجهة: ${projection.header.organizationName}'),
                const SizedBox(height: 8),
                Text(
                  'الأسابيع المعتمدة المساهمة: '
                  '${projection.weeklyInputs.length}',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _snapshotState(context),
        if (projection.missingItems.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          Card(
            key: const Key('monthly_report_missing_warnings'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'بيانات تحتاج مراجعة',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'التصحيح يتم في مصدر الطالب أو يوم الحلقة. '
                    'التقرير الشهري لا يعدّل Snapshot أسبوعيًا أو شهريًا.',
                  ),
                  const SizedBox(height: 10),
                  ...projection.missingItems.map(_warning),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text('الطلاب', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...projection.students.map(
          (student) => Card(
            key: Key('monthly_report_student_${student.sourceStudentId}'),
            child: ListTile(
              title: Text(student.studentName),
              subtitle: Text(
                'رقم الجهة: '
                '${student.supportStudentNumber ?? 'غير مكتمل'}\n'
                'الجزء الحالي: '
                '${student.currentJuz?.toString() ?? 'غير مكتمل'}\n'
                'الهدف: ${_faces(student.monthlyGoalQuarterFaces)}'
                ' • الإنجاز: ${_faces(student.achievedQuarterFaces)}\n'
                'أيام الغياب: ${student.absenceDays}'
                ' • إكمال الجزء: ${student.goalCompleted ? 'تم' : 'لم يتم'}',
              ),
              isThreeLine: true,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Card(
          key: Key('monthly_report_primary_artifact_gate'),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('بوابة الاعتماد النهائي'),
                SizedBox(height: 6),
                Text(
                  'الاعتماد النهائي معطل في P7. '
                  'P8 يجب أن ينشئ ملف Excel الأساسي ويعيد فتحه '
                  'ويتحقق منه قبل تثبيت الاعتماد.',
                ),
                SizedBox(height: 12),
                FilledButton(
                  key: Key('monthly_report_final_approval_button'),
                  onPressed: null,
                  child: Text('الاعتماد النهائي - متاح بعد P8'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _snapshotState(BuildContext context) {
    return switch (review.comparison.freshness) {
      MonthlySupportReportSnapshotFreshness.noApprovedSnapshot => const Card(
        key: Key('monthly_report_no_approved_snapshot'),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'لا توجد نسخة شهرية معتمدة. المعروض إسقاط مشتق فقط '
            'من الأسابيع المعتمدة.',
          ),
        ),
      ),
      MonthlySupportReportSnapshotFreshness.current => const Card(
        key: Key('monthly_report_approved_current'),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'النسخة الشهرية المعتمدة مطابقة للأسابيع المعتمدة الحالية.',
          ),
        ),
      ),
      MonthlySupportReportSnapshotFreshness.stale => const Card(
        key: Key('monthly_report_stale_warning'),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'تغيرت المدخلات الأسبوعية المعتمدة بعد الاعتماد الشهري. '
            'تبقى النسخة الشهرية السابقة محفوظة حتى إعادة اعتماد ناجحة.',
          ),
        ),
      ),
    };
  }

  Widget _warning(ReportMissingItem item) {
    final action = switch (item.field) {
      ReportMissingField.supportStudentNumber => OutlinedButton(
        onPressed: actionsEnabled
            ? () {
                onFixStudentProfile(item.studentId);
              }
            : null,
        child: const Text('تصحيح بيانات الطالب'),
      ),
      ReportMissingField.currentJuz => OutlinedButton(
        onPressed: actionsEnabled
            ? () {
                onFixProgressPlan(item.studentId);
              }
            : null,
        child: const Text('تصحيح خطة الطالب'),
      ),
      ReportMissingField.attendanceStatus => OutlinedButton(
        onPressed: actionsEnabled
            ? () {
                onOpenAttendanceSource();
              }
            : null,
        child: const Text('فتح مصدر الحضور'),
      ),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            '${item.studentName}: ${_missingLabel(item.field)}'
            '${item.localDate == null ? '' : ' - ${_date(item.localDate!)}'}',
          ),
          const SizedBox(height: 6),
          action,
        ],
      ),
    );
  }

  String _missingLabel(ReportMissingField field) {
    return switch (field) {
      ReportMissingField.supportStudentNumber => 'رقم الجهة غير مكتمل',
      ReportMissingField.currentJuz => 'الجزء الحالي غير مكتمل',
      ReportMissingField.attendanceStatus => 'حالة الحضور غير مكتملة',
    };
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
    final date = SupportReportPolicy.dateOnly(value);

    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
