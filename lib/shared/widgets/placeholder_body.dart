import 'package:flutter/material.dart';

/// Thân màn hình tạm cho các tính năng sẽ xây ở các bước sau.
/// Sẽ bị thay thế dần — không dùng trong bản phát hành.
class PlaceholderBody extends StatelessWidget {
  const PlaceholderBody({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
  });

  final String title;
  final IconData icon;
  final String description;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: scheme.primary),
              const SizedBox(height: 16),
              Text(title, style: text.headlineSmall),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: text.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
