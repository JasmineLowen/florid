# Testing Multi-Repository Support

## Test Setup

To test the multi-repository support feature, you need to configure at least two repositories that contain the same app.

### Example Test Scenario

1. **Add Multiple Repositories**
   - Go to Settings → Repositories
   - Add F-Droid Official (if not already present): `https://f-droid.org/repo`
   - Add IzzyOnDroid: `https://apt.izzysoft.de/fdroid/repo`
   - Enable both repositories

2. **Find Apps Available in Multiple Repos**
   
   Common apps available in both F-Droid and IzzyOnDroid:
   - NewPipe
   - Aurora Store
   - Termux
   - KDE Connect
   - Many others...

## Test Cases

### Test Case 1: Single Repository App
**Expected Behavior:**
- App detail screen shows a simple "Download" or "Install" button
- No dropdown arrow visible
- Clicking downloads from the single available repository

**Steps:**
1. Find an app available in only one repository
2. Open app details
3. Verify button shows as a single unified button

### Test Case 2: Multiple Repository App - Default Install
**Expected Behavior:**
- App detail screen shows a split button with main action + dropdown
- Main button labeled "Download" or "Install"
- Dropdown button shows arrow (▼)
- Clicking main button downloads from primary repository

**Steps:**
1. Find an app available in multiple repositories
2. Open app details
3. Verify split button is visible
4. Click main "Download" button
5. Verify download starts from primary repository

### Test Case 3: Multiple Repository App - Repository Selection
**Expected Behavior:**
- Clicking dropdown shows dialog with repository options
- Each repository shows name and URL
- Selecting a repository downloads from that source

**Steps:**
1. Open an app available in multiple repositories
2. Click the dropdown arrow (▼)
3. Verify dialog appears with title "Install from Repository"
4. Verify all available repositories are listed with:
   - Repository name (e.g., "F-Droid Official", "IzzyOnDroid")
   - Repository URL (truncated if too long)
5. Click on a non-default repository
6. Verify download starts from selected repository

### Test Case 4: App List Display
**Expected Behavior:**
- Apps available in multiple repositories appear only ONCE in lists
- No duplicate entries for the same package name

**Steps:**
1. Navigate to Latest Apps or Recently Updated
2. Search for an app that's in multiple repositories
3. Verify the app appears only once in the list
4. Open the app details to confirm multi-repo support

## Verification Points

### Visual Verification
- [ ] Single repo apps show unified button
- [ ] Multi-repo apps show split button with clear visual separation
- [ ] Dropdown arrow is clearly visible and tappable
- [ ] Repository selection dialog is readable and well-formatted
- [ ] Repository names and URLs are displayed correctly

### Functional Verification
- [ ] Downloads work from default repository
- [ ] Downloads work from selected repository
- [ ] Installations complete successfully from any repository
- [ ] No duplicate apps appear in listings
- [ ] Error handling works for failed downloads

### Edge Cases
- [ ] Apps with only availableRepositories=null work as before
- [ ] Apps with empty availableRepositories list show single button
- [ ] Very long repository names/URLs are handled gracefully
- [ ] Dialog can be cancelled without triggering download

## Known Limitations

1. **Version Differences**: The feature currently doesn't show if different repositories have different versions of the app
2. **Repository Information**: No indication in app listings that an app is available in multiple repositories
3. **Preference Memory**: The app doesn't remember which repository was previously selected for an app

## Future Testing

Once implemented:
1. Test with 3+ repositories for the same app
2. Test with different versions across repositories
3. Test offline behavior when repositories are unavailable
4. Test repository priority/preference settings
