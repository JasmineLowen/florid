# Multi-Repository Support - Visual Guide

## User Interface Changes

### 1. App Detail Screen - Single Repository

When an app is available in only ONE repository:

```
┌─────────────────────────────────────────────┐
│  App Icon    App Name                       │
│              by Author                      │
│                                             │
│  ┌───────────────────────────────────────┐ │
│  │         Download                      │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  Description...                             │
│  Screenshots...                             │
│  Version Info...                            │
└─────────────────────────────────────────────┘
```

**Behavior:** Simple button, clicking downloads from the single available repository.

---

### 2. App Detail Screen - Multiple Repositories

When an app is available in MULTIPLE repositories:

```
┌─────────────────────────────────────────────┐
│  App Icon    App Name                       │
│              by Author                      │
│                                             │
│  ┌──────────────────────────────┬────────┐ │
│  │       Download               │   ▼    │ │
│  └──────────────────────────────┴────────┘ │
│                                             │
│  Description...                             │
│  Screenshots...                             │
│  Version Info...                            │
└─────────────────────────────────────────────┘
```

**Behavior:**
- Left button: Downloads from primary (default) repository
- Right button (▼): Opens repository selection dialog

---

### 3. Repository Selection Dialog

When user clicks the dropdown button (▼):

```
┌──────────────────────────────────────────┐
│  Download from Repository                │
├──────────────────────────────────────────┤
│                                          │
│  ┌────────────────────────────────────┐ │
│  │ F-Droid Official        [Default] │ │
│  │ https://f-droid.org/repo          │ │
│  └────────────────────────────────────┘ │
│                                          │
│  ┌────────────────────────────────────┐ │
│  │ IzzyOnDroid                       │ │
│  │ https://apt.izzysoft.de/fdroid... │ │
│  └────────────────────────────────────┘ │
│                                          │
│  ┌────────────────────────────────────┐ │
│  │ Guardian Project                  │ │
│  │ https://guardianproject.info/... │ │
│  └────────────────────────────────────┘ │
│                                          │
│                           [Cancel]       │
└──────────────────────────────────────────┘
```

**Features:**
- Dynamic title based on action (Download/Install)
- Lists all available repositories
- Shows repository name and URL
- "Default" badge on primary repository
- Primary repo has highlighted border
- Clicking any repo starts download from that source
- Cancel button dismisses dialog

---

## Visual Design Elements

### Split Button Design

```
Main Button (Expanded)        Dropdown (Fixed Width)
┌────────────────────────┐   ┌──────┐
│    Download            │   │  ▼   │
│    [Icon] Label        │   │      │
└────────────────────────┘   └──────┘
     Rounded Left             Rounded Right
     Border Radius: 24         Border Radius: 24
```

**Spacing:** 1px gap between buttons for visual separation

### Repository Item in Dialog

```
┌──────────────────────────────────────────┐
│  Repository Name              [Default]  │ ← Title Medium
│  https://repository-url.com/...          │ ← Body Small (70% opacity)
└──────────────────────────────────────────┘
   ↑ Primary repo has 2px border in primary color
```

### Color Scheme
- **Primary Repository Border:** 2px, primary color
- **Default Badge Background:** primaryContainer color
- **Default Badge Text:** onPrimaryContainer color
- **URL Text Opacity:** 70% of normal text color

---

## States and Interactions

### Button States

| Condition | Main Button | Dropdown | Interaction |
|-----------|-------------|----------|-------------|
| Single Repo | Download/Install | Hidden | Click → Download |
| Multi Repo | Download/Install | ▼ | Main → Download from primary |
| Multi Repo | Download/Install | ▼ | Dropdown → Show dialog |
| Downloaded | Install | ▼ | Main → Install APK |
| Downloading | Cancel Download | Hidden | Click → Cancel |
| Installed | Open + Uninstall | Hidden | Standard buttons |

### Dialog Interactions

1. **Click Repository Item:** Closes dialog, starts download from selected repo
2. **Click Cancel:** Closes dialog, no action
3. **Click Outside:** Closes dialog, no action
4. **Default Repo Indicator:** Visual only, still clickable

---

## Responsive Behavior

### Mobile Portrait (Typical)
- Split button takes full width
- Main button expands to fill available space
- Dropdown button fixed ~48dp width
- Dialog centers on screen, max width constrained

### Tablet/Large Screens
- Same layout, scales proportionally
- Dialog may show larger but with same max width
- Touch targets remain appropriately sized

---

## Accessibility

- **Semantic Labels:** Both buttons have clear purposes
- **Touch Targets:** Minimum 48x48dp maintained
- **Color Contrast:** Meets WCAG AA standards
- **Screen Readers:** Can identify button purposes
- **Keyboard Navigation:** Dialog supports tab navigation (if applicable)

---

## Edge Cases Handled

1. **Very Long Repository Names:** Truncated with ellipsis
2. **Very Long URLs:** Truncated with ellipsis (maxLines: 1)
3. **Many Repositories:** Dialog scrollable if needed
4. **Network Errors:** Standard error handling with SnackBar
5. **Permission Denied:** Shows permission dialog
6. **Null/Empty availableRepositories:** Falls back to simple button

---

## Animation/Transitions

- Button appears with fade-in (300ms delay, 300ms duration)
- Dialog uses standard Material dialog animation
- No custom animations for button state changes (uses Flutter defaults)

This visual guide should help developers and testers understand exactly what the feature looks like and how it behaves in different scenarios.
