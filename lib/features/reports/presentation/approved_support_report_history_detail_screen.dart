import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurani/features/reports/application/support_report_history_detail.dart';
import 'package:qurani/features/reports/application/support_report_pdf_action_service.dart';
import 'package:qurani/features/reports/application/support_report_pdf_runtime_provider.dart';
import 'package:qurani/features/reports/application/support_report_student_export_runtime_provider.dart';
import 'package:qurani/features/reports/application/support_report_student_export_service.dart';
import 'package:qurani/features/reports/application/support_report_artifact_save_service.dart';
import 'package:qurani/features/reports/application/support_reports_runtime_providers.dart';
import 'package:qurani/features/reports/domain/approved_monthly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/approved_weekly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/support_reports_review.dart';
import 'package:qurani/features/reports/domain/weekly_support_report_projection.dart';

class ApprovedSupportReportHistoryDetailScreen extends ConsumerStatefulWidget {
  const ApprovedSupportReportHistoryDetailScreen({
    required this.item,
    super.key,
  });

  final SupportReportHistoryItem item;

  @override
  ConsumerState<ApprovedSupportReportHistoryDetailScreen> createState() =>
      _ApprovedSupportReportHistoryDetailScreenState();
}

class _ApprovedSupportReportHistoryDetailScreenState
    extends ConsumerState<ApprovedSupportReportHistoryDetailScreen> {
  bool _openingExcel = false;
  bool _savingExcel = false;
  bool _sharingExcel = false;
  bool _openingPdf = false;
  bool _savingPdf = false;
  bool _sharingPdf = false;
  bool _studentExporting = false;

  bool get _artifactActionBusy =>
      _openingExcel ||
      _savingExcel ||
      _sharingExcel ||
      _openingPdf ||
      _savingPdf ||
      _sharingPdf ||
      _studentExporting;

  Future<void> _openApprovedExcel(SupportReportHistoryDetail detail) async {
    if (_artifactActionBusy) {
      return;
    }

    setState(() => _openingExcel = true);

    try {
      final service = await ref.read(
        supportReportApprovedArtifactOpenServiceProvider.future,
      );
      final halaqahId =
          detail.weeklySnapshot?.halaqahId ?? detail.monthlySnapshot?.halaqahId;

      if (halaqahId == null) {
        throw StateError('Approved history detail does not expose halaqah id.');
      }

      await service.openApprovedExcel(halaqahId: halaqahId, item: widget.item);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم فتح ملف Excel المعتمد في تطبيق خارجي.'),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذر فتح ملف Excel المعتمد. تحقق من توفر الملف ثم أعد المحاولة.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _openingExcel = false);
      }
    }
  }

  Future<void> _saveApprovedExcel(SupportReportHistoryDetail detail) async {
    if (_artifactActionBusy) {
      return;
    }

    setState(() => _savingExcel = true);

    try {
      final service = await ref.read(
        supportReportApprovedArtifactSaveServiceProvider.future,
      );
      final halaqahId =
          detail.weeklySnapshot?.halaqahId ?? detail.monthlySnapshot?.halaqahId;

      if (halaqahId == null) {
        throw StateError('Approved history detail does not expose halaqah id.');
      }

      final outcome = await service.saveApprovedExcel(
        halaqahId: halaqahId,
        item: widget.item,
      );

      if (!mounted) {
        return;
      }

      final message = outcome == SupportReportApprovedArtifactSaveOutcome.saved
          ? 'تم حفظ نسخة Excel المعتمدة بنجاح.'
          : 'تم إلغاء حفظ نسخة Excel.';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذر حفظ نسخة Excel المعتمدة. تحقق من الملف ثم أعد المحاولة.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _savingExcel = false);
      }
    }
  }

  Future<void> _shareApprovedExcel(SupportReportHistoryDetail detail) async {
    if (_artifactActionBusy) {
      return;
    }

    setState(() => _sharingExcel = true);

    try {
      final service = await ref.read(
        supportReportApprovedArtifactShareServiceProvider.future,
      );
      final halaqahId =
          detail.weeklySnapshot?.halaqahId ?? detail.monthlySnapshot?.halaqahId;

      if (halaqahId == null) {
        throw StateError('Approved history detail does not expose halaqah id.');
      }

      await service.shareApprovedExcel(halaqahId: halaqahId, item: widget.item);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم فتح قائمة المشاركة. يمكنك اختيار واتساب أو أي تطبيق مناسب.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذر مشاركة ملف Excel المعتمد. تحقق من الملف ثم أعد المحاولة.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _sharingExcel = false);
      }
    }
  }

  Future<void> _openApprovedPdf(SupportReportHistoryDetail detail) async {
    if (_artifactActionBusy) {
      return;
    }

    setState(() => _openingPdf = true);

    try {
      final service = ref.read(supportReportApprovedPdfActionServiceProvider);
      await service.openApprovedPdf(detail: detail);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إنشاء وفتح PDF من النسخة المعتمدة.')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذر إنشاء أو فتح PDF من النسخة المعتمدة. أعد المحاولة.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _openingPdf = false);
      }
    }
  }

  Future<void> _saveApprovedPdf(SupportReportHistoryDetail detail) async {
    if (_artifactActionBusy) {
      return;
    }

    setState(() => _savingPdf = true);

    try {
      final service = ref.read(supportReportApprovedPdfActionServiceProvider);
      final outcome = await service.saveApprovedPdf(detail: detail);

      if (!mounted) {
        return;
      }

      final message = outcome == SupportReportApprovedPdfSaveOutcome.saved
          ? 'تم حفظ نسخة PDF المشتقة من النسخة المعتمدة بنجاح.'
          : 'تم إلغاء حفظ نسخة PDF.';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذر حفظ نسخة PDF المشتقة من النسخة المعتمدة. أعد المحاولة.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _savingPdf = false);
      }
    }
  }

  Future<void> _shareApprovedPdf(SupportReportHistoryDetail detail) async {
    if (_artifactActionBusy) {
      return;
    }

    setState(() => _sharingPdf = true);

    try {
      final service = ref.read(supportReportApprovedPdfActionServiceProvider);
      await service.shareApprovedPdf(detail: detail);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم فتح قائمة مشاركة PDF. يمكنك اختيار واتساب أو أي تطبيق مناسب.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذر مشاركة نسخة PDF المشتقة من النسخة المعتمدة. أعد المحاولة.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _sharingPdf = false);
      }
    }
  }

  Future<void> _exportStudent(
    SupportReportHistoryDetail detail, {
    required int sourceStudentId,
    required SupportReportStudentExportFormat format,
    required SupportReportStudentExportAction action,
  }) async {
    if (_artifactActionBusy) {
      return;
    }

    final formatLabel = format == SupportReportStudentExportFormat.excel
        ? 'Excel'
        : 'PDF';

    setState(() => _studentExporting = true);

    try {
      final service = ref.read(supportReportStudentExportServiceProvider);
      final outcome = await service.exportStudent(
        detail: detail,
        sourceStudentId: sourceStudentId,
        format: format,
        action: action,
      );

      if (!mounted) {
        return;
      }

      late final String message;

      if (outcome == SupportReportStudentExportOutcome.cancelled) {
        message = 'تم إلغاء حفظ نسخة $formatLabel للطالب.';
      } else {
        message = switch (action) {
          SupportReportStudentExportAction.open =>
            'تم إنشاء وفتح $formatLabel للطالب من النسخة المعتمدة.',
          SupportReportStudentExportAction.save =>
            'تم حفظ نسخة $formatLabel للطالب بنجاح.',
          SupportReportStudentExportAction.share =>
            'تم فتح قائمة مشاركة $formatLabel للطالب.',
        };
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر تصدير ملف $formatLabel للطالب من النسخة المعتمدة. أعد المحاولة.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _studentExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
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
          data: (value) => _HistoryDetailBody(
            detail: value,
            openingExcel: _openingExcel,
            savingExcel: _savingExcel,
            sharingExcel: _sharingExcel,
            openingPdf: _openingPdf,
            savingPdf: _savingPdf,
            sharingPdf: _sharingPdf,
            artifactActionBusy: _artifactActionBusy,
            onOpenExcel: () => _openApprovedExcel(value),
            onSaveExcel: () => _saveApprovedExcel(value),
            onShareExcel: () => _shareApprovedExcel(value),
            onOpenPdf: () => _openApprovedPdf(value),
            onSavePdf: () => _saveApprovedPdf(value),
            onSharePdf: () => _shareApprovedPdf(value),
            onStudentExport: (sourceStudentId, format, action) =>
                _exportStudent(
                  value,
                  sourceStudentId: sourceStudentId,
                  format: format,
                  action: action,
                ),
          ),
        ),
      ),
    );
  }
}

class _HistoryDetailBody extends StatelessWidget {
  const _HistoryDetailBody({
    required this.detail,
    required this.openingExcel,
    required this.savingExcel,
    required this.sharingExcel,
    required this.openingPdf,
    required this.savingPdf,
    required this.sharingPdf,
    required this.artifactActionBusy,
    required this.onOpenExcel,
    required this.onSaveExcel,
    required this.onShareExcel,
    required this.onOpenPdf,
    required this.onSavePdf,
    required this.onSharePdf,
    required this.onStudentExport,
  });

  final SupportReportHistoryDetail detail;
  final bool openingExcel;
  final bool savingExcel;
  final bool sharingExcel;
  final bool openingPdf;
  final bool savingPdf;
  final bool sharingPdf;
  final bool artifactActionBusy;
  final Future<void> Function() onOpenExcel;
  final Future<void> Function() onSaveExcel;
  final Future<void> Function() onShareExcel;
  final Future<void> Function() onOpenPdf;
  final Future<void> Function() onSavePdf;
  final Future<void> Function() onSharePdf;
  final Future<void> Function(
    int sourceStudentId,
    SupportReportStudentExportFormat format,
    SupportReportStudentExportAction action,
  )
  onStudentExport;

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
                Text(
                  item.header.reportContext == SupportReportContext.support
                      ? 'الجهة: ${item.header.organizationName}'
                      : 'المركز/المسجد: ${item.header.organizationName}',
                ),
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
        Card(
          key: const Key('approved_history_primary_excel_card'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'ملف Excel الأساسي المعتمد',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                const Text(
                  'يتم التحقق من ملف الاعتماد المخزن داخليًا قبل إنشاء '
                  'نسخة مؤقتة ضيقة الصلاحية لفتحها في تطبيق خارجي.',
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  key: const Key('approved_history_open_excel_button'),
                  onPressed:
                      openingExcel ||
                          savingExcel ||
                          sharingExcel ||
                          openingPdf ||
                          savingPdf ||
                          sharingPdf ||
                          artifactActionBusy
                      ? null
                      : () async {
                          await onOpenExcel();
                        },
                  icon: openingExcel
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.open_in_new),
                  label: Text(
                    openingExcel
                        ? 'جارٍ التحقق والفتح...'
                        : 'فتح Excel المعتمد',
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  key: const Key('approved_history_save_excel_button'),
                  onPressed:
                      openingExcel ||
                          savingExcel ||
                          sharingExcel ||
                          openingPdf ||
                          savingPdf ||
                          sharingPdf ||
                          artifactActionBusy
                      ? null
                      : () async {
                          await onSaveExcel();
                        },
                  icon: savingExcel
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_alt),
                  label: Text(
                    savingExcel
                        ? 'جارٍ التحقق وفتح موقع الحفظ...'
                        : 'حفظ نسخة Excel',
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton.tonalIcon(
                  key: const Key('approved_history_share_excel_button'),
                  onPressed:
                      openingExcel ||
                          savingExcel ||
                          sharingExcel ||
                          openingPdf ||
                          savingPdf ||
                          sharingPdf ||
                          artifactActionBusy
                      ? null
                      : () async {
                          await onShareExcel();
                        },
                  icon: sharingExcel
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.share),
                  label: Text(
                    sharingExcel
                        ? 'جارٍ التحقق وفتح قائمة المشاركة...'
                        : 'مشاركة Excel',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          key: const Key('approved_history_secondary_pdf_card'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'PDF ثانوي من النسخة المعتمدة',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                const Text(
                  'يُنشأ عند الطلب من الـ Snapshot المعتمدة نفسها، ثم يُتحقق '
                  'من بنية PDF قبل الفتح أو الحفظ أو المشاركة. لا يغيّر ملف '
                  'Excel الأساسي ولا يضيف اعتمادًا جديدًا.',
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  key: const Key('approved_history_open_pdf_button'),
                  onPressed:
                      openingExcel ||
                          savingExcel ||
                          sharingExcel ||
                          openingPdf ||
                          savingPdf ||
                          sharingPdf ||
                          artifactActionBusy
                      ? null
                      : () async {
                          await onOpenPdf();
                        },
                  icon: openingPdf
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.picture_as_pdf),
                  label: Text(
                    openingPdf ? 'جارٍ إنشاء وفتح PDF...' : 'فتح PDF',
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  key: const Key('approved_history_save_pdf_button'),
                  onPressed:
                      openingExcel ||
                          savingExcel ||
                          sharingExcel ||
                          openingPdf ||
                          savingPdf ||
                          sharingPdf ||
                          artifactActionBusy
                      ? null
                      : () async {
                          await onSavePdf();
                        },
                  icon: savingPdf
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_alt),
                  label: Text(
                    savingPdf
                        ? 'جارٍ إنشاء PDF وفتح موقع الحفظ...'
                        : 'حفظ نسخة PDF',
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton.tonalIcon(
                  key: const Key('approved_history_share_pdf_button'),
                  onPressed:
                      openingExcel ||
                          savingExcel ||
                          sharingExcel ||
                          openingPdf ||
                          savingPdf ||
                          sharingPdf ||
                          artifactActionBusy
                      ? null
                      : () async {
                          await onSharePdf();
                        },
                  icon: sharingPdf
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.share),
                  label: Text(
                    sharingPdf
                        ? 'جارٍ إنشاء PDF وفتح قائمة المشاركة...'
                        : 'مشاركة PDF',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _StudentExportCard(
          detail: detail,
          busy: artifactActionBusy,
          onExport: onStudentExport,
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

final class _StudentExportChoice {
  const _StudentExportChoice({
    required this.sourceStudentId,
    required this.studentName,
  });

  final int sourceStudentId;
  final String studentName;
}

List<_StudentExportChoice> _studentExportChoices(
  SupportReportHistoryDetail detail,
) {
  final weekly = detail.weeklySnapshot;

  if (weekly != null) {
    return weekly.students
        .map(
          (student) => _StudentExportChoice(
            sourceStudentId: student.sourceStudentId,
            studentName: student.studentName,
          ),
        )
        .toList(growable: false);
  }

  return detail.monthlySnapshot!.students
      .map(
        (student) => _StudentExportChoice(
          sourceStudentId: student.sourceStudentId,
          studentName: student.studentName,
        ),
      )
      .toList(growable: false);
}

class _StudentExportCard extends StatefulWidget {
  const _StudentExportCard({
    required this.detail,
    required this.busy,
    required this.onExport,
  });

  final SupportReportHistoryDetail detail;
  final bool busy;
  final Future<void> Function(
    int sourceStudentId,
    SupportReportStudentExportFormat format,
    SupportReportStudentExportAction action,
  )
  onExport;

  @override
  State<_StudentExportCard> createState() => _StudentExportCardState();
}

class _StudentExportCardState extends State<_StudentExportCard> {
  int? _selectedStudentId;

  @override
  void initState() {
    super.initState();
    final choices = _studentExportChoices(widget.detail);
    _selectedStudentId = choices.isEmpty ? null : choices.first.sourceStudentId;
  }

  Future<void> _run(
    SupportReportStudentExportFormat format,
    SupportReportStudentExportAction action,
  ) async {
    final sourceStudentId = _selectedStudentId;

    if (sourceStudentId == null || widget.busy) {
      return;
    }

    await widget.onExport(sourceStudentId, format, action);
  }

  @override
  Widget build(BuildContext context) {
    final choices = _studentExportChoices(widget.detail);
    final enabled = !widget.busy && _selectedStudentId != null;

    return Card(
      key: const Key('approved_history_student_export_card'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'تصدير طالب واحد',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            const Text(
              'يُشتق الملف مؤقتًا من الـ Snapshot المعتمدة نفسها بعد تصفيتها '
              'للطالب المحدد فقط. لا يُنشئ تقريرًا جديدًا ولا يغيّر الاعتماد.',
            ),
            const SizedBox(height: 12),
            if (choices.isEmpty)
              const Text('لا يوجد طلاب في هذه النسخة المعتمدة.')
            else
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'الطالب',
                  border: OutlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    key: const Key('approved_history_student_export_selector'),
                    value: _selectedStudentId,
                    isExpanded: true,
                    items: choices
                        .map(
                          (choice) => DropdownMenuItem<int>(
                            value: choice.sourceStudentId,
                            child: Text(choice.studentName),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: widget.busy
                        ? null
                        : (value) {
                            setState(() => _selectedStudentId = value);
                          },
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Text('Excel', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                OutlinedButton.icon(
                  key: const Key(
                    'approved_history_student_export_excel_open_button',
                  ),
                  onPressed: enabled
                      ? () => _run(
                          SupportReportStudentExportFormat.excel,
                          SupportReportStudentExportAction.open,
                        )
                      : null,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('فتح'),
                ),
                OutlinedButton.icon(
                  key: const Key(
                    'approved_history_student_export_excel_save_button',
                  ),
                  onPressed: enabled
                      ? () => _run(
                          SupportReportStudentExportFormat.excel,
                          SupportReportStudentExportAction.save,
                        )
                      : null,
                  icon: const Icon(Icons.save_alt),
                  label: const Text('حفظ'),
                ),
                OutlinedButton.icon(
                  key: const Key(
                    'approved_history_student_export_excel_share_button',
                  ),
                  onPressed: enabled
                      ? () => _run(
                          SupportReportStudentExportFormat.excel,
                          SupportReportStudentExportAction.share,
                        )
                      : null,
                  icon: const Icon(Icons.share),
                  label: const Text('مشاركة'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('PDF', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                OutlinedButton.icon(
                  key: const Key(
                    'approved_history_student_export_pdf_open_button',
                  ),
                  onPressed: enabled
                      ? () => _run(
                          SupportReportStudentExportFormat.pdf,
                          SupportReportStudentExportAction.open,
                        )
                      : null,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('فتح'),
                ),
                OutlinedButton.icon(
                  key: const Key(
                    'approved_history_student_export_pdf_save_button',
                  ),
                  onPressed: enabled
                      ? () => _run(
                          SupportReportStudentExportFormat.pdf,
                          SupportReportStudentExportAction.save,
                        )
                      : null,
                  icon: const Icon(Icons.save_alt),
                  label: const Text('حفظ'),
                ),
                OutlinedButton.icon(
                  key: const Key(
                    'approved_history_student_export_pdf_share_button',
                  ),
                  onPressed: enabled
                      ? () => _run(
                          SupportReportStudentExportFormat.pdf,
                          SupportReportStudentExportAction.share,
                        )
                      : null,
                  icon: const Icon(Icons.share),
                  label: const Text('مشاركة'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
                  if (snapshot.header.reportContext ==
                      SupportReportContext.support)
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
                  if (student.monthlyGoalQuarterFaces != null)
                    Text(
                      'الهدف الشهري: '
                      '${_faces(student.monthlyGoalQuarterFaces!)}',
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
                student.monthlyGoalQuarterFaces == null
                    ? 'الجزء الحالي: '
                          '${student.currentJuz?.toString() ?? 'غير مسجل'}\n'
                          'الخطة اليومية: '
                          '${student.dailyPlanText ?? 'غير مسجلة'}\n'
                          'الإنجاز: ${_faces(student.achievedQuarterFaces)}\n'
                          'الغياب: ${student.absenceDays}'
                          '${student.note == null || student.note!.trim().isEmpty ? '' : '\nملاحظة: ${student.note}'}'
                    : 'رقم الجهة: '
                          '${student.supportStudentNumber ?? 'غير مسجل'}\n'
                          'الجزء الحالي: '
                          '${student.currentJuz?.toString() ?? 'غير مسجل'}\n'
                          'الخطة اليومية: '
                          '${student.dailyPlanText ?? 'غير مسجلة'}\n'
                          'الهدف: ${_faces(student.monthlyGoalQuarterFaces!)}'
                          ' • الإنجاز: ${_faces(student.achievedQuarterFaces)}\n'
                          'الغياب: ${student.absenceDays}'
                          ' • إكمال الجزء: '
                          '${student.goalCompleted == true ? 'تم' : 'لم يتم'}'
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
