import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../services/fdroid_api_service.dart';

/// A widget that fetches and displays a changelog from an HTML URL with expand/collapse functionality.
class ChangelogPreview extends StatefulWidget {
  final String? changelogUrl; // Optional URL to fetch
  final String? text; // Optional pre-fetched text (e.g., whatsNew)
  final int maxLines;

  const ChangelogPreview({
    super.key,
    this.changelogUrl,
    this.text,
    this.maxLines = 2,
  });

  @override
  State<ChangelogPreview> createState() => _ChangelogPreviewState();
}

class _ChangelogPreviewState extends State<ChangelogPreview> {
  bool _isExpanded = false;
  Future<String?>? _changelogFuture;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    _changelogFuture ??= _resolveTextOrFetch(context);

    return FutureBuilder<String?>(
      future: _changelogFuture,
      builder: (context, snapshot) {
        // Show loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              spacing: 8,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  'Loading changelog...',
                  style: textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        // Show error or no data
        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final changelogText = snapshot.data!.trim();

        // Check if text would overflow with max lines
        final textPainter = TextPainter(
          text: TextSpan(text: changelogText, style: textTheme.bodySmall),
          maxLines: widget.maxLines,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 32);
        final isOverflowing = textPainter.didExceedMaxLines;

        return Card.outlined(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
          // padding: const EdgeInsets.all(24),
          // decoration: BoxDecoration(
          //   color: Theme.of(context).colorScheme.surfaceContainerHighest,
          //   borderRadius: BorderRadius.circular(8),
          // ),
          child: InkWell(
            onTap: isOverflowing
                ? () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  }
                : null,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 8.0,
                top: 4.0,
                bottom: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Row(
                    spacing: 6,
                    children: [
                      Icon(
                        Symbols.article_rounded,
                        fill: 1,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      Text(
                        'What\'s New',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Spacer(),
                      if (isOverflowing)
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                          icon: Icon(
                            _isExpanded
                                ? Symbols.expand_less_rounded
                                : Symbols.expand_more_rounded,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Text(
                      changelogText,
                      maxLines: _isExpanded ? null : widget.maxLines,
                      overflow: _isExpanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Fetches changelog text via FDroidApiService (handles repo-relative paths and HTML stripping).
  Future<String?> _resolveTextOrFetch(BuildContext context) async {
    // If text was provided directly (e.g., version.whatsNew), use it
    if (widget.text != null && widget.text!.trim().isNotEmpty) {
      return widget.text!.trim();
    }
    // Otherwise, try fetching from URL
    if (widget.changelogUrl == null || widget.changelogUrl!.isEmpty) {
      return null;
    }
    try {
      final api = context.read<FDroidApiService>();
      return await api.fetchChangelogText(widget.changelogUrl);
    } catch (e) {
      debugPrint('Error fetching changelog: $e');
      return null;
    }
  }
}
