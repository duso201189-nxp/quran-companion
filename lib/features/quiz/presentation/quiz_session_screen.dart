import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../app/theme/app_theme.dart';
import '../data/quiz_providers.dart';
import '../domain/entities/quiz_question.dart';

/// Màn hình "Trắc nghiệm" (Quiz Session — Sprint 10 Phase 4,
/// DR-2026-0005 mục 5). Trình bày từng câu hỏi một, tự chuyển câu khi
/// chọn đáp án — KHÔNG có logic nghiệp vụ trong widget (không tự sinh
/// câu hỏi, không tự so đáp án đúng/sai; chỉ đọc
/// quizSessionControllerProvider và gọi answer()/restart()).
class QuizSessionScreen extends ConsumerWidget {
  const QuizSessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sessionAsync = ref.watch(quizSessionControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.studyQuiz)),
      body: SafeArea(
        child: sessionAsync.when(
          data: (session) {
            if (session.questions.isEmpty) {
              return _QuizEmpty(l10n: l10n);
            }
            if (session.isComplete) {
              return _QuizComplete(
                l10n: l10n,
                score: session.score,
                total: session.questions.length,
              );
            }
            return _QuizQuestionView(
              l10n: l10n,
              question: session.questions[session.currentIndex],
              questionNumber: session.currentIndex + 1,
              totalQuestions: session.questions.length,
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(
            child: Text(
              l10n.errorLoadData,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuizEmpty extends StatelessWidget {
  const _QuizEmpty({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          l10n.quizEmpty,
          textAlign: TextAlign.center,
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _QuizComplete extends ConsumerWidget {
  const _QuizComplete({
    required this.l10n,
    required this.score,
    required this.total,
  });

  final AppLocalizations l10n;
  final int score;
  final int total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events_rounded, size: 56, color: scheme.primary),
            const SizedBox(height: 16),
            Text(
              l10n.quizScoreResult(score, total),
              textAlign: TextAlign.center,
              style:
                  textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () =>
                  ref.read(quizSessionControllerProvider.notifier).restart(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.quizRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizQuestionView extends ConsumerWidget {
  const _QuizQuestionView({
    required this.l10n,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
  });

  final AppLocalizations l10n;
  final QuizQuestion question;
  final int questionNumber;
  final int totalQuestions;

  Future<void> _selectOption(
    BuildContext context,
    WidgetRef ref,
    int index,
  ) async {
    final correct =
        await ref.read(quizSessionControllerProvider.notifier).answer(index);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(correct ? l10n.quizCorrect : l10n.quizIncorrect),
          duration: const Duration(milliseconds: 700),
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.quizQuestionProgress(questionNumber, totalQuestions),
            style: textTheme.labelMedium?.copyWith(color: scheme.primary),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (question.promptIsArabic)
                    Text(
                      question.promptText,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: quranTextStyle(
                        fontSize: 24,
                        color: scheme.onSurface,
                      ),
                    )
                  else
                    Text(
                      question.promptText,
                      style: textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  const SizedBox(height: 24),
                  for (var i = 0; i < question.options.length; i++)
                    Padding(
                      key: ValueKey('quiz_option_$i'),
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _OptionButton(
                        text: question.options[i],
                        isArabic: question.optionsAreArabic,
                        onTap: () => _selectOption(context, ref, i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.text,
    required this.isArabic,
    required this.onTap,
  });

  final String text;
  final bool isArabic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Text(
            text,
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            style: isArabic
                ? quranTextStyle(fontSize: 20, color: scheme.onSurface)
                : Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: scheme.onSurface),
          ),
        ),
      ),
    );
  }
}
