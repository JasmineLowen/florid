import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/fdroid_app.dart';
import '../providers/app_provider.dart';
import '../providers/download_provider.dart';

class AppDetailsScreen extends StatelessWidget {
  final FDroidApp app;

  const AppDetailsScreen({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    const double expandedHeight = 180;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: expandedHeight,
            pinned: true,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final maxHeight = constraints.maxHeight;
                final collapseRange = expandedHeight - kToolbarHeight;
                final t = collapseRange <= 0
                    ? 1.0
                    : ((expandedHeight - maxHeight) / collapseRange).clamp(
                        0.0,
                        1.0,
                      );

                return FlexibleSpaceBar(
                  titlePadding: EdgeInsetsDirectional.only(
                    start: t < 1 ? 50 : 16,
                    bottom: 16,
                    end: 100,
                  ),
                  title: AnimatedOpacity(
                    opacity: t,
                    duration: const Duration(milliseconds: 150),
                    child: Row(
                      spacing: 8,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _AppDetailsIcon(app: app),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            app.name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                    ),
                  ),
                );
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  Share.share(
                    'Check out ${app.name} on F-Droid: https://f-droid.org/packages/${app.packageName}/',
                  );
                },
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  switch (value) {
                    case 'website':
                      if (app.webSite != null) {
                        await launchUrl(Uri.parse(app.webSite!));
                      }
                      break;
                    case 'source':
                      if (app.sourceCode != null) {
                        await launchUrl(Uri.parse(app.sourceCode!));
                      }
                      break;
                    case 'issues':
                      if (app.issueTracker != null) {
                        await launchUrl(Uri.parse(app.issueTracker!));
                      }
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (app.webSite != null)
                    const PopupMenuItem(
                      value: 'website',
                      child: ListTile(
                        leading: Icon(Icons.web),
                        title: Text('Website'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  if (app.sourceCode != null)
                    const PopupMenuItem(
                      value: 'source',
                      child: ListTile(
                        leading: Icon(Icons.code),
                        title: Text('Source Code'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  if (app.issueTracker != null)
                    const PopupMenuItem(
                      value: 'issues',
                      child: ListTile(
                        leading: Icon(Icons.bug_report),
                        title: Text('Issue Tracker'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                ],
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App info header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    spacing: 16,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: 'app-icon-${app.packageName}',
                        child: Material(
                          child: SizedBox(
                            width: 100,
                            height: 100,

                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: _AppDetailsIcon(app: app),
                            ),
                          ),
                        ),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          Text(
                            app.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            'by ${app.authorName ?? 'Unknown'}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                      if (app.categories?.isNotEmpty == true) ...[
                        Chip(label: Text(app.categories!.first)),
                      ],

                      _DownloadSection(app: app),
                    ],
                  ),
                ),

                // Description
                _DescriptionSection(app: app),

                // Download section
                // _DownloadSection(app: app),

                // App details
                _AppInfoSection(app: app),

                // Version info
                if (app.latestVersion != null)
                  _VersionInfoSection(version: app.latestVersion!)
                else
                  const _NoVersionInfoSection(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DownloadSection extends StatelessWidget {
  final FDroidApp app;

  const _DownloadSection({required this.app});

  @override
  Widget build(BuildContext context) {
    if (app.latestVersion == null) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'No Version Available',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'This app doesn\'t have any downloadable versions available.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ],
        ),
      );
    }

    return Consumer2<DownloadProvider, AppProvider>(
      builder: (context, downloadProvider, appProvider, child) {
        final version = app.latestVersion!;
        final isInstalled = appProvider.isAppInstalled(app.packageName);
        final installedApp = appProvider.getInstalledApp(app.packageName);
        final downloadInfo = downloadProvider.getDownloadInfo(
          app.packageName,
          version.versionName,
        );
        final isDownloading =
            downloadInfo?.status == DownloadStatus.downloading;
        final isCancelled = downloadInfo?.status == DownloadStatus.cancelled;
        final isDownloaded =
            downloadInfo?.status == DownloadStatus.completed &&
            downloadInfo?.filePath != null &&
            !isCancelled;
        final progress = downloadProvider.getProgress(
          app.packageName,
          version.versionName,
        );

        return Container(
          // width: double.infinity,
          // margin: const EdgeInsets.symmetric(horizontal: 16),
          // decoration: BoxDecoration(
          //   color: Theme.of(context).colorScheme.primaryContainer,
          //   borderRadius: BorderRadius.circular(16),
          // ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row(
              //   children: [
              //     Expanded(
              //       child: Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Text(
              //             'Version ${version.versionName}',
              //             style: Theme.of(context).textTheme.titleMedium
              //                 ?.copyWith(
              //                   color: Theme.of(
              //                     context,
              //                   ).colorScheme.onPrimaryContainer,
              //                   fontWeight: FontWeight.w600,
              //                 ),
              //           ),
              //           const SizedBox(height: 4),
              //           Text(
              //             'Size: ${version.sizeString}',
              //             style: Theme.of(context).textTheme.bodyMedium
              //                 ?.copyWith(
              //                   color: Theme.of(
              //                     context,
              //                   ).colorScheme.onPrimaryContainer,
              //                 ),
              //           ),
              //           if (isInstalled && installedApp != null)
              //             Text(
              //               'Installed: ${installedApp.versionName ?? 'Unknown'}',
              //               style: Theme.of(context).textTheme.bodySmall
              //                   ?.copyWith(
              //                     color: Theme.of(context)
              //                         .colorScheme
              //                         .onPrimaryContainer
              //                         .withOpacity(0.8),
              //                   ),
              //             ),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
              // const SizedBox(height: 16),
              if (isDownloading)
                Column(
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Downloading... ${(progress * 100).toInt()}%',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            downloadProvider.cancelDownload(
                              app.packageName,
                              version.versionName,
                            );
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (isDownloaded) {
                        // Install APK
                        try {
                          final downloadInfo = downloadProvider.getDownloadInfo(
                            app.packageName,
                            version.versionName,
                          );
                          if (downloadInfo?.filePath != null) {
                            // Request install permission first
                            final hasPermission = await downloadProvider
                                .requestInstallPermission();
                            if (!hasPermission) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Install permission is required to install APK files',
                                    ),
                                  ),
                                );
                              }
                              return;
                            }

                            await downloadProvider.installApk(
                              downloadInfo!.filePath!,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${app.name} installation started!',
                                  ),
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Installation failed: ${e.toString()}',
                                ),
                              ),
                            );
                          }
                        }
                      } else {
                        // Download APK - show permission rationale first
                        final shouldProceed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            icon: const Icon(Icons.folder_open, size: 48),
                            title: const Text('Storage Permission Required'),
                            content: const Text(
                              'Florid needs access to your device storage to download and save APK files. This allows you to:\n\n'
                              '• Download apps from F-Droid\n'
                              '• Install downloaded apps\n'
                              '• Manage your downloads\n\n'
                              'Your files and data remain private and secure.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Continue'),
                              ),
                            ],
                          ),
                        );

                        if (shouldProceed != true) return;

                        try {
                          await downloadProvider.downloadApk(app);
                          // No success message - auto-install handles feedback
                        } catch (e) {
                          // Only show error if not cancelled
                          final errorMsg = e.toString();
                          if (!errorMsg.contains('cancelled') &&
                              !errorMsg.contains('Cancelled')) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Download failed: $errorMsg'),
                                ),
                              );
                            }
                          }
                        }
                      }
                    },
                    icon: Icon(
                      isDownloaded ? Icons.install_mobile : Icons.download,
                    ),
                    label: Text(isDownloaded ? 'Install' : 'Download'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _AppInfoSection extends StatelessWidget {
  final FDroidApp app;

  const _AppInfoSection({required this.app});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'App Information',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _InfoRow('Package Name', app.packageName),
          _InfoRow('License', app.license),
          if (app.added != null) _InfoRow('Added', _formatDate(app.added!)),
          if (app.lastUpdated != null)
            _InfoRow('Last Updated', _formatDate(app.lastUpdated!)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _DescriptionSection extends StatelessWidget {
  final FDroidApp app;

  const _DescriptionSection({required this.app});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(app.description, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _VersionInfoSection extends StatelessWidget {
  final FDroidVersion version;

  const _VersionInfoSection({required this.version});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Version Information',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _InfoRow('Version Name', version.versionName),
          _InfoRow('Version Code', version.versionCode.toString()),
          _InfoRow('Size', version.sizeString),
          if (version.minSdkVersion != null)
            _InfoRow('Min SDK', version.minSdkVersion!),
          if (version.targetSdkVersion != null)
            _InfoRow('Target SDK', version.targetSdkVersion!),
          _InfoRow('Added', _formatDate(version.added)),
          if (version.permissions?.isNotEmpty == true)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Permissions:',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 4),
                ...version.permissions!.map(
                  (permission) => Padding(
                    padding: const EdgeInsets.only(left: 16, top: 2),
                    child: Text(
                      '• $permission',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _NoVersionInfoSection extends StatelessWidget {
  const _NoVersionInfoSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Version Information',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'No Version Information Available',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This app doesn\'t have detailed version information in the F-Droid repository.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _AppDetailsIcon extends StatefulWidget {
  final FDroidApp app;
  const _AppDetailsIcon({required this.app});

  @override
  State<_AppDetailsIcon> createState() => _AppDetailsIconState();
}

class _AppDetailsIconState extends State<_AppDetailsIcon> {
  late List<String> _candidates;
  int _index = 0;
  bool _showFallback = false;

  @override
  void initState() {
    super.initState();
    _candidates = widget.app.iconUrls;
  }

  void _next() {
    if (!mounted) return;

    // Always use addPostFrameCallback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Move through all candidates before showing a fallback
      if (_index < _candidates.length - 1) {
        setState(() {
          _index++;
        });
      } else {
        setState(() {
          _showFallback = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showFallback) {
      return Container(
        color: Colors.white.withOpacity(0.2),
        child: const Icon(Icons.android, color: Colors.white, size: 40),
      );
    }

    if (_index >= _candidates.length) {
      return Container(
        color: Colors.white.withOpacity(0.2),
        child: const Icon(Icons.apps, color: Colors.white, size: 40),
      );
    }

    final url = _candidates[_index];
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // Move to next candidate or fallback
        _next();
        return Container(
          color: Colors.white.withOpacity(0.2),
          child: const Icon(Icons.broken_image, color: Colors.white, size: 40),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.white.withOpacity(0.2),
          alignment: Alignment.center,
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        );
      },
    );
  }
}
