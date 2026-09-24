import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurani/features/daily_halaqah/application/daily_halaqah_runtime_providers.dart';
import 'package:qurani/features/daily_halaqah/presentation/halaqah_day_history_screen.dart';
import 'package:qurani/features/daily_halaqah/presentation/halaqah_day_summary_screen.dart';
import 'package:qurani/features/reports/application/package8_support_report_approval_coordinator.dart';
import 'package:qurani/features/reports/application/support_reports_runtime_providers.dart';
import 'package:qurani/features/reports/application/weekly_support_report_approval_candidate.dart';
import 'package:qurani/features/reports/application/weekly_support_report_approval_service.dart';
import 'package:qurani/features/reports/application/weekly_support_report_review.dart';
import 'package:qurani/features/reports/domain/support_report_policy.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/weekly_support_report_projection.dart';
import 'package:qurani/features/students/application/student_runtime_providers.dart';
import 'package:qurani/features/students/domain/student.dart';
import 'package:qurani/features/students/presentation/student_form_screen.dart';
import 'package:qurani/features/students/presentation/student_progress_plan_screen.dart';

typedef WeeklyReportStudentCorrection = Future<void> Function(int studentId);

typedef WeeklyReportAttendanceCorrection =
    Future<void> Function(ReportMissingItem item, int? sourceDayId);

class WeeklySupportReportReviewScreen extends ConsumerStatefulWidget {
  const WeeklySupportReportReviewScreen({
    required this.actionsEnabled,
    super.key,
  });

  final bool actionsEnabled;

  @override
  ConsumerState<WeeklySupportReportReviewScreen> createState() =>
      _WeeklySupportReportReviewScreenState();
}

class _WeeklySupportReportReviewScreenState
    extends ConsumerState<WeeklySupportReportReviewScreen> {
  bool _isApproving = false;

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

      if (!mounted) {
        return;
      }

      _refreshLiveReport();
    } catch (_) {
      _showCorrectionError('تعذر فتح بيانات الطالب للتصحيح.');
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

      if (!mounted) {
        return;
      }

      _refreshLiveReport();
    } catch (_) {
      _showCorrectionError('تعذر فتح خطة تقدم الطالب للتصحيح.');
    }
  }

  Future<void> _fixAttendance(ReportMissingItem item, int? sourceDayId) async {
    final localDate = item.localDate;

    if (localDate == null) {
      _showCorrectionError('تعذر تحديد تاريخ الحضور المطلوب تصحيحه.');
      return;
    }

    try {
      final runtimeContext = await ref.read(
        dailyHalaqahRuntimeContextProvider.future,
      );

      if (!mounted) {
        return;
      }

      if (sourceDayId != null) {
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (context) => HalaqahDaySummaryScreen(
              runtimeContext: runtimeContext,
              dayId: sourceDayId,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'لا يوجد يوم حلقة محفوظ لهذا التاريخ؛ '
              'افتح سجل الأيام للتحقق من مصدر الحضور.',
            ),
          ),
        );

        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (context) =>
                HalaqahDayHistoryScreen(runtimeContext: runtimeContext),
          ),
        );
      }

      if (!mounted) {
        return;
      }

      _refreshLiveReport();
    } catch (_) {
      _showCorrectionError('تعذر فتح مصدر الحضور للتصحيح.');
    }
  }

  Future<void> _approveReport(WeeklySupportReportReview review) async {
    if (_isApproving || !widget.actionsEnabled) {
      return;
    }

    var candidate = review.candidate;

    if (candidate.hasWarnings && !candidate.warningsConfirmed) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            key: const Key('weekly_report_warning_confirmation_dialog'),
            title: const Text('تأكيد الاعتماد مع وجود تنبيهات'),
            content: Text(
              'يوجد ${candidate.projection.missingItems.length} بندًا يحتاج مراجعة. '
              'يمكنك الرجوع لتصحيح بيانات المصدر، أو المتابعة واعتماد التقرير بالقيم الحالية.',
            ),
            actions: <Widget>[
              TextButton(
                key: const Key('weekly_report_warning_cancel_button'),
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('رجوع للتصحيح'),
              ),
              FilledButton(
                key: const Key('weekly_report_warning_confirm_button'),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('متابعة الاعتماد'),
              ),
            ],
          );
        },
      );

      if (confirmed != true || !mounted) {
        return;
      }

      candidate = WeeklySupportReportApprovalCandidate(
        projection: candidate.projection,
        sourceFingerprint: candidate.sourceFingerprint,
        warningsConfirmed: true,
      );
    }

    if (!mounted) {
      return;
    }

    setState(() => _isApproving = true);

    try {
      final reportsContext = await ref.read(
        supportReportsRuntimeContextProvider.future,
      );
      final dailyContext = await ref.read(
        dailyHalaqahRuntimeContextProvider.future,
      );

      if (reportsContext.halaqahId != dailyContext.halaqahId) {
        throw StateError(
          'Reports and daily halaqah runtime contexts do not match.',
        );
      }

      final coordinator = await ref.read(
        package8WeeklySupportReportApprovalCoordinatorProvider.future,
      );

      final outcome = await coordinator.approve(
        halaqahId: reportsContext.halaqahId,
        candidate: candidate,
        approvedAtUtc: dailyContext.clock.nowUtc(),
      );

      if (!mounted) {
        return;
      }

      final message = switch (outcome.status) {
        Package8SupportReportApprovalStatus.approved =>
          'تم اعتماد التقرير الأسبوعي وإنشاء ملف Excel الأساسي والتحقق منه.',
        Package8SupportReportApprovalStatus.warningsNotConfirmed =>
          'لم يتم الاعتماد؛ يلزم تأكيد المتابعة مع التنبيهات أولًا.',
        Package8SupportReportApprovalStatus.sourceChangedDuringPreparation =>
          'تغيرت بيانات المصدر أثناء تجهيز Excel. لم يتم الاعتماد؛ راجع التقرير وحاول مجددًا.',
        Package8SupportReportApprovalStatus.primaryArtifactNotSatisfied =>
          'تعذر التحقق من ملف Excel الأساسي. لم يتم اعتماد التقرير.',
      };

      _showCorrectionError(message);

      if (outcome.status == Package8SupportReportApprovalStatus.approved ||
          outcome.status ==
              Package8SupportReportApprovalStatus
                  .sourceChangedDuringPreparation) {
        _refreshLiveReport();
      }
    } catch (_) {
      _refreshLiveReport();
      _showCorrectionError(
        'تعذر إكمال عملية اعتماد التقرير الأسبوعي أو التحقق من نتيجتها. '
        'تم تحديث التقرير؛ تحقق من الحالة الحالية قبل إعادة المحاولة.',
      );
    } finally {
      if (mounted) {
        setState(() => _isApproving = false);
      }
    }
  }

  void _refreshLiveReport() {
    ref.invalidate(weeklySupportReportReviewProvider);
    ref.invalidate(supportReportsRuntimeContextProvider);
  }

  void _showCorrectionError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final reviewAsync = ref.watch(weeklySupportReportReviewProvider);
    final actionsEnabled = widget.actionsEnabled && !_isApproving;

    return Scaffold(
      key: const Key('weekly_support_report_review_screen'),
      appBar: AppBar(
        title: const Text('التقرير الأسبوعي'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            key: const Key('weekly_report_refresh_button'),
            tooltip: 'تحديث من بيانات المصدر',
            onPressed: actionsEnabled
                ? () {
                    ref.invalidate(weeklySupportReportReviewProvider);
                  }
                : null,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: reviewAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'تعذر بناء التقرير الأسبوعي من بيانات المصدر.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    key: const Key('weekly_report_retry_button'),
                    onPressed: () {
                      ref.invalidate(weeklySupportReportReviewProvider);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          ),
          data: (review) => WeeklySupportReportReviewView(
            review: review,
            actionsEnabled: actionsEnabled,
            approvalInProgress: _isApproving,
            onApprove: () => _approveReport(review),
            onFixStudentProfile: _fixStudentProfile,
            onFixProgressPlan: _fixProgressPlan,
            onFixAttendance: _fixAttendance,
          ),
        ),
      ),
    );
  }
}

class WeeklySupportReportReviewView extends StatelessWidget {
  const WeeklySupportReportReviewView({
    required this.review,
    required this.actionsEnabled,
    required this.approvalInProgress,
    required this.onApprove,
    required this.onFixStudentProfile,
    required this.onFixProgressPlan,
    required this.onFixAttendance,
    super.key,
  });

  final WeeklySupportReportReview review;
  final bool actionsEnabled;
  final bool approvalInProgress;
  final Future<void> Function() onApprove;
  final WeeklyReportStudentCorrection onFixStudentProfile;
  final WeeklyReportStudentCorrection onFixProgressPlan;
  final WeeklyReportAttendanceCorrection onFixAttendance;

  @override
  Widget build(BuildContext context) {
    final projection = review.projection;

    return ListView(
      key: const Key('weekly_support_report_review_list'),
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _buildPeriodCard(context, projection),
        const SizedBox(height: 12),
        _buildSnapshotStateCard(context),
        if (projection.missingItems.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          _buildWarningsCard(context, projection),
        ],
        const SizedBox(height: 12),
        Text('الطلاب', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (projection.students.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('لا يوجد طلاب ضمن نطاق الدعم في هذا الأسبوع.'),
            ),
          )
        else
          ...projection.students.map(
            (student) => _buildStudentCard(context, projection, student),
          ),
        const SizedBox(height: 12),
        _buildApprovalGateCard(context),
      ],
    );
  }

  Widget _buildPeriodCard(
    BuildContext context,
    WeeklySupportReportProjection projection,
  ) {
    return Card(
      key: const Key('weekly_report_period_card'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'الفترة: ${_dateText(projection.period.weekStart)}'
              ' - ${_dateText(projection.period.weekEnd)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Text('المعلم: ${projection.header.teacherName}'),
            Text('الحلقة: ${projection.header.halaqahName}'),
            Text(
              projection.header.reportContext == SupportReportContext.support
                  ? 'الجهة: ${projection.header.organizationName}'
                  : 'المركز/المسجد: ${projection.header.organizationName}',
            ),
            const SizedBox(height: 8),
            Text(
              'إصدار السياسة: ${projection.header.policyVersion}'
              ' | إصدار القالب: ${projection.header.templateVersion}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSnapshotStateCard(BuildContext context) {
    switch (review.comparison.freshness) {
      case WeeklySupportReportSnapshotFreshness.noApprovedSnapshot:
        return _snapshotCard(
          context,
          key: const Key('weekly_report_no_approved_snapshot'),
          icon: Icons.pending_actions_outlined,
          title: 'لا توجد نسخة معتمدة لهذا الأسبوع',
          message:
              'المعروض الآن إسقاط حي مشتق من بيانات المصدر، ولم يُنشأ Snapshot بمجرد فتح التقرير.',
        );
      case WeeklySupportReportSnapshotFreshness.current:
        return _snapshotCard(
          context,
          key: const Key('weekly_report_approved_current'),
          icon: Icons.verified_outlined,
          title: 'النسخة المعتمدة مطابقة للمصدر',
          message:
              'بصمة بيانات المصدر الحالية مطابقة للنسخة الأسبوعية المعتمدة.',
        );
      case WeeklySupportReportSnapshotFreshness.stale:
        return _snapshotCard(
          context,
          key: const Key('weekly_report_stale_warning'),
          icon: Icons.warning_amber_rounded,
          title: 'تغيرت بيانات المصدر بعد الاعتماد',
          message:
              'النسخة المعتمدة السابقة بقيت محفوظة دون تعديل. '
              'راجع التصحيحات ثم أعد الاعتماد بعد تفعيل بوابة Excel في P8.',
        );
    }
  }

  Widget _snapshotCard(
    BuildContext context, {
    required Key key,
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Card(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(message),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningsCard(
    BuildContext context,
    WeeklySupportReportProjection projection,
  ) {
    return Card(
      key: const Key('weekly_report_missing_warnings'),
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
              'التصحيح يتم في بيانات المصدر فقط، وليس داخل Snapshot التقرير.',
            ),
            const SizedBox(height: 12),
            ...projection.missingItems.map(
              (item) => _buildMissingItem(context, item),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissingItem(BuildContext context, ReportMissingItem item) {
    final date = item.localDate;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                '${item.studentName}: ${_missingFieldLabel(item.field)}'
                '${date == null ? '' : ' - ${_dateText(date)}'}',
              ),
              const SizedBox(height: 8),
              _buildCorrectionButton(item),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCorrectionButton(ReportMissingItem item) {
    switch (item.field) {
      case ReportMissingField.supportStudentNumber:
        return OutlinedButton.icon(
          key: Key('weekly_report_fix_support_number_${item.studentId}'),
          onPressed: actionsEnabled
              ? () {
                  onFixStudentProfile(item.studentId);
                }
              : null,
          icon: const Icon(Icons.badge_outlined),
          label: const Text('تصحيح رقم الجهة في بيانات الطالب'),
        );
      case ReportMissingField.currentJuz:
        return OutlinedButton.icon(
          key: Key('weekly_report_fix_current_juz_${item.studentId}'),
          onPressed: actionsEnabled
              ? () {
                  onFixProgressPlan(item.studentId);
                }
              : null,
          icon: const Icon(Icons.menu_book_outlined),
          label: const Text('تصحيح الجزء الحالي في خطة الطالب'),
        );
      case ReportMissingField.attendanceStatus:
        final date = item.localDate;
        final sourceDayId = date == null ? null : review.sourceDayIdFor(date);

        return OutlinedButton.icon(
          key: Key(
            'weekly_report_fix_attendance_${item.studentId}_'
            '${date == null ? 'unknown' : _dateKey(date)}',
          ),
          onPressed: actionsEnabled
              ? () {
                  onFixAttendance(item, sourceDayId);
                }
              : null,
          icon: const Icon(Icons.fact_check_outlined),
          label: Text(
            sourceDayId == null
                ? 'فتح سجل أيام الحلقة'
                : 'تصحيح الحضور من يوم الحلقة',
          ),
        );
    }
  }

  Widget _buildStudentCard(
    BuildContext context,
    WeeklySupportReportProjection projection,
    WeeklySupportReportStudentProjection student,
  ) {
    final achieved = projection.achievedQuarterFacesForStudent(
      student.sourceStudentId,
    );

    return Card(
      key: Key('weekly_report_student_${student.sourceStudentId}'),
      child: ExpansionTile(
        title: Text(student.studentName),
        subtitle: Text(
          projection.header.reportContext == SupportReportContext.support
              ? 'رقم الجهة: ${student.supportStudentNumber ?? 'غير مكتمل'}'
                    ' | الجزء: ${student.currentJuz?.toString() ?? 'غير مكتمل'}'
              : 'الجزء: ${student.currentJuz?.toString() ?? 'غير مكتمل'}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: <Widget>[
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              'الخطة اليومية: '
              '${student.dailyPlanText?.trim().isNotEmpty == true ? student.dailyPlanText : 'غير محددة'}',
            ),
          ),
          const SizedBox(height: 4),
          if (student.monthlyGoalQuarterFaces != null) ...<Widget>[
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'الهدف الشهري: '
                '${_facesLabel(student.monthlyGoalQuarterFaces!)}',
              ),
            ),
            const SizedBox(height: 4),
          ],
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text('إنجاز هذا الأسبوع: ${_facesLabel(achieved)}'),
          ),
          if (student.note?.trim().isNotEmpty == true) ...<Widget>[
            const SizedBox(height: 4),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text('ملاحظة الطالب: ${student.note}'),
            ),
          ],
          const Divider(height: 24),
          ...projection.days.map(
            (day) => _buildStudentDay(context, day, student.sourceStudentId),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentDay(
    BuildContext context,
    WeeklySupportReportDayProjection day,
    int studentId,
  ) {
    final entry = _entryForStudent(day, studentId);

    final recitations =
        entry?.newMemorizationEntries ??
        const <WeeklySupportReportRecitationProjection>[];

    var achievedQuarterFaces = 0;

    for (final recitation in recitations) {
      achievedQuarterFaces += recitation.achievedQuarterFaces;
    }

    final rangeText = recitations
        .map((recitation) => _rangeLabel(recitation.range))
        .join('، ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                '${_weekdayLabel(day.localDate)} '
                '${_dateText(day.localDate)}'
                ' - ${_dayKindLabel(day.dayKind)}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text('الحضور: ${_attendanceLabel(entry?.attendanceStatus)}'),
              Text('الحفظ الجديد: ${_facesLabel(achievedQuarterFaces)}'),
              if (rangeText.isNotEmpty) Text('من/إلى: $rangeText'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApprovalGateCard(BuildContext context) {
    return Card(
      key: const Key('weekly_report_primary_artifact_gate'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'بوابة الاعتماد النهائي',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            const Text(
              'سيتم إنشاء ملف Excel الأساسي من نفس بيانات التقرير، '
              'ثم إعادة فتحه والتحقق منه قبل تثبيت الاعتماد.',
            ),
            if (review.candidate.hasWarnings) ...<Widget>[
              const SizedBox(height: 8),
              const Text(
                'يوجد تنبيهات في بيانات المصدر؛ ستحتاج إلى تأكيد صريح '
                'إذا اخترت المتابعة دون تصحيحها.',
              ),
            ],
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const Key('weekly_report_final_approval_button'),
              onPressed: actionsEnabled && !approvalInProgress
                  ? () async {
                      await onApprove();
                    }
                  : null,
              icon: approvalInProgress
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.verified_outlined),
              label: Text(
                approvalInProgress
                    ? 'جارٍ إنشاء Excel والتحقق منه...'
                    : 'اعتماد التقرير وإنشاء Excel',
              ),
            ),
          ],
        ),
      ),
    );
  }

  WeeklySupportReportDayEntryProjection? _entryForStudent(
    WeeklySupportReportDayProjection day,
    int studentId,
  ) {
    for (final entry in day.entries) {
      if (entry.sourceStudentId == studentId) {
        return entry;
      }
    }

    return null;
  }

  String _missingFieldLabel(ReportMissingField field) {
    return switch (field) {
      ReportMissingField.supportStudentNumber => 'رقم الجهة الداعمة غير مكتمل',
      ReportMissingField.currentJuz => 'الجزء الحالي غير مكتمل',
      ReportMissingField.attendanceStatus => 'حالة الحضور غير مكتملة',
    };
  }

  String _dayKindLabel(SupportReportDayKind kind) {
    return switch (kind) {
      SupportReportDayKind.normal => 'يوم حلقة',
      SupportReportDayKind.holiday => 'إجازة',
      SupportReportDayKind.missing => 'بيانات اليوم مفقودة',
      SupportReportDayKind.notApplicable => 'غير منطبق',
    };
  }

  String _attendanceLabel(SupportReportAttendanceStatus? status) {
    return switch (status) {
      SupportReportAttendanceStatus.present => 'حاضر',
      SupportReportAttendanceStatus.absent => 'غائب',
      SupportReportAttendanceStatus.excusedAbsent => 'غائب بعذر',
      null => 'غير مسجل',
    };
  }

  String _weekdayLabel(DateTime date) {
    return switch (date.weekday) {
      DateTime.saturday => 'السبت',
      DateTime.sunday => 'الأحد',
      DateTime.monday => 'الاثنين',
      DateTime.tuesday => 'الثلاثاء',
      DateTime.wednesday => 'الأربعاء',
      DateTime.thursday => 'الخميس',
      DateTime.friday => 'الجمعة',
      _ => '',
    };
  }

  String _rangeLabel(SupportReportQuranRange range) {
    return 'س${range.startSurah}:آ${range.startAyah}'
        ' - س${range.endSurah}:آ${range.endAyah}';
  }

  String _facesLabel(int quarterFaces) {
    if (quarterFaces <= 0) {
      return '0 وجه';
    }

    final wholeFaces = quarterFaces ~/ 4;
    final remainder = quarterFaces % 4;

    if (remainder == 0) {
      return '$wholeFaces وجه';
    }

    if (wholeFaces == 0) {
      return '$remainder/4 وجه';
    }

    return '$wholeFaces وجه و$remainder/4';
  }

  String _dateText(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
