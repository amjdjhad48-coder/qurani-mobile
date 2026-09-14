import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurani/features/daily_halaqah/application/daily_halaqah_runtime_providers.dart';
import 'package:qurani/features/daily_halaqah/presentation/qurani_home_screen.dart';
import 'package:qurani/features/students/application/student_runtime_providers.dart';
import 'package:qurani/features/students/presentation/students_list_screen.dart';

class QuraniMainShell extends ConsumerStatefulWidget {
  const QuraniMainShell({
    required this.onChangePin,
    required this.onLockNow,
    this.actionsEnabled = true,
    this.noticeText,
    super.key,
  });

  final VoidCallback onChangePin;
  final VoidCallback onLockNow;
  final bool actionsEnabled;
  final String? noticeText;

  @override
  ConsumerState<QuraniMainShell> createState() => _QuraniMainShellState();
}

class _QuraniMainShellState extends ConsumerState<QuraniMainShell> {
  _MainSection _section = _MainSection.home;
  bool? _supportEnabled;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_refreshSupportStatus);
  }

  Future<void> _refreshSupportStatus() async {
    try {
      final studentContext = await ref.read(
        studentRuntimeContextProvider.future,
      );

      final status = await studentContext.service.supportStatusForHalaqah(
        studentContext.halaqahId,
      );

      if (!mounted) {
        return;
      }

      final enabled = status == 'enabled';

      setState(() {
        _supportEnabled = enabled;

        if (!enabled && _section == _MainSection.reports) {
          _section = _MainSection.home;
        }
      });
    } catch (_) {
      if (!mounted || _supportEnabled != null) {
        return;
      }

      setState(() {
        _supportEnabled = false;
      });
    }
  }

  void _selectSection(int index, List<_MainSection> sections) {
    final next = sections[index];

    setState(() {
      _section = next;
    });

    unawaited(_refreshSupportStatus());
  }

  @override
  Widget build(BuildContext context) {
    final sections = <_MainSection>[
      _MainSection.home,
      _MainSection.students,
      if (_supportEnabled == true) _MainSection.reports,
      _MainSection.settings,
    ];

    final selectedIndex = sections.indexOf(_section);

    return Scaffold(
      key: const Key('qurani_main_shell'),
      body: _buildSection(),
      bottomNavigationBar: NavigationBar(
        key: const Key('qurani_bottom_navigation'),
        selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
        onDestinationSelected: (index) {
          _selectSection(index, sections);
        },
        destinations: sections.map(_destinationFor).toList(growable: false),
      ),
    );
  }

  Widget _buildSection() {
    return switch (_section) {
      _MainSection.home => _buildHome(),
      _MainSection.students => StudentsListScreen(
        actionsEnabled: widget.actionsEnabled,
        noticeText: widget.noticeText,
        onChangePin: widget.onChangePin,
        onLockNow: widget.onLockNow,
      ),
      _MainSection.reports => _ReportsPlaceholderScreen(
        actionsEnabled: widget.actionsEnabled,
        onChangePin: widget.onChangePin,
        onLockNow: widget.onLockNow,
      ),
      _MainSection.settings => _SettingsScreen(
        actionsEnabled: widget.actionsEnabled,
        noticeText: widget.noticeText,
        onChangePin: widget.onChangePin,
        onLockNow: widget.onLockNow,
      ),
    };
  }

  Widget _buildHome() {
    final runtimeContext = ref.watch(dailyHalaqahRuntimeContextProvider);

    return runtimeContext.when(
      loading: () => _ShellStatusScreen(
        title: 'الرئيسية',
        actionsEnabled: widget.actionsEnabled,
        noticeText: widget.noticeText,
        onChangePin: widget.onChangePin,
        onLockNow: widget.onLockNow,
        child: const CircularProgressIndicator(
          key: Key('home_runtime_loading'),
        ),
      ),
      error: (error, stackTrace) => _ShellStatusScreen(
        title: 'الرئيسية',
        actionsEnabled: widget.actionsEnabled,
        noticeText: widget.noticeText,
        onChangePin: widget.onChangePin,
        onLockNow: widget.onLockNow,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'تعذر فتح بيانات الحلقة اليومية.',
              key: Key('home_runtime_error'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () {
                ref.invalidate(dailyHalaqahRuntimeContextProvider);
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
      data: (value) => QuraniHomeScreen(
        runtimeContext: value,
        actionsEnabled: widget.actionsEnabled,
        noticeText: widget.noticeText,
        onChangePin: widget.onChangePin,
        onLockNow: widget.onLockNow,
      ),
    );
  }

  NavigationDestination _destinationFor(_MainSection section) {
    return switch (section) {
      _MainSection.home => const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'الرئيسية',
      ),
      _MainSection.students => const NavigationDestination(
        icon: Icon(Icons.people_outline),
        selectedIcon: Icon(Icons.people),
        label: 'الطلاب',
      ),
      _MainSection.reports => const NavigationDestination(
        icon: Icon(Icons.assessment_outlined),
        selectedIcon: Icon(Icons.assessment),
        label: 'التقارير',
      ),
      _MainSection.settings => const NavigationDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings),
        label: 'الإعدادات',
      ),
    };
  }
}

enum _MainSection { home, students, reports, settings }

class _ShellStatusScreen extends StatelessWidget {
  const _ShellStatusScreen({
    required this.title,
    required this.actionsEnabled,
    required this.onChangePin,
    required this.onLockNow,
    required this.child,
    this.noticeText,
  });

  final String title;
  final bool actionsEnabled;
  final VoidCallback onChangePin;
  final VoidCallback onLockNow;
  final Widget child;
  final String? noticeText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _runtimeAppBar(
        title: title,
        actionsEnabled: actionsEnabled,
        onChangePin: onChangePin,
        onLockNow: onLockNow,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (noticeText != null) ...<Widget>[
                  Text(
                    noticeText!,
                    key: const Key('runtime_notice'),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsScreen extends StatelessWidget {
  const _SettingsScreen({
    required this.actionsEnabled,
    required this.onChangePin,
    required this.onLockNow,
    this.noticeText,
  });

  final bool actionsEnabled;
  final VoidCallback onChangePin;
  final VoidCallback onLockNow;
  final String? noticeText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('qurani_settings_screen'),
      appBar: AppBar(title: const Text('الإعدادات'), centerTitle: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            if (noticeText != null) ...<Widget>[
              Text(
                noticeText!,
                key: const Key('runtime_notice'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            Card(
              child: ListTile(
                key: const Key('settings_change_pin_button'),
                leading: const Icon(Icons.password_outlined),
                title: const Text('تغيير PIN'),
                trailing: const Icon(Icons.chevron_left),
                enabled: actionsEnabled,
                onTap: actionsEnabled ? onChangePin : null,
              ),
            ),
            Card(
              child: ListTile(
                key: const Key('settings_lock_now_button'),
                leading: const Icon(Icons.lock_outline),
                title: const Text('قفل التطبيق الآن'),
                trailing: const Icon(Icons.chevron_left),
                enabled: actionsEnabled,
                onTap: actionsEnabled ? onLockNow : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportsPlaceholderScreen extends StatelessWidget {
  const _ReportsPlaceholderScreen({
    required this.actionsEnabled,
    required this.onChangePin,
    required this.onLockNow,
  });

  final bool actionsEnabled;
  final VoidCallback onChangePin;
  final VoidCallback onLockNow;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('reports_placeholder_screen'),
      appBar: _runtimeAppBar(
        title: 'التقارير',
        actionsEnabled: actionsEnabled,
        onChangePin: onChangePin,
        onLockNow: onLockNow,
      ),
      body: const SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'تم تثبيت بوابة التقارير في التنقل. '
              'وظائف التقارير نفسها تُنفذ في الحزمة المخصصة لها.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

AppBar _runtimeAppBar({
  required String title,
  required bool actionsEnabled,
  required VoidCallback onChangePin,
  required VoidCallback onLockNow,
}) {
  return AppBar(
    title: Text(title),
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
  );
}
