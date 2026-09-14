import 'package:flutter/material.dart';
import 'package:qurani/features/daily_halaqah/application/daily_halaqah_runtime_providers.dart';
import 'package:qurani/features/daily_halaqah/domain/daily_halaqah.dart';
import 'package:qurani/features/daily_halaqah/presentation/halaqah_day_summary_screen.dart';

class HalaqahDayHistoryScreen extends StatefulWidget {
  const HalaqahDayHistoryScreen({required this.runtimeContext, super.key});

  final DailyHalaqahRuntimeContext runtimeContext;

  @override
  State<HalaqahDayHistoryScreen> createState() =>
      _HalaqahDayHistoryScreenState();
}

class _HalaqahDayHistoryScreenState extends State<HalaqahDayHistoryScreen> {
  List<HalaqahDayHistoryItem> _items = const <HalaqahDayHistoryItem>[];
  String? _errorText;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _errorText = null;
      });
    }

    try {
      final items = await widget.runtimeContext.readService.history(
        halaqahId: widget.runtimeContext.halaqahId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _errorText = 'تعذر تحميل سجل الأيام.';
      });
    }
  }

  Future<void> _openSummary(HalaqahDayHistoryItem item) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => HalaqahDaySummaryScreen(
          runtimeContext: widget.runtimeContext,
          dayId: item.day.id,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('halaqah_day_history_screen'),
      appBar: AppBar(title: const Text('سجل الأيام'), centerTitle: true),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(key: Key('day_history_loading')),
      );
    }

    if (_errorText != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(_errorText!, textAlign: TextAlign.center),
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

    if (_items.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد أيام مكتملة أو إجازات بعد.',
          key: Key('day_history_empty'),
          textAlign: TextAlign.center,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        key: const Key('day_history_list'),
        padding: const EdgeInsets.all(12),
        itemCount: _items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 4),
        itemBuilder: (context, index) {
          final item = _items[index];

          return Card(
            child: ListTile(
              key: ValueKey<String>('day_history_${item.day.dayDate}'),
              leading: Icon(
                item.day.isHoliday
                    ? Icons.event_busy_outlined
                    : Icons.check_circle_outline,
              ),
              title: Text(item.day.dayDate),
              subtitle: Text(_summaryText(item)),
              trailing: const Icon(Icons.chevron_left),
              onTap: () {
                _openSummary(item);
              },
            ),
          );
        },
      ),
    );
  }

  String _summaryText(HalaqahDayHistoryItem item) {
    if (item.day.isHoliday) {
      return 'إجازة';
    }

    final counts = item.attendance;

    return 'حاضر ${counts.presentCount} • '
        'غائب ${counts.absentCount} • '
        'بعذر ${counts.excusedAbsentCount}';
  }
}
