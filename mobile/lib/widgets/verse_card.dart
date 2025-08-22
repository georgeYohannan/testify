import 'package:flutter/material.dart';
import 'package:word__way/models/verse.dart';

class VerseCard extends StatelessWidget {
  final Verse verse;
  final bool isCompact;

  const VerseCard({
    super.key,
    required this.verse,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 12 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_stories,
                  color: theme.colorScheme.primary,
                  size: isCompact ? 20 : 24,
                ),
                const SizedBox(width: 8),
                Text(
                  isCompact ? 'Verse' : 'Verse of the Day',
                  style: isCompact 
                      ? theme.textTheme.titleSmall
                      : theme.textTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: isCompact ? 8 : 12),
            Text(
              '"${verse.text}"',
              style: isCompact 
                  ? theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    )
                  : theme.textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
            ),
            SizedBox(height: isCompact ? 6 : 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '- ${verse.reference}',
                style: isCompact 
                    ? theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      )
                    : theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}