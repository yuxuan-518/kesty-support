//
//
//
//import SwiftUI
//
//struct SettingsView: View {
//    @EnvironmentObject var appState: AppState
//    @State private var showEditProfile = false
//    @State private var showThemeColor = false
//    @State private var showLanguage = false
//    @State private var showDailyGoals = false
//    @State private var showLongTermPlans = false
//    @State private var showStudyProgress = false
//    @State private var showResetConfirm = false
//    @State private var showFeedback = false
//    @State private var showDeleteAccountConfirm = false
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                appState.bgColor
//                    .ignoresSafeArea()
//
//                ScrollView(showsIndicators: false) {
//                    VStack(alignment: .leading, spacing: 14) {
//
//                        Text("Settings")
//                            .font(.system(size: 20, weight: .semibold))
//                            .foregroundStyle(AppTheme.textPrimary)
//                            .frame(maxWidth: .infinity, alignment: .center)
//                            .padding(.top, 10)
//
//                        // Profile card
//                        Button { showEditProfile = true } label: {
//                            ProfileCard()
//                        }
//                        .buttonStyle(.plain)
//
//                        // GENERAL
//                        SectionLabel("GENERAL")
//                        SettingsCard {
//                            SettingRow(
//                                icon: "paintpalette.fill",
//                                iconBg: appState.themeColor.opacity(0.18),
//                                title: "Theme Color",
//                                trailingText: appState.selectedThemeColor,
//                                showChevron: true
//                            ) { showThemeColor = true }
//
//                            Divider().opacity(0.15).padding(.leading, 48)
//
//                            SettingRow(
//                                icon: "globe",
//                                iconBg: appState.themeColor.opacity(0.18),
//                                title: "App Language",
//                                trailingText: appState.selectedLanguage,
//                                showChevron: true
//                            ) { showLanguage = true }
//                        }
//
//                        // STUDY
//                        SectionLabel("STUDY")
//                        SettingsCard {
//                            SettingRow(
//                                icon: "target",
//                                iconBg: appState.themeColor.opacity(0.18),
//                                title: "Daily Goals",
//                                subtitle: "Set your daily study targets and progress rules",
//                                showChevron: true
//                            ) { showDailyGoals = true }
//
//                            Divider().opacity(0.15).padding(.leading, 48)
//
//                            SettingRow(
//                                icon: "calendar",
//                                iconBg: appState.themeColor.opacity(0.18),
//                                title: "Long-Term Plans",
//                                subtitle: "Manage plans that span across days or weeks",
//                                showChevron: true
//                            ) { showLongTermPlans = true }
//
//                            Divider().opacity(0.15).padding(.leading, 48)
//
//                            SettingRow(
//                                icon: "chart.bar.fill",
//                                iconBg: appState.themeColor.opacity(0.18),
//                                title: "Study Progress",
//                                subtitle: "View and adjust study tracking stats",
//                                showChevron: true
//                            ) { showStudyProgress = true }
//                        }
//
//                        // DATA & SYNC
//                        SectionLabel("DATA & SYNC")
//                        SettingsCard {
//                            SettingRow(
//                                icon: "square.and.arrow.up.fill",
//                                iconBg: appState.themeColor.opacity(0.18),
//                                title: "Export Data",
//                                showChevron: true
//                            ) { exportData() }
//
//                            Divider().opacity(0.15).padding(.leading, 48)
//
//                            SettingRow(
//                                icon: "exclamationmark.triangle.fill",
//                                iconBg: Color.red.opacity(0.14),
//                                iconFg: Color.red.opacity(0.85),
//                                title: "Reset Statistics",
//                                titleColor: Color.red.opacity(0.85),
//                                showChevron: true
//                            ) { showResetConfirm = true }
//                        }
//
//                        // SUPPORT
//                        SectionLabel("SUPPORT & ABOUT")
//                        SettingsCard {
//                            SettingRow(
//                                icon: "bubble.left.and.bubble.right.fill",
//                                iconBg: appState.themeColor.opacity(0.18),
//                                title: "Send Feedback",
//                                showChevron: true
//                            ) { showFeedback = true }
//
//                            Divider().opacity(0.15).padding(.leading, 48)
//
//                            SettingRow(
//                                icon: "info.circle.fill",
//                                iconBg: appState.themeColor.opacity(0.18),
//                                title: "Version",
//                                trailingText: "1.1.0",
//                                showChevron: false
//                            ) {}
//                        }
//
//                        // ACCOUNT
//                        SectionLabel("ACCOUNT")
//                        SettingsCard {
//                            SettingRow(
//                                icon: "rectangle.portrait.and.arrow.right.fill",
//                                iconBg: Color.red.opacity(0.12),
//                                iconFg: Color.red.opacity(0.85),
//                                title: "Sign Out",
//                                titleColor: Color.red.opacity(0.85),
//                                showChevron: false
//                            ) { appState.logout() }
//
//                            Divider().opacity(0.15).padding(.leading, 48)
//
//                            SettingRow(
//                                icon: "person.crop.circle.badge.minus",
//                                iconBg: Color.red.opacity(0.12),
//                                iconFg: Color.red.opacity(0.85),
//                                title: "Delete Account",
//                                titleColor: Color.red.opacity(0.85),
//                                showChevron: false
//                            ) { showDeleteAccountConfirm = true }
//                        }
//
//                        Spacer(minLength: 0)
//                    }
//                    .padding(.horizontal, 16)
//                    .padding(.bottom, 100)
//                }
//            }
//            .navigationDestination(isPresented: $showEditProfile) {
//                EditProfileView().environmentObject(appState)
//            }
//            .navigationDestination(isPresented: $showThemeColor) {
//                ThemeColorView().environmentObject(appState)
//            }
//            .navigationDestination(isPresented: $showLanguage) {
//                LanguageView().environmentObject(appState)
//            }
//            .navigationDestination(isPresented: $showDailyGoals) {
//                DailyGoalsView().environmentObject(appState)
//            }
//            .navigationDestination(isPresented: $showLongTermPlans) {
//                LongTermPlansView().environmentObject(appState)
//            }
//            .navigationDestination(isPresented: $showStudyProgress) {
//                StudyProgressView().environmentObject(appState)
//            }
//            .navigationDestination(isPresented: $showFeedback) {
//                FeedbackView().environmentObject(appState)
//            }
//        }
//        .alert("Reset All Data", isPresented: $showResetConfirm) {
//            Button("Cancel", role: .cancel) {}
//            Button("Reset", role: .destructive) {
//                appState.resetAllAccountData()
//            }
//        } message: {
//            Text("This will permanently delete all your tasks, plans, focus history, and streak data. Your account will remain active.")
//        }
//        .alert("Delete Account", isPresented: $showDeleteAccountConfirm) {
//            Button("Cancel", role: .cancel) {}
//            Button("Delete", role: .destructive) {
//                appState.deleteAccount()
//            }
//        } message: {
//            Text("This will permanently delete your account and all associated data. This action cannot be undone.")
//        }
//    }
//
//    private func exportData() {
//        var csv = "Date,Duration (minutes)\n"
//        let formatter = DateFormatter()
//        formatter.dateStyle = .short
//        for session in appState.focusSessions {
//            csv += "\(formatter.string(from: session.date)),\(Int(session.duration / 60))\n"
//        }
//        let av = UIActivityViewController(activityItems: [csv], applicationActivities: nil)
//        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//           let vc = scene.windows.first?.rootViewController {
//            vc.present(av, animated: true)
//        }
//    }
//}
//
//// MARK: - Profile Card
//
//struct ProfileCard: View {
//    @EnvironmentObject var appState: AppState
//
//    var body: some View {
//        HStack(spacing: 12) {
//            Circle()
//                .fill(appState.themeColor.opacity(0.18))
//                .frame(width: 54, height: 54)
//                .overlay {
//                    if let data = appState.currentUser.avatarData,
//                       let img = UIImage(data: data) {
//                        Image(uiImage: img)
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: 54, height: 54)
//                            .clipShape(Circle())
//                    } else {
//                        Image(systemName: "person.fill")
//                            .font(.system(size: 22, weight: .semibold))
//                            .foregroundStyle(appState.themeColor)
//                    }
//                }
//
//            VStack(alignment: .leading, spacing: 4) {
//                Text(appState.currentUser.name.isEmpty ? "User" : appState.currentUser.name)
//                    .font(.system(size: 17, weight: .bold))
//                    .foregroundStyle(AppTheme.textPrimary)
//
//                Text("Streak: \(appState.currentStreak) day\(appState.currentStreak == 1 ? "" : "s") 🔥")
//                    .font(.system(size: 13, weight: .semibold))
//                    .foregroundStyle(AppTheme.textSecondary)
//            }
//
//            Spacer()
//
//            Text("Edit")
//                .font(.system(size: 14, weight: .semibold))
//                .foregroundStyle(appState.themeColor)
//                .padding(.horizontal, 16)
//                .padding(.vertical, 8)
//                .background(Capsule().fill(appState.themeColor.opacity(0.14)))
//        }
//        .padding(14)
//        .background(RoundedRectangle(cornerRadius: 18).fill(.white.opacity(0.75)))
//        .overlay(RoundedRectangle(cornerRadius: 18).stroke(appState.themeColor.opacity(0.10), lineWidth: 1))
//    }
//}
//
//// MARK: - Shared Components
//
//struct SectionLabel: View {
//    let text: String
//    init(_ text: String) { self.text = text }
//
//    var body: some View {
//        Text(text)
//            .font(.system(size: 12, weight: .bold))
//            .foregroundStyle(AppTheme.textSecondary)
//            .padding(.horizontal, 6)
//            .padding(.top, 2)
//    }
//}
//
//struct SettingsCard<Content: View>: View {
//    @EnvironmentObject var appState: AppState
//    @ViewBuilder var content: Content
//
//    var body: some View {
//        VStack(spacing: 0) { content }
//            .background(RoundedRectangle(cornerRadius: 18).fill(.white.opacity(0.78)))
//            .overlay(RoundedRectangle(cornerRadius: 18).stroke(appState.themeColor.opacity(0.10), lineWidth: 1))
//    }
//}
//
//struct SettingRow: View {
//    @EnvironmentObject var appState: AppState
//    var icon: String
//    var iconBg: Color
//    var iconFg: Color? = nil
//    var title: String
//    var subtitle: String? = nil
//    var trailingText: String? = nil
//    var titleColor: Color = AppTheme.textPrimary
//    var showChevron: Bool = true
//    var onTap: () -> Void
//
//    var body: some View {
//        Button(action: onTap) {
//            HStack(spacing: 12) {
//                IconBubble(icon: icon, bg: iconBg, fg: iconFg ?? appState.themeColor)
//
//                VStack(alignment: .leading, spacing: 3) {
//                    Text(title)
//                        .font(.system(size: 16, weight: .semibold))
//                        .foregroundStyle(titleColor)
//                    if let sub = subtitle {
//                        Text(sub)
//                            .font(.system(size: 12, weight: .medium))
//                            .foregroundStyle(AppTheme.textSecondary)
//                            .lineLimit(2)
//                    }
//                }
//
//                Spacer()
//
//                if let t = trailingText {
//                    Text(t)
//                        .font(.system(size: 14, weight: .semibold))
//                        .foregroundStyle(appState.themeColor.opacity(0.9))
//                }
//
//                if showChevron {
//                    Image(systemName: "chevron.right")
//                        .font(.system(size: 14, weight: .semibold))
//                        .foregroundStyle(AppTheme.textSecondary)
//                }
//            }
//            .padding(.vertical, 12)
//            .padding(.horizontal, 14)
//        }
//        .buttonStyle(.plain)
//    }
//}
//
//struct IconBubble: View {
//    var icon: String
//    var bg: Color
//    var fg: Color
//
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 11)
//                .fill(bg)
//                .frame(width: 34, height: 34)
//            Image(systemName: icon)
//                .font(.system(size: 16, weight: .semibold))
//                .foregroundStyle(fg)
//        }
//    }
//}
//
//#Preview {
//    SettingsView().environmentObject(AppState())
//}





import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showEditProfile = false
    @State private var showThemeColor = false
    @State private var showLanguage = false
    @State private var showDailyGoals = false
    @State private var showLongTermPlans = false
    @State private var showStudyProgress = false
    @State private var showResetConfirm = false
    @State private var showFeedback = false
    @State private var showDeleteAccountConfirm = false

    // iPad export: we need a reference to the button's geometry for the popover anchor
    @State private var exportButtonFrame: CGRect = .zero

    var body: some View {
        NavigationStack {
            ZStack {
                appState.bgColor
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {

                        Text("Settings")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 10)

                        // Profile card
                        Button { showEditProfile = true } label: {
                            ProfileCard()
                        }
                        .buttonStyle(.plain)

                        // GENERAL
                        SectionLabel("GENERAL")
                        SettingsCard {
                            SettingRow(
                                icon: "paintpalette.fill",
                                iconBg: appState.themeColor.opacity(0.18),
                                title: "Theme Color",
                                trailingText: appState.selectedThemeColor,
                                showChevron: true
                            ) { showThemeColor = true }

                            Divider().opacity(0.15).padding(.leading, 48)

                            SettingRow(
                                icon: "globe",
                                iconBg: appState.themeColor.opacity(0.18),
                                title: "App Language",
                                trailingText: appState.selectedLanguage,
                                showChevron: true
                            ) { showLanguage = true }
                        }

                        // STUDY
                        SectionLabel("STUDY")
                        SettingsCard {
                            SettingRow(
                                icon: "target",
                                iconBg: appState.themeColor.opacity(0.18),
                                title: "Daily Goals",
                                subtitle: "Set your daily study targets and progress rules",
                                showChevron: true
                            ) { showDailyGoals = true }

                            Divider().opacity(0.15).padding(.leading, 48)

                            SettingRow(
                                icon: "calendar",
                                iconBg: appState.themeColor.opacity(0.18),
                                title: "Long-Term Plans",
                                subtitle: "Manage plans that span across days or weeks",
                                showChevron: true
                            ) { showLongTermPlans = true }

                            Divider().opacity(0.15).padding(.leading, 48)

                            SettingRow(
                                icon: "chart.bar.fill",
                                iconBg: appState.themeColor.opacity(0.18),
                                title: "Study Progress",
                                subtitle: "View and adjust study tracking stats",
                                showChevron: true
                            ) { showStudyProgress = true }
                        }

                        // DATA & SYNC
                        SectionLabel("DATA & SYNC")
                        SettingsCard {
                            // Use a GeometryReader anchor so iPad popover has a valid source rect
                            ExportDataRow(
                                iconBg: appState.themeColor.opacity(0.18),
                                themeColor: appState.themeColor,
                                onExport: { sourceRect in
                                    exportData(sourceRect: sourceRect)
                                }
                            )

                            Divider().opacity(0.15).padding(.leading, 48)

                            SettingRow(
                                icon: "exclamationmark.triangle.fill",
                                iconBg: Color.red.opacity(0.14),
                                iconFg: Color.red.opacity(0.85),
                                title: "Reset Statistics",
                                titleColor: Color.red.opacity(0.85),
                                showChevron: true
                            ) { showResetConfirm = true }
                        }

                        // SUPPORT
                        SectionLabel("SUPPORT & ABOUT")
                        SettingsCard {
                            SettingRow(
                                icon: "bubble.left.and.bubble.right.fill",
                                iconBg: appState.themeColor.opacity(0.18),
                                title: "Send Feedback",
                                showChevron: true
                            ) { showFeedback = true }

                            Divider().opacity(0.15).padding(.leading, 48)

                            SettingRow(
                                icon: "info.circle.fill",
                                iconBg: appState.themeColor.opacity(0.18),
                                title: "Version",
                                trailingText: "1.1.0",
                                showChevron: false
                            ) {}
                        }

                        // ACCOUNT
                        SectionLabel("ACCOUNT")
                        SettingsCard {
                            SettingRow(
                                icon: "rectangle.portrait.and.arrow.right.fill",
                                iconBg: Color.red.opacity(0.12),
                                iconFg: Color.red.opacity(0.85),
                                title: "Sign Out",
                                titleColor: Color.red.opacity(0.85),
                                showChevron: false
                            ) { appState.logout() }

                            Divider().opacity(0.15).padding(.leading, 48)

                            SettingRow(
                                icon: "person.crop.circle.badge.minus",
                                iconBg: Color.red.opacity(0.12),
                                iconFg: Color.red.opacity(0.85),
                                title: "Delete Account",
                                titleColor: Color.red.opacity(0.85),
                                showChevron: false
                            ) { showDeleteAccountConfirm = true }
                        }

                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
            }
            .navigationDestination(isPresented: $showEditProfile) {
                EditProfileView().environmentObject(appState)
            }
            .navigationDestination(isPresented: $showThemeColor) {
                ThemeColorView().environmentObject(appState)
            }
            .navigationDestination(isPresented: $showLanguage) {
                LanguageView().environmentObject(appState)
            }
            .navigationDestination(isPresented: $showDailyGoals) {
                DailyGoalsView().environmentObject(appState)
            }
            .navigationDestination(isPresented: $showLongTermPlans) {
                LongTermPlansView().environmentObject(appState)
            }
            .navigationDestination(isPresented: $showStudyProgress) {
                StudyProgressView().environmentObject(appState)
            }
            .navigationDestination(isPresented: $showFeedback) {
                FeedbackView().environmentObject(appState)
            }
        }
        .alert("Reset All Data", isPresented: $showResetConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                appState.resetAllAccountData()
            }
        } message: {
            Text("This will permanently delete all your tasks, plans, focus history, and streak data. Your account will remain active.")
        }
        .alert("Delete Account", isPresented: $showDeleteAccountConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                appState.deleteAccount()
            }
        } message: {
            Text("This will permanently delete your account and all associated data. This action cannot be undone.")
        }
    }

    // MARK: - Export (iPad-safe)

    private func exportData(sourceRect: CGRect) {
        // Build CSV safely — no force unwraps, no file URL needed
        var csv = "Date,Duration (minutes)\n"
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        for session in appState.focusSessions {
            let dateStr = formatter.string(from: session.date)
            let mins = Int(session.duration / 60)
            csv += "\(dateStr),\(mins)\n"
        }

        let av = UIActivityViewController(activityItems: [csv], applicationActivities: nil)

        // iPad REQUIRES a popoverPresentationController source — without this it crashes
        if let popover = av.popoverPresentationController {
            // Find the key window to use as sourceView
            if let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
               let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                popover.sourceView = window
                // Use the tapped button's frame so the arrow points to the right place.
                // Fall back to screen center if frame is zero (shouldn't happen).
                if sourceRect != .zero {
                    popover.sourceRect = sourceRect
                } else {
                    popover.sourceRect = CGRect(
                        x: window.bounds.midX,
                        y: window.bounds.midY,
                        width: 0,
                        height: 0
                    )
                }
                popover.permittedArrowDirections = [.up, .down]
            }
        }

        // Present from the root view controller safely
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
           let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            // Walk to the topmost presented controller to avoid "already presenting" crash
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            topVC.present(av, animated: true)
        }
    }
}

// MARK: - Export Data Row (captures its own frame for iPad popover)

/// A dedicated row for "Export Data" that reads its own CGRect in global coordinates
/// and passes it to the parent's exportData function. This gives UIActivityViewController
/// a valid sourceRect on iPad so it can attach the popover arrow correctly.
private struct ExportDataRow: View {
    let iconBg: Color
    let themeColor: Color
    let onExport: (CGRect) -> Void

    var body: some View {
        GeometryReader { geo in
            // We wrap the SettingRow in a GeometryReader so we can read the frame
            // in global (window) coordinates and hand it to the popover.
            SettingRow(
                icon: "square.and.arrow.up.fill",
                iconBg: iconBg,
                title: "Export Data",
                showChevron: true
            ) {
                let frame = geo.frame(in: .global)
                onExport(frame)
            }
        }
        // Give it the same intrinsic height as a normal SettingRow
        .frame(height: 50)
    }
}

// MARK: - Profile Card

struct ProfileCard: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(appState.themeColor.opacity(0.18))
                .frame(width: 54, height: 54)
                .overlay {
                    if let data = appState.currentUser.avatarData,
                       let img = UIImage(data: data) {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 54, height: 54)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(appState.themeColor)
                    }
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(appState.currentUser.name.isEmpty ? "User" : appState.currentUser.name)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)

                Text("Streak: \(appState.currentStreak) day\(appState.currentStreak == 1 ? "" : "s") 🔥")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            Text("Edit")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(appState.themeColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Capsule().fill(appState.themeColor.opacity(0.14)))
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 18).fill(.white.opacity(0.75)))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(appState.themeColor.opacity(0.10), lineWidth: 1))
    }
}

// MARK: - Shared Components

struct SectionLabel: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(AppTheme.textSecondary)
            .padding(.horizontal, 6)
            .padding(.top, 2)
    }
}

struct SettingsCard<Content: View>: View {
    @EnvironmentObject var appState: AppState
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) { content }
            .background(RoundedRectangle(cornerRadius: 18).fill(.white.opacity(0.78)))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(appState.themeColor.opacity(0.10), lineWidth: 1))
    }
}

struct SettingRow: View {
    @EnvironmentObject var appState: AppState
    var icon: String
    var iconBg: Color
    var iconFg: Color? = nil
    var title: String
    var subtitle: String? = nil
    var trailingText: String? = nil
    var titleColor: Color = AppTheme.textPrimary
    var showChevron: Bool = true
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                IconBubble(icon: icon, bg: iconBg, fg: iconFg ?? appState.themeColor)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(titleColor)
                    if let sub = subtitle {
                        Text(sub)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineLimit(2)
                    }
                }

                Spacer()

                if let t = trailingText {
                    Text(t)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(appState.themeColor.opacity(0.9))
                }

                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
        }
        .buttonStyle(.plain)
    }
}

struct IconBubble: View {
    var icon: String
    var bg: Color
    var fg: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 11)
                .fill(bg)
                .frame(width: 34, height: 34)
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(fg)
        }
    }
}

#Preview {
    SettingsView().environmentObject(AppState())
}
