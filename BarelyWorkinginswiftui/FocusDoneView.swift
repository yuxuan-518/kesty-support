import SwiftUI

struct FocusDoneView: View {
    @EnvironmentObject var appState: AppState
    @Binding var selectedTab: AppTab
    @Environment(\.dismiss) private var dismiss

    let elapsedTime: TimeInterval

    private var elapsedLabel: String {
        let total = Int(elapsedTime)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60

        if h > 0 && m > 0 {
            return "\(h) hour\(h > 1 ? "s" : "") \(m) minute\(m > 1 ? "s" : "")"
        } else if h > 0 {
            return "\(h) hour\(h > 1 ? "s" : "")"
        } else if m > 0 && s > 0 {
            return "\(m) minute\(m > 1 ? "s" : "") \(s) second\(s > 1 ? "s" : "")"
        } else if m > 0 {
            return "\(m) minute\(m > 1 ? "s" : "")"
        } else {
            return "\(s) second\(s > 1 ? "s" : "")"
        }
    }

    var body: some View {
        ZStack {
            appState.bgColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Rectangle().fill(Color.clear).frame(height: 54)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {

                        VStack(spacing: 14) {
                            Text("Done!")
                                .font(.system(size: 44, weight: .bold))
                                .foregroundStyle(appState.themeColor.opacity(0.95))

                            CheckmarkHero()
                                .frame(height: 210)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 14)

                        Text("You focused for \(elapsedLabel).\nGreat job! 🎉")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                            .multilineTextAlignment(.leading)
                            .padding(.top, 4)

                        StreakCard(streak: appState.currentStreak, isNewRecord: appState.isNewRecord)

                        HStack(spacing: 12) {
                            SecondaryPillButton(title: "Back to Tasks") {
                                dismiss()
                                selectedTab = .tasks
                            }
                            PrimaryPillButton(title: "Start Next Session") {
                                dismiss()
                                selectedTab = .focus
                            }
                        }
                        .padding(.top, 2)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 18)
                    .padding(.bottom, 120)
                }
            }
        }
    }
}

// MARK: - Hero

struct CheckmarkHero: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        ZStack {
            Circle()
                .fill(appState.themeColor.opacity(0.10))
                .frame(width: 190, height: 190)

            Circle()
                .stroke(appState.themeColor.opacity(0.16), lineWidth: 10)
                .frame(width: 170, height: 170)

            Circle()
                .stroke(appState.themeColor.opacity(0.08), lineWidth: 18)
                .frame(width: 205, height: 205)

            Image(systemName: "checkmark")
                .font(.system(size: 70, weight: .heavy))
                .foregroundStyle(appState.themeColor.opacity(0.25))
                .offset(y: 1)

            Image(systemName: "checkmark")
                .font(.system(size: 64, weight: .heavy))
                .foregroundStyle(appState.themeColor.opacity(0.9))
                .shadow(color: appState.themeColor.opacity(0.22), radius: 10, x: 0, y: 8)

            Group {
                Image(systemName: "sparkle")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(appState.themeColor.opacity(0.55))
                    .offset(x: -86, y: -42)
                Image(systemName: "sparkle")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(appState.themeColor.opacity(0.35))
                    .offset(x: 90, y: -18)
                Image(systemName: "sparkle")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(appState.themeColor.opacity(0.45))
                    .offset(x: 78, y: 46)
                Circle().fill(.orange.opacity(0.45)).frame(width: 8, height: 8).offset(x: -72, y: 62)
                RoundedRectangle(cornerRadius: 3).fill(.yellow.opacity(0.55)).frame(width: 10, height: 6).rotationEffect(.degrees(18)).offset(x: -20, y: -88)
                RoundedRectangle(cornerRadius: 3).fill(.blue.opacity(0.45)).frame(width: 10, height: 6).rotationEffect(.degrees(-24)).offset(x: 34, y: -92)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Streak Card

struct StreakCard: View {
    @EnvironmentObject var appState: AppState
    let streak: Int
    let isNewRecord: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(appState.themeColor.opacity(0.10))
                    .frame(width: 42, height: 42)
                Image(systemName: "flame.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.orange.opacity(0.9))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Current Streak")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                Text("\(streak) day\(streak == 1 ? "" : "s")")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                Text("Keep up the good work!")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            if isNewRecord {
                Text("NEW RECORD!")
                    .font(.system(size: 11, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(appState.themeColor.opacity(0.14)))
                    .foregroundStyle(appState.themeColor)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 18).fill(.white.opacity(0.75)))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(appState.themeColor.opacity(0.10), lineWidth: 1))
    }
}

// MARK: - Buttons

struct PrimaryPillButton: View {
    @EnvironmentObject var appState: AppState
    let title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Capsule().fill(appState.themeColor))
                .shadow(color: appState.themeColor.opacity(0.25), radius: 10, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }
}

struct SecondaryPillButton: View {
    @EnvironmentObject var appState: AppState
    let title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(appState.themeColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Capsule().fill(.white.opacity(0.65)))
                .overlay(Capsule().stroke(appState.themeColor.opacity(0.18), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FocusDoneView(selectedTab: .constant(.tasks), elapsedTime: 2700)
        .environmentObject(AppState())
}
