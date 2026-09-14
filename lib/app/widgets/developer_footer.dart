import 'package:flutter/material.dart';

class DeveloperFooter extends StatelessWidget {
  const DeveloperFooter({super.key});

  static const text = 'برمجة وتطوير المهندس أمجد جهاد';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 3, 12, 5),
      child: Center(
        child: Text(
          text,
          key: const Key('developer_footer'),
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
