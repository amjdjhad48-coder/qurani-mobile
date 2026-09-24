import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurani/features/reports/application/support_reports_runtime_providers.dart';
import 'package:qurani/features/reports/domain/support_reports_review.dart';
import 'package:qurani/features/reports/presentation/approved_support_report_history_detail_screen.dart';
import 'package:qurani/features/reports/presentation/monthly_support_report_review_screen.dart';
import 'package:qurani/features/reports/presentation/weekly_support_report_review_screen.dart';

class SupportReportsScreen extends ConsumerWidget {
  const SupportReportsScreen({
    required this.actionsEnabled,
    required this.onChangePin,
    required this.onLockNow,
    this.noticeText,
    super.key,
  });

  final bool actionsEnabled;
  final VoidCallback onChangePin;
  final VoidCallback onLockNow;
  final String? noticeText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runtime = ref.watch(supportReportsRuntimeContextProvider);
    return Scaffold(
      key: const Key('support_reports_screen'),
      appBar: AppBar(
        title: const Text('التقارير'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            key: const Key('change_pin_button'),
            onPressed: actionsEnabled ? onChangePin : null,
            tooltip: 'تغيير PIN',
            icon: const Icon(Icons.password_outlined),
          ),
          IconButton(
            key: const Key('lock_now_button'),
            onPressed: actionsEnabled ? onLockNow : null,
            tooltip: 'قفل التطبيق',
            icon: const Icon(Icons.lock_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: runtime.when(
          loading: () => const Center(
            child: CircularProgressIndicator(
              key: Key('reports_runtime_loading'),
            ),
          ),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'تعذر فتح بيانات التقارير.',
                    key: Key('reports_runtime_error'),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    key: const Key('reports_retry_button'),
                    onPressed: () {
                      ref.invalidate(supportReportsRuntimeContextProvider);
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          ),
          data: (value) => _ReportsGatewayBody(
            runtimeContext: value,
            noticeText: noticeText,
            actionsEnabled: actionsEnabled,
          ),
        ),
      ),
    );
  }
}

class _ReportsGatewayBody extends StatelessWidget {
  const _ReportsGatewayBody({
    required this.runtimeContext,
    required this.noticeText,
    required this.actionsEnabled,
  });
  final SupportReportsRuntimeContext runtimeContext;
  final String? noticeText;
  final bool actionsEnabled;

  @override
  Widget build(BuildContext context) {
    final history = runtimeContext.history;
    return ListView(
      key: const Key('reports_gateway_list'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: <Widget>[
        if (noticeText != null) ...<Widget>[
          Text(
            noticeText!,
            key: const Key('runtime_notice'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
        ],
        Card(
          key: Key(
            runtimeContext.supportEnabled
                ? 'reports_current_support_card'
                : 'reports_current_general_card',
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'تقارير الفترة الحالية',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                ListTile(
                  key: const Key('reports_current_weekly_gateway'),
                  onTap: actionsEnabled
                      ? () {
                          Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (context) =>
                                  WeeklySupportReportReviewScreen(
                                    actionsEnabled: actionsEnabled,
                                  ),
                            ),
                          );
                        }
                      : null,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.view_week_outlined),
                  title: const Text('التقرير الأسبوعي الحالي'),
                  subtitle: const Text(
                    'السبت إلى الأربعاء، من بيانات المصدر المسجلة.',
                  ),
                  trailing: const Icon(Icons.chevron_left),
                ),
                ListTile(
                  key: const Key('reports_current_monthly_gateway'),
                  onTap: actionsEnabled
                      ? () {
                          Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (context) =>
                                  MonthlySupportReportReviewScreen(
                                    actionsEnabled: actionsEnabled,
                                  ),
                            ),
                          );
                        }
                      : null,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_month_outlined),
                  title: const Text('التقرير الشهري الحالي'),
                  subtitle: const Text(
                    'الشهر الميلادي، ويُبنى من الأسابيع المعتمدة فقط.',
                  ),
                  trailing: const Icon(Icons.chevron_left),
                ),
                const Text(
                  'التقارير الجارية مشتقة من المصدر، '
                  'ولا يتغير أي تقرير معتمد بمجرد فتح شاشة التقارير.',
                  key: Key('reports_live_projection_notice'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'التقارير السابقة',
          key: const Key('reports_history_title'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        if (history.isEmpty)
          const Card(
            key: Key('reports_history_empty'),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'لا توجد تقارير معتمدة سابقة.',
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ...history.map(
            (item) => Card(
              key: ValueKey<String>(
                'support_report_history_${item.kind.name}_${item.reportId}',
              ),
              child: ListTile(
                leading: Icon(
                  item.kind == SupportReportHistoryKind.weekly
                      ? Icons.view_week_outlined
                      : Icons.calendar_month_outlined,
                ),
                title: Text(
                  '${_kindLabel(item.kind)} • '
                  '${_dateText(item.periodStart)} - ${_dateText(item.periodEnd)}',
                ),
                subtitle: Text(
                  '${item.header.organizationName}\n'
                  'المعلم: ${item.header.teacherName}',
                ),
                onTap: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (context) =>
                          ApprovedSupportReportHistoryDetailScreen(item: item),
                    ),
                  );
                },
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_left),
              ),
            ),
          ),
        const SizedBox(height: 16),
        const Card(
          key: Key('reports_primary_artifact_gate_notice'),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'يُنفذ الاعتماد النهائي من شاشة التقرير الأسبوعي أو الشهري. '
              'عند الاعتماد يُنشأ ملف Excel الأساسي ويُعاد فتحه والتحقق منه '
              'قبل تثبيت الاعتماد.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  String _kindLabel(SupportReportHistoryKind kind) => switch (kind) {
    SupportReportHistoryKind.weekly => 'أسبوعي',
    SupportReportHistoryKind.monthly => 'شهري',
  };

  String _dateText(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }
}
