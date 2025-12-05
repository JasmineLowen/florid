import 'package:app_installer/app_installer.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/fdroid_app.dart';
import '../services/fdroid_api_service.dart';

enum DownloadStatus { idle, downloading, completed, error, cancelled }

class DownloadInfo {
  final String packageName;
  final String versionName;
  final DownloadStatus status;
  final double progress;
  final String? filePath;
  final String? error;

  const DownloadInfo({
    required this.packageName,
    required this.versionName,
    required this.status,
    this.progress = 0.0,
    this.filePath,
    this.error,
  });

  DownloadInfo copyWith({
    DownloadStatus? status,
    double? progress,
    String? filePath,
    String? error,
  }) {
    return DownloadInfo(
      packageName: packageName,
      versionName: versionName,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      filePath: filePath ?? this.filePath,
      error: error ?? this.error,
    );
  }

  String get key => '${packageName}_$versionName';
}

class DownloadProvider extends ChangeNotifier {
  final FDroidApiService _apiService;
  final Map<String, DownloadInfo> _downloads = {};

  DownloadProvider(this._apiService);

  Map<String, DownloadInfo> get downloads => Map.unmodifiable(_downloads);

  DownloadInfo? getDownloadInfo(String packageName, String versionName) {
    final key = '${packageName}_$versionName';
    return _downloads[key];
  }

  bool isDownloading(String packageName, String versionName) {
    final info = getDownloadInfo(packageName, versionName);
    return info?.status == DownloadStatus.downloading;
  }

  bool isDownloaded(String packageName, String versionName) {
    final info = getDownloadInfo(packageName, versionName);
    return info?.status == DownloadStatus.completed;
  }

  double getProgress(String packageName, String versionName) {
    final info = getDownloadInfo(packageName, versionName);
    return info?.progress ?? 0.0;
  }

  /// Requests necessary permissions for downloads
  Future<bool> requestPermissions() async {
    if (await Permission.storage.isGranted) {
      return true;
    }

    final status = await Permission.storage.request();
    return status.isGranted;
  }

  /// Downloads an APK file
  Future<String?> downloadApk(FDroidApp app) async {
    final version = app.latestVersion;
    if (version == null) {
      throw Exception('No version available for download');
    }

    final key = DownloadInfo(
      packageName: app.packageName,
      versionName: version.versionName,
      status: DownloadStatus.idle,
    ).key;

    // Check if already downloading or completed
    final existingInfo = _downloads[key];
    if (existingInfo?.status == DownloadStatus.downloading) {
      throw Exception('Download already in progress');
    }
    if (existingInfo?.status == DownloadStatus.completed &&
        existingInfo?.filePath != null) {
      return existingInfo!.filePath;
    }

    // Check permissions
    if (!await requestPermissions()) {
      throw Exception('Storage permission is required to download APK files');
    }

    // Check if already downloaded
    if (await _apiService.isApkDownloaded(
      app.packageName,
      version.versionName,
    )) {
      final filePath = await _apiService.getDownloadedApkPath(
        app.packageName,
        version.versionName,
      );
      if (filePath != null) {
        _downloads[key] = DownloadInfo(
          packageName: app.packageName,
          versionName: version.versionName,
          status: DownloadStatus.completed,
          progress: 1.0,
          filePath: filePath,
        );
        notifyListeners();
        return filePath;
      }
    }

    // Start download
    _downloads[key] = DownloadInfo(
      packageName: app.packageName,
      versionName: version.versionName,
      status: DownloadStatus.downloading,
      progress: 0.0,
    );
    notifyListeners();

    try {
      final filePath = await _apiService.downloadApk(
        version,
        app.packageName,
        onProgress: (progress) {
          _downloads[key] = _downloads[key]!.copyWith(progress: progress);
          notifyListeners();
        },
      );

      _downloads[key] = _downloads[key]!.copyWith(
        status: DownloadStatus.completed,
        progress: 1.0,
        filePath: filePath,
      );
      notifyListeners();

      return filePath;
    } catch (e) {
      _downloads[key] = _downloads[key]!.copyWith(
        status: DownloadStatus.error,
        error: e.toString(),
      );
      notifyListeners();

      rethrow;
    }
  }

  /// Cancels a download (if possible)
  void cancelDownload(String packageName, String versionName) {
    final key = '${packageName}_$versionName';
    final info = _downloads[key];

    if (info?.status == DownloadStatus.downloading) {
      _downloads[key] = info!.copyWith(status: DownloadStatus.cancelled);
      notifyListeners();
    }
  }

  /// Removes a download from the list
  void removeDownload(String packageName, String versionName) {
    final key = '${packageName}_$versionName';
    _downloads.remove(key);
    notifyListeners();
  }

  /// Clears all completed downloads
  void clearCompleted() {
    _downloads.removeWhere(
      (key, info) =>
          info.status == DownloadStatus.completed ||
          info.status == DownloadStatus.error ||
          info.status == DownloadStatus.cancelled,
    );
    notifyListeners();
  }

  /// Gets all active downloads
  List<DownloadInfo> getActiveDownloads() {
    return _downloads.values
        .where((info) => info.status == DownloadStatus.downloading)
        .toList();
  }

  /// Gets all completed downloads
  List<DownloadInfo> getCompletedDownloads() {
    return _downloads.values
        .where((info) => info.status == DownloadStatus.completed)
        .toList();
  }

  /// Gets the download queue count
  int get activeDownloadsCount {
    return _downloads.values
        .where((info) => info.status == DownloadStatus.downloading)
        .length;
  }

  /// Installs an APK file
  Future<void> installApk(String filePath) async {
    try {
      await AppInstaller.installApk(filePath);
    } catch (e) {
      throw Exception('Failed to install APK: $e');
    }
  }

  /// Requests install permission
  Future<bool> requestInstallPermission() async {
    try {
      final status = await Permission.requestInstallPackages.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting install permission: $e');
      return false;
    }
  }
}
