# Kesty

**English** | [简体中文](README.zh-CN.md)

**Plan your studies. Stay focused. Track your progress.**

Kesty is an iOS study and productivity app built with Swift and SwiftUI. It brings daily tasks, focus sessions, long-term goals, and personal achievement records together.

The app connects planning with action: start a focus session directly from a task, add study time to that task, and review your progress through calendars and statistics.

## Features

### Daily tasks and goals

- Create, rename, and delete daily tasks.
- Accumulate time spent on a task or set a target duration.
- Start a focus session directly from the task list.
- Automatically mark a task as complete when its target duration is reached.
- Archive the previous day's task status and reset daily progress while keeping task definitions.

### Focus timer

- Customize the countdown duration, with a default of 25 minutes.
- Link a focus session to a specific task.
- Record completed sessions and sessions manually ended after at least 5 seconds.
- View a session summary and your study streak after finishing.
- Choose background audio: piano, rain, café, wind, forest, or ambient drone.

### Long-term planning

- Create plans with start and end dates and smaller goals.
- Assign milestones to specific months.
- Browse plans and milestones by month.
- Link smaller goals from a plan to the daily task list.

### Study statistics

- View today's study time and progress toward your daily goal.
- Browse study records in a monthly calendar.
- Review total focus time, session count, average duration, and longest session.
- Explore recent study trends, focus activity by time of day, and plan completion.
- Share session dates and durations as CSV-formatted text.

### Profile and achievement records

- Set an avatar and basic profile information.
- Record education, skills, projects, work experience, research, leadership, volunteering, extracurricular activities, awards, certifications, publications, and languages.
- Add dates, descriptions, links, and education materials to relevant entries.

### Appearance settings

- Customize the app's theme and background colors.
- Save appearance preferences for future sessions.

## Technical implementation

| Component | Implementation |
| --- | --- |
| User interface | SwiftUI |
| Shared app state | `ObservableObject`, `@Published`, and `@EnvironmentObject` |
| Local storage | `UserDefaults`, `@AppStorage`, and Codable models |
| Focus timer | Combine timer publisher |
| Audio playback | AVFoundation |
| Avatar selection and camera | PhotosUI and UIKit |
| Content sharing | UIKit share sheet |
| Large audio asset management | Git LFS |

The project currently uses Apple's native frameworks and has no third-party Swift Package dependencies configured.

## Download and run

### Requirements

- A Mac with Xcode and the appropriate iOS SDK installed.
- An iPhone or iPad simulator, or a compatible physical device.
- The app target is currently configured for **iOS 17.6 or later**.
- Git and [Git LFS](https://git-lfs.com/).

### Download and open the project

Install Git LFS first, then run:

```sh
git lfs install
git clone https://github.com/yuxuan-518/kesty-support.git
cd kesty-support
git lfs pull
open BarelyWorkinginswiftui.xcodeproj
```

The Xcode project retains its development name, `BarelyWorkinginswiftui`. The app's display name is **Kesty**.

In Xcode:

1. Select the `BarelyWorkinginswiftui` scheme.
2. Choose an iPhone or iPad simulator.
3. Press **Command + R** to build and run.

For a physical device, configure your own development team under **Signing & Capabilities**.

The Ambient Drone audio file is managed with Git LFS. If this asset is missing after downloading the project, run `git lfs pull`.

## Quick walkthrough

1. Register a local account using test information.
2. Add a task and choose how to track its time.
3. Tap **Start** beside the task to open a linked focus session.
4. Set a duration and optionally select background audio.
5. Finish the session and review your recorded study time.
6. Open **Settings** to explore long-term plans, study statistics, your profile, and appearance settings.

## Code structure

| File | Main responsibility |
| --- | --- |
| `AppState.swift` | Shared state, data models, local storage, account flows, and study records |
| `RootView.swift` | Navigation between the splash screen, login screen, and main interface |
| `TasksView.swift` | Main navigation, daily tasks, calendar, and study progress overview |
| `FocusView.swift` | Focus countdown, task linking, and background audio |
| `FocusDoneView.swift` | Summary after a focus session |
| `SettingsView.swift` | Settings, focus record export, and account management |
| `SettingsSubViews.swift` | Goals, long-term plans, study statistics, and personalization screens |
| `EditProfileView.swift` | Profile, education, and achievement records |
| `AppTheme.swift` | Shared colors and appearance configuration |

## Current implementation notes

- **Local storage:** Accounts, tasks, plans, and study records are stored on the current device. Cross-device cloud synchronization is not implemented yet.
- **Local account flows:** Registration, login, and password reset run locally, without server-side authentication or email ownership verification.
- **Language settings:** The app saves a language preference, but most interface text is currently in English.
- **Focus timer:** Timing currently depends on in-app updates. Background and lock-screen timing need further development and validation.

## Feedback

Report bugs or suggest features through [GitHub Issues](https://github.com/yuxuan-518/kesty-support/issues).

When reporting an issue, please include your device model, iOS version, steps to reproduce it, and the expected result.
