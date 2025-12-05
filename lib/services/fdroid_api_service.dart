import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../models/fdroid_app.dart';

class FDroidApiService {
  static const String baseUrl = 'https://f-droid.org';
  static const String apiUrl = '$baseUrl/api/v1';
  static const String repoIndexUrl = '$baseUrl/repo/index-v2.json';
  static const String _cacheFileName = 'fdroid_index_cache.json';
  static const Duration _fallbackCacheMaxAge = Duration(hours: 6);

  final http.Client _client;
  final Dio _dio;

  FDroidApiService({http.Client? client, Dio? dio})
    : _client = client ?? http.Client(),
      _dio = dio ?? Dio();

  /// Returns the cache file location for the repo index.
  Future<File> _cacheFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_cacheFileName');
  }

  /// Loads cached index JSON if it exists and is fresh enough.
  Future<Map<String, dynamic>?> _tryLoadCache() async {
    try {
      final file = await _cacheFile();
      if (!await file.exists()) return null;

      final stat = await file.stat();
      final age = DateTime.now().difference(stat.modified);
      if (age > _fallbackCacheMaxAge) return null;

      final contents = await file.readAsString();
      final jsonData = json.decode(contents);
      return jsonData is Map<String, dynamic> ? jsonData : null;
    } catch (_) {
      return null;
    }
  }

  /// Saves the latest index JSON to disk for offline use.
  Future<void> _saveCache(String body) async {
    try {
      final file = await _cacheFile();
      await file.writeAsString(body, flush: true);
    } catch (_) {
      // Ignore cache write failures
    }
  }

  /// Fetches the complete F-Droid repository index with disk caching.
  /// Flow: try cache (fresh) -> network -> cache fallback on network failure.
  Future<FDroidRepository> fetchRepository() async {
    Map<String, dynamic>? cachedJson = await _tryLoadCache();

    // Prefer cache when available.
    if (cachedJson != null) {
      try {
        return FDroidRepository.fromJson(cachedJson);
      } catch (_) {
        // If cache is corrupt, fall through to network fetch.
        cachedJson = null;
      }
    }

    try {
      final response = await _client.get(Uri.parse(repoIndexUrl));

      if (response.statusCode == 200) {
        final body = response.body;
        await _saveCache(body);
        final jsonData = json.decode(body);
        // Defensive: ensure expected top-level keys exist, else wrap in structure
        if (jsonData is Map &&
            (!jsonData.containsKey('repo') ||
                !jsonData.containsKey('packages'))) {
          // Possibly already flattened custom structure; we still attempt parsing
        }
        final repo = FDroidRepository.fromJson(
          jsonData as Map<String, dynamic>,
        );
        return repo;
      } else {
        throw Exception('Failed to load repository: ${response.statusCode}');
      }
    } catch (e) {
      // Fall back to cache if available.
      if (cachedJson != null) {
        return FDroidRepository.fromJson(cachedJson);
      }
      throw Exception('Error fetching repository: $e');
    }
  }

  /// Fetches apps with pagination support
  Future<List<FDroidApp>> fetchApps({
    int? limit,
    int? offset,
    String? category,
    String? search,
  }) async {
    try {
      final repository = await fetchRepository();
      List<FDroidApp> apps = repository.appsList;

      // Filter by category if specified
      if (category != null && category.isNotEmpty) {
        apps = apps
            .where((app) => app.categories?.contains(category) ?? false)
            .toList();
      }

      // Filter by search query if specified
      if (search != null && search.isNotEmpty) {
        final lowerSearch = search.toLowerCase();
        apps = apps
            .where(
              (app) =>
                  app.name.toLowerCase().contains(lowerSearch) ||
                  app.summary.toLowerCase().contains(lowerSearch) ||
                  app.description.toLowerCase().contains(lowerSearch) ||
                  app.packageName.toLowerCase().contains(lowerSearch),
            )
            .toList();
      }

      // Apply pagination
      if (offset != null) {
        apps = apps.skip(offset).toList();
      }
      if (limit != null) {
        apps = apps.take(limit).toList();
      }

      return apps;
    } catch (e) {
      throw Exception('Error fetching apps: $e');
    }
  }

  /// Fetches the latest apps
  Future<List<FDroidApp>> fetchLatestApps({int limit = 50}) async {
    try {
      final repository = await fetchRepository();
      return repository.latestApps.take(limit).toList();
    } catch (e) {
      throw Exception('Error fetching latest apps: $e');
    }
  }

  /// Fetches apps by category
  Future<List<FDroidApp>> fetchAppsByCategory(String category) async {
    try {
      final repository = await fetchRepository();
      return repository.getAppsByCategory(category);
    } catch (e) {
      throw Exception('Error fetching apps by category: $e');
    }
  }

  /// Searches for apps
  Future<List<FDroidApp>> searchApps(String query) async {
    try {
      final repository = await fetchRepository();
      return repository.searchApps(query);
    } catch (e) {
      throw Exception('Error searching apps: $e');
    }
  }

  /// Fetches all available categories
  Future<List<String>> fetchCategories() async {
    try {
      final repository = await fetchRepository();
      return repository.categories;
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  /// Fetches a specific app by package name
  Future<FDroidApp?> fetchApp(String packageName) async {
    try {
      final repository = await fetchRepository();
      return repository.apps[packageName];
    } catch (e) {
      throw Exception('Error fetching app: $e');
    }
  }

  /// Downloads an APK file with progress tracking
  Future<String> downloadApk(
    FDroidVersion version,
    String packageName, {
    Function(double)? onProgress,
  }) async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('Cannot access external storage');
      }

      final downloadsDir = Directory('${directory.path}/Downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final fileName = '${packageName}_${version.versionName}.apk';
      final filePath = '${downloadsDir.path}/$fileName';

      await _dio.download(
        version.downloadUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );

      return filePath;
    } catch (e) {
      throw Exception('Error downloading APK: $e');
    }
  }

  /// Checks if an APK file is already downloaded
  Future<bool> isApkDownloaded(String packageName, String versionName) async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) return false;

      final downloadsDir = Directory('${directory.path}/Downloads');
      final fileName = '${packageName}_$versionName.apk';
      final filePath = '${downloadsDir.path}/$fileName';

      return await File(filePath).exists();
    } catch (e) {
      return false;
    }
  }

  /// Gets the file path of a downloaded APK
  Future<String?> getDownloadedApkPath(
    String packageName,
    String versionName,
  ) async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) return null;

      final downloadsDir = Directory('${directory.path}/Downloads');
      final fileName = '${packageName}_$versionName.apk';
      final filePath = '${downloadsDir.path}/$fileName';

      if (await File(filePath).exists()) {
        return filePath;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    _client.close();
  }
}
