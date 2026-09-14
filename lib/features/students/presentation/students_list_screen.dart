import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurani/features/students/application/student_runtime_providers.dart';
import 'package:qurani/features/students/domain/student.dart';
import 'package:qurani/features/students/presentation/student_form_screen.dart';
import 'package:qurani/features/students/presentation/student_profile_screen.dart';
import 'package:qurani/features/students/presentation/archived_students_screen.dart';
import 'package:qurani/features/students/presentation/support_program_screen.dart';

class StudentsListScreen extends ConsumerWidget {
  const StudentsListScreen({
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
  Widget build(BuildContext context, WidgetRef ref) {
    final runtimeContext = ref.watch(studentRuntimeContextProvider);

    return Scaffold(
      key: const Key('students_list_screen'),
      appBar: AppBar(
        title: const Text('الطلاب'),
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
        child: Column(
          children: <Widget>[
            if (noticeText != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(
                  noticeText!,
                  key: const Key('runtime_notice'),
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              child: runtimeContext.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    key: Key('students_runtime_loading'),
                  ),
                ),
                error: (error, stackTrace) => _RuntimeErrorSurface(
                  onRetry: () {
                    ref.invalidate(studentRuntimeContextProvider);
                  },
                ),
                data: (value) => _StudentsListBody(
                  key: ValueKey<int>(value.halaqahId),
                  runtimeContext: value,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuntimeErrorSurface extends StatelessWidget {
  const _RuntimeErrorSurface({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'تعذر فتح بيانات الطلاب في الجلسة الحالية.',
              key: Key('students_runtime_error'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              key: const Key('students_runtime_retry'),
              onPressed: onRetry,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentsListBody extends StatefulWidget {
  const _StudentsListBody({required this.runtimeContext, super.key});

  final StudentRuntimeContext runtimeContext;

  @override
  State<_StudentsListBody> createState() => _StudentsListBodyState();
}

class _StudentsListBodyState extends State<_StudentsListBody> {
  final TextEditingController _searchController = TextEditingController();

  List<StudentRecord> _students = const <StudentRecord>[];
  String _query = '';
  String? _errorText;
  var _loading = true;
  var _reordering = false;
  var _openingForm = false;
  var _openingArchived = false;
  var _openingSupportProgram = false;
  var _requestGeneration = 0;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_loadStudents);
  }

  @override
  void didUpdateWidget(covariant _StudentsListBody oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.runtimeContext.halaqahId != widget.runtimeContext.halaqahId) {
      _searchController.clear();
      _query = '';
      Future<void>.microtask(_loadStudents);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents({bool showLoading = true}) async {
    final generation = ++_requestGeneration;

    if (showLoading && mounted) {
      setState(() {
        _loading = true;
        _errorText = null;
      });
    }

    try {
      final students = await widget.runtimeContext.service.search(
        halaqahId: widget.runtimeContext.halaqahId,
        query: _query,
      );

      if (!mounted || generation != _requestGeneration) {
        return;
      }

      setState(() {
        _students = students;
        _loading = false;
        _errorText = null;
      });
    } catch (_) {
      if (!mounted || generation != _requestGeneration) {
        return;
      }

      setState(() {
        _loading = false;
        _errorText = 'تعذر تحميل قائمة الطلاب.';
      });
    }
  }

  void _search(String value) {
    _query = value;
    unawaited(_loadStudents(showLoading: false));
  }

  Future<void> _reorder(int oldIndex, int newIndex) async {
    if (_reordering || _query.trim().isNotEmpty) {
      return;
    }

    if (oldIndex == newIndex) {
      return;
    }

    final original = List<StudentRecord>.of(_students);
    final reordered = List<StudentRecord>.of(_students);

    final moved = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, moved);

    setState(() {
      _students = reordered;
      _reordering = true;
      _errorText = null;
    });

    try {
      final saved = await widget.runtimeContext.service.reorderActiveStudents(
        halaqahId: widget.runtimeContext.halaqahId,
        orderedStudentIds: reordered
            .map((student) => student.id)
            .toList(growable: false),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _students = saved;
        _reordering = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _students = original;
        _reordering = false;
        _errorText = 'تعذر حفظ ترتيب الطلاب.';
      });
    }
  }

  Future<void> _openAddStudent() async {
    if (_openingForm) {
      return;
    }

    setState(() {
      _openingForm = true;
      _errorText = null;
    });

    try {
      final service = widget.runtimeContext.service;

      final supportStatus = await service.supportStatusForHalaqah(
        widget.runtimeContext.halaqahId,
      );

      if (!mounted) {
        return;
      }

      final saved = await Navigator.of(context).push<StudentRecord>(
        MaterialPageRoute<StudentRecord>(
          builder: (context) => StudentFormScreen(
            service: service,
            halaqahId: widget.runtimeContext.halaqahId,
            supportStatus: supportStatus,
          ),
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _openingForm = false;
      });

      if (saved != null) {
        await _loadStudents(showLoading: false);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _openingForm = false;
        _errorText = 'تعذر فتح نموذج إضافة الطالب.';
      });
    }
  }

  Future<void> _openArchivedStudents() async {
    if (_openingArchived) {
      return;
    }

    setState(() {
      _openingArchived = true;
      _errorText = null;
    });

    try {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (context) => ArchivedStudentsScreen(
            service: widget.runtimeContext.service,
            halaqahId: widget.runtimeContext.halaqahId,
          ),
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _openingArchived = false;
      });

      await _loadStudents(showLoading: false);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _openingArchived = false;
        _errorText = 'تعذر فتح الطلاب المؤرشفين.';
      });
    }
  }

  Future<void> _openSupportProgram() async {
    final supportService = widget.runtimeContext.supportProgramService;

    if (_openingSupportProgram || supportService == null) {
      return;
    }

    setState(() {
      _openingSupportProgram = true;
      _errorText = null;
    });

    try {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (context) => SupportProgramScreen(
            service: supportService,
            halaqahId: widget.runtimeContext.halaqahId,
          ),
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _openingSupportProgram = false;
      });

      await _loadStudents(showLoading: false);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _openingSupportProgram = false;
        _errorText = 'تعذر فتح برنامج الدعم.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            key: const Key('students_search_field'),
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              labelText: 'بحث عن طالب',
              hintText: 'الاسم أو رقم الجهة الداعمة',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      key: const Key('students_search_clear'),
                      tooltip: 'مسح البحث',
                      onPressed: () {
                        _searchController.clear();
                        _search('');
                      },
                      icon: const Icon(Icons.clear),
                    ),
              border: const OutlineInputBorder(),
            ),
            onChanged: _search,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('add_student_button'),
              onPressed: _openingForm ? null : _openAddStudent,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('إضافة طالب'),
            ),
          ),
        ),
        if (widget.runtimeContext.supportProgramService != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: const Key('support_program_button'),
                onPressed: _openingSupportProgram ? null : _openSupportProgram,
                icon: const Icon(Icons.volunteer_activism_outlined),
                label: const Text('برنامج الدعم'),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: const Key('archived_students_button'),
              onPressed: _openingArchived ? null : _openArchivedStudents,
              icon: const Icon(Icons.archive_outlined),
              label: const Text('الطلاب المؤرشفون'),
            ),
          ),
        ),
        if (_errorText != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              _errorText!,
              key: const Key('students_list_error'),
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        Expanded(child: _buildList()),
      ],
    );
  }

  Widget _buildList() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(key: Key('students_list_loading')),
      );
    }

    if (_students.isEmpty) {
      return Center(
        child: Text(
          _query.trim().isEmpty
              ? 'لا يوجد طلاب نشطون بعد.'
              : 'لا توجد نتائج مطابقة.',
          key: const Key('students_empty_state'),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_query.trim().isNotEmpty) {
      return ListView.builder(
        key: const Key('students_search_results'),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        itemCount: _students.length,
        itemBuilder: (context, index) {
          return _studentCard(_students[index], dragHandle: null);
        },
      );
    }

    return ReorderableListView.builder(
      key: const Key('students_active_list'),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      buildDefaultDragHandles: false,
      itemCount: _students.length,
      onReorderItem: (oldIndex, newIndex) {
        unawaited(_reorder(oldIndex, newIndex));
      },
      itemBuilder: (context, index) {
        final student = _students[index];

        return _studentCard(
          student,
          dragHandle: ReorderableDragStartListener(
            index: index,
            enabled: !_reordering,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(
                Icons.drag_handle,
                semanticLabel: 'تغيير ترتيب الطالب',
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openStudentProfile(StudentRecord student) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => StudentProfileScreen(
          service: widget.runtimeContext.service,
          student: student,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    await _loadStudents(showLoading: false);
  }

  Widget _studentCard(StudentRecord student, {required Widget? dragHandle}) {
    final details = <String>['العمر: ${student.ageYears}'];

    final supportNumber = student.supportStudentNumber;
    if (supportNumber != null && supportNumber.isNotEmpty) {
      details.add('رقم الدعم: $supportNumber');
    }

    return Card(
      key: ValueKey<String>('student_${student.id}'),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            student.studentName.trim().isEmpty
                ? '؟'
                : student.studentName.trim().substring(0, 1),
          ),
        ),
        title: Text(student.studentName),
        subtitle: Text(details.join(' • ')),
        onTap: () {
          unawaited(_openStudentProfile(student));
        },
        trailing: dragHandle,
      ),
    );
  }
}
