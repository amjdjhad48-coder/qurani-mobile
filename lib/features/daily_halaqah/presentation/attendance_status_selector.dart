import 'package:flutter/material.dart';
import 'package:qurani/features/daily_halaqah/domain/daily_halaqah.dart';

class AttendanceStatusSelector extends StatelessWidget {
  const AttendanceStatusSelector({
    required this.value,
    required this.onChanged,
    required this.keyPrefix,
    super.key,
  });

  final AttendanceStatus? value;
  final ValueChanged<AttendanceStatus>? onChanged;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: AttendanceStatus.values
          .map((status) {
            return ChoiceChip(
              key: Key('${keyPrefix}_${status.storageValue}'),
              label: Text(_label(status)),
              selected: value == status,
              onSelected: onChanged == null
                  ? null
                  : (selected) {
                      if (selected) {
                        onChanged!(status);
                      }
                    },
            );
          })
          .toList(growable: false),
    );
  }

  String _label(AttendanceStatus status) {
    return switch (status) {
      AttendanceStatus.present => 'حاضر',
      AttendanceStatus.absent => 'غائب',
      AttendanceStatus.excusedAbsent => 'غائب بعذر',
    };
  }
}
