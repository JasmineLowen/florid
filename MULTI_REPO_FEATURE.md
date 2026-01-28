# Multi-Repository Support Feature

## Overview
This feature allows apps that are available in multiple F-Droid repositories to be shown as a single entry in the app list, with the ability to choose which repository to install from in the AppDetailScreen.

## Changes Made

### 1. Model Changes (`lib/models/fdroid_app.dart`)

#### New Class: `RepositorySource`
```dart
class RepositorySource {
  final String name;
  final String url;
  
  const RepositorySource({
    required this.name,
    required this.url,
  });
}
```

This class represents a repository source with its name and URL. It implements equality based on URL to prevent duplicates.

#### Updated: `FDroidApp`
Added new field:
```dart
@JsonKey(ignore: true)
final List<RepositorySource>? availableRepositories;
```

This field tracks all repositories where the app is available. It's ignored in JSON serialization since it's computed at runtime.

### 2. Provider Changes (`lib/providers/app_provider.dart`)

#### Updated: `_mergeRepositories` method
The method now:
1. Iterates through all repositories
2. For each app (identified by package name):
   - If it's the first time seeing the app: adds it with its repository as a source
   - If the app already exists: adds the new repository to the `availableRepositories` list
3. Returns a merged repository with apps deduplicated by package name but tracking all sources

### 3. UI Changes (`lib/screens/app_details_screen.dart`)

#### New Method: `_buildInstallButton`
This method determines which button to show:
- **Single Repository**: Shows a simple Download/Install button
- **Multiple Repositories**: Shows a split button with:
  - Main button: Downloads from the primary repository
  - Dropdown button: Opens a dialog to select a different repository

#### New Method: `_handleInstall`
Handles the actual download/install process with:
- Permission checks
- Progress tracking
- Error handling
- Support for selecting a specific repository URL

#### New Method: `_showRepositorySelection`
Shows a dialog listing all available repositories with:
- Repository name
- Repository URL (truncated)
- Button to install from each repository

## User Experience

### Single Repository Scenario
When an app is available in only one repository:
```
┌─────────────────────────┐
│      Download           │
└─────────────────────────┘
```

### Multiple Repository Scenario
When an app is available in multiple repositories:
```
┌───────────────────┬─────┐
│    Download       │  ▼  │
└───────────────────┴─────┘
```

Clicking the dropdown (▼) shows:
```
┌────────────────────────────┐
│  Install from Repository   │
├────────────────────────────┤
│  ┌──────────────────────┐ │
│  │ F-Droid Official     │ │
│  │ https://f-droid.org  │ │
│  └──────────────────────┘ │
│  ┌──────────────────────┐ │
│  │ IzzyOnDroid         │ │
│  │ https://apt.izzy... │ │
│  └──────────────────────┘ │
│                            │
│           Cancel           │
└────────────────────────────┘
```

## Technical Details

### How Apps are Tracked
1. Apps are fetched from multiple repositories
2. During merge, apps with the same package name are combined
3. Each occurrence adds to the `availableRepositories` list
4. The app is displayed once in lists but remembers all sources

### Repository Selection
When a user selects a different repository:
1. The app is copied with the selected repository URL
2. The download uses this URL to fetch the APK
3. Installation proceeds normally

### Backward Compatibility
- Apps without `availableRepositories` (null) are treated as single-repo apps
- Existing functionality for single repository apps is unchanged
- Database structure remains the same

## Future Enhancements

Possible improvements:
1. Show repository badges in app list items
2. Display version differences between repositories
3. Allow setting a preferred default repository per app
4. Cache repository information for offline viewing
5. Show repository trust/verification status
