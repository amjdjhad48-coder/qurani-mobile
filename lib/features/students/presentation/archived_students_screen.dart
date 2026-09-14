import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qurani/features/students/application/student_service.dart';
import 'package:qurani/features/students/domain/student.dart';
import 'package:qurani/features/students/presentation/student_profile_screen.dart';

class ArchivedStudentsScreen extends StatefulWidget {
  const ArchivedStudentsScreen({
    required this.service,
    required this.halaqahId,
    super.key,
  });

  final StudentService service;
  final int halaqahId;

  @override
  State<ArchivedStudentsScreen> createState() => _ArchivedStudentsScreenState();
}

class _ArchivedStudentsScreenState extends State<ArchivedStudentsScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<StudentRecord> _students = const <StudentRecord>[];

  String _query = '';
  String? _errorText;

  var _loading = true;
  var _openingProfile = false;
  var _requestGeneration = 0;

  @override
  void initState() {
    super.initState();

    Future<void>.microtask(_loadStudents);
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
      final students = await widget.service.searchArchived(
        halaqahId: widget.halaqahId,
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
        _errorText = 'تعذر تحميل الطلاب المؤرشفين.';
      });
    }
  }

  void _search(String value) {
    _query = value;

    unawaited(_loadStudents(showLoading: false));
  }

  Future<void> _openProfile(StudentRecord student) async {
    if (_openingProfile) {
      return;
    }

    setState(() {
      _openingProfile = true;
      _errorText = null;
    });

    try {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (context) =>
              StudentProfileScreen(service: widget.service, student: student),
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _openingProfile = false;
      });

      await _loadStudents(showLoading: false);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _openingProfile = false;
        _errorText = 'تعذر فتح ملف الطالب.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('archived_students_screen'),
      appBar: AppBar(title: const Text('الطلاب المؤرشفون'), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                key: const Key('archived_students_search_field'),
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  labelText: 'بحث عن طالب مؤرشف',
                  hintText: 'الاسم أو رقم الجهة الداعمة',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          key: const Key('archived_students_search_clear'),
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
            if (_errorText != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text(
                  _errorText!,
                  key: const Key('archived_students_error'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(key: Key('archived_students_loading')),
      );
    }

    if (_students.isEmpty) {
      return Center(
        child: Text(
          _query.trim().isEmpty
              ? 'لا يوجد طلاب مؤرشفون.'
              : 'لا توجد نتائج مطابقة.',
          key: const Key('archived_students_empty_state'),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      key: const Key('archived_students_list'),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      itemCount: _students.length,
      itemBuilder: (context, index) {
        final student = _students[index];

        return Card(
          key: ValueKey<String>('archived_student_${student.id}'),
          child: ListTile(
            onTap: _openingProfile
                ? null
                : () {
                    unawaited(_openProfile(student));
                  },
            leading: const Icon(Icons.archive_outlined),
            title: Text(student.studentName),
            subtitle: Text(_subtitleFor(student)),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }

  String _subtitleFor(StudentRecord student) {
    final supportNumber = student.supportStudentNumber;

    if (supportNumber != null && supportNumber.isNotEmpty) {
      return 'العمر ${student.ageYears} - '
          'رقم الجهة الداعمة: $supportNumber';
    }

    return 'العمر ${student.ageYears}';
  }
}
