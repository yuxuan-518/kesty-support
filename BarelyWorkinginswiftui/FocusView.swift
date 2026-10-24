import SwiftUI
import Combine
import AVFoundation

struct FocusView: View {
    @EnvironmentObject var appState: AppState
    @Binding var selectedTab: AppTab

    @State private var selHour: Int = 0
    @State private var selMin: Int = 25
    @State private var selSec: Int = 0

    @State private var isRunning = false
    @State private var totalDuration: TimeInterval = 0
    @State private var remaining: TimeInterval = 0
    @State private var elapsedTime: TimeInterval = 0

    @State private var showTooShortPopup = false
    @State private var showNotRecordedPopup = false
    @State private var goNextPage = false

    // Music
    @State private var selectedMusic: MusicTrack? = nil
    @State private var showMusicPicker = false
    @State private var audioPlayer: AVAudioPlayer? = nil

    // Task linking
    @State private var linkedTaskId: UUID? = nil
    @State private var showTaskPicker = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var duration: TimeInterval {
        TimeInterval(selHour * 3600 + selMin * 60 + selSec)
    }

    private var displaySeconds: Int {
        Int(isRunning ? remaining : duration)
    }

    private var linkedTask: TaskItem? {
        guard let id = linkedTaskId else { return nil }
        return appState.tasks.first { $0.id == id }
    }

    private var sessionLabel: String {
        if let task = linkedTask { return task.title }
        return "Untitled Session"
    }

    var body: some View {
        ZStack {
            appState.bgColor.ignoresSafeArea()

            VStack(spacing: 18) {
                let h = displaySeconds / 3600
                let m = (displaySeconds % 3600) / 60
                let s = displaySeconds % 60

                // Time display
                HStack(spacing: 10) {
                    FlipTimeBox(text: String(format: "%02d", h), themeColor: appState.themeColor, isRunning: isRunning)
                    colonText
                    FlipTimeBox(text: String(format: "%02d", m), themeColor: appState.themeColor, isRunning: isRunning)
                    colonText
                    FlipTimeBox(text: String(format: "%02d", s), themeColor: appState.themeColor, isRunning: isRunning)
                }
                .padding(.top, 20)

                // Wheel picker
                HMSWheelPicker(hour: $selHour, minute: $selMin, second: $selSec)
                    .frame(height: 200)
                    .padding(.horizontal, 18)
                    .disabled(isRunning)
                    .opacity(isRunning ? 0.5 : 1)

                // Task label — tappable to pick/change task
                Button { if !isRunning { showTaskPicker = true } } label: {
                    HStack(spacing: 8) {
                        Image(systemName: linkedTask == nil ? "square.dashed" : "checkmark.circle")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(linkedTask == nil ? AppTheme.textSecondary : appState.themeColor)
                        Text(sessionLabel)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(linkedTask == nil ? .black.opacity(0.45) : appState.themeColor)
                            .lineLimit(1)
                        if !isRunning {
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                    }
                    .padding(.horizontal, 16).padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.black.opacity(0.04)))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(
                        linkedTask == nil ? Color.black.opacity(0.10) : appState.themeColor.opacity(0.25), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .disabled(isRunning)

                // Start button
                Button { startCountdown() } label: {
                    Text(isRunning ? "Running..." : "Start")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 230, height: 44)
                        .background(appState.themeColor)
                        .cornerRadius(12)
                        .opacity((duration <= 0 || isRunning) ? 0.55 : 1)
                }
                .disabled(duration <= 0 || isRunning)

                // Music picker button
                Button { showMusicPicker = true } label: {
                    HStack(spacing: 8) {
                        Image(systemName: selectedMusic == nil ? "speaker.slash.fill" : "music.note")
                            .font(.system(size: 13, weight: .semibold))
                        Text(selectedMusic == nil ? "No Music" : selectedMusic!.displayName)
                            .font(.system(size: 13, weight: .semibold))
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(selectedMusic == nil ? AppTheme.textSecondary : appState.themeColor)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(selectedMusic == nil
                                  ? Color.black.opacity(0.05)
                                  : appState.themeColor.opacity(0.12))
                    )
                    .overlay(
                        Capsule()
                            .stroke(selectedMusic == nil
                                    ? Color.black.opacity(0.08)
                                    : appState.themeColor.opacity(0.25), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)

                // Progress bar
                ProgressBarView(remaining: remaining, total: totalDuration, themeColor: appState.themeColor)
                    .padding(.horizontal, 18)

                Spacer()

                // Cancel / Stop
                HStack {
                    Spacer()
                    Button {
                        if isRunning {
                            stopAndDecide()
                        } else {
                            selHour = 0; selMin = 25; selSec = 0
                            selectedTab = .tasks
                        }
                    } label: {
                        Text(isRunning ? "Stop" : "Cancel")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(appState.themeColor.opacity(0.9))
                    }
                    Spacer()
                }
                .padding(.bottom, 18)
            }

            // Popups
            if showTooShortPopup {
                FocusPopup(message: "Time is too short.\nPlease set at least 5 seconds.") {
                    withAnimation { showTooShortPopup = false }
                }
            }

            if showNotRecordedPopup {
                FocusPopup(message: "Session too short to record.\nPlease focus for at least 5 seconds.") {
                    withAnimation { showNotRecordedPopup = false }
                }
            }
        }
        .onReceive(timer) { _ in
            guard isRunning else { return }
            tick()
        }
        .onAppear {
            // If navigated from a task's Start button, auto-link it
            if let taskId = appState.focusTaskId {
                linkedTaskId = taskId
                appState.focusTaskId = nil
                // If countdown task, pre-fill a sensible session duration
                if let task = appState.tasks.first(where: { $0.id == taskId }),
                   task.isCountdown && task.targetSeconds > 0 {
                    let remaining = max(0, task.targetSeconds - task.accumulatedSeconds)
                    if remaining > 0 {
                        selHour = remaining / 3600
                        selMin  = (remaining % 3600) / 60
                        selSec  = remaining % 60
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $goNextPage) {
            FocusDoneView(selectedTab: $selectedTab, elapsedTime: elapsedTime)
                .environmentObject(appState)
        }
        .sheet(isPresented: $showMusicPicker) {
            MusicPickerSheet(selectedMusic: $selectedMusic, themeColor: appState.themeColor) { track in
                playMusic(track)
            }
            .presentationDetents([.fraction(0.6)])
            .colorScheme(.light)
        }
        .sheet(isPresented: $showTaskPicker) {
            TaskPickerSheet(linkedTaskId: $linkedTaskId, themeColor: appState.themeColor)
                .environmentObject(appState)
                .presentationDetents([.fraction(0.55)])
                .colorScheme(.light)
        }
    }

    // MARK: Helpers
    private var colonText: some View {
        Text(":")
            .font(.system(size: 34, weight: .semibold))
            .foregroundColor(.black.opacity(0.5))
    }

    private func startCountdown() {
        if duration < 5 {
            withAnimation { showTooShortPopup = true }
            return
        }
        totalDuration = duration
        remaining = duration
        isRunning = true
    }

    private func stopAndDecide() {
        isRunning = false
        audioPlayer?.stop()
        let elapsed = totalDuration - remaining
        if elapsed < 5 {
            withAnimation { showNotRecordedPopup = true }
        } else {
            elapsedTime = elapsed
            appState.recordSession(duration: elapsed)
            if let id = linkedTaskId { appState.addTime(Int(elapsed), to: id) }
            goNextPage = true
        }
    }

    private func tick() {
        if remaining > 0 {
            remaining -= 1
        } else {
            remaining = 0
            isRunning = false
            audioPlayer?.stop()
            elapsedTime = totalDuration
            appState.recordSession(duration: totalDuration)
            if let id = linkedTaskId { appState.addTime(Int(totalDuration), to: id) }
            goNextPage = true
        }
    }

    private func playMusic(_ track: MusicTrack?) {
        audioPlayer?.stop()
        audioPlayer = nil
        guard let track = track else { return }
        // Try common audio extensions
        let extensions = ["mp3", "wav", "m4a", "aac", "caf"]
        for ext in extensions {
            if let url = Bundle.main.url(forResource: track.fileName, withExtension: ext) {
                audioPlayer = try? AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1 // loop forever
                audioPlayer?.volume = 0.6
                audioPlayer?.play()
                return
            }
        }
    }
}

// MARK: - Progress Bar

private struct ProgressBarView: View {
    let remaining: TimeInterval
    let total: TimeInterval
    let themeColor: Color

    var progress: Double {
        guard total > 0 else { return 0 }
        return max(0, min(remaining / total, 1))
    }

    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.08))
                        .frame(height: 10)

                    RoundedRectangle(cornerRadius: 10)
                        .fill(themeColor)
                        .frame(width: geo.size.width * CGFloat(progress), height: 10)
                        .animation(.linear(duration: 0.5), value: progress)
                }
            }
            .frame(height: 10)
        }
    }
}

// MARK: - Flip Time Box

private struct FlipTimeBox: View {
    let text: String
    let themeColor: Color
    let isRunning: Bool

    @State private var flipped = false
    @State private var displayText: String = ""
    @State private var nextText: String = ""

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(themeColor.opacity(0.13))
                .frame(width: 72, height: 68)

            if isRunning {
                // Top half (static current)
                VStack(spacing: 0) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(themeColor.opacity(0.13))
                            .frame(width: 72, height: 68)
                        Text(displayText)
                            .font(.system(size: 34, weight: .semibold))
                            .foregroundColor(themeColor)
                    }
                    .clipped()
                }

                // Flip card overlay
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(themeColor.opacity(0.18))
                        .frame(width: 72, height: 68)
                    Text(flipped ? nextText : displayText)
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundColor(themeColor)
                }
                .rotation3DEffect(
                    .degrees(flipped ? -90 : 0),
                    axis: (x: 1, y: 0, z: 0),
                    anchor: .bottom,
                    perspective: 0.4
                )
                .frame(width: 72, height: 68)
            } else {
                Text(text)
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundColor(themeColor)
            }
        }
        .frame(width: 72, height: 68)
        .onChange(of: text) {
            guard isRunning else {
                displayText = text
                return
            }
            nextText = text
            withAnimation(.easeIn(duration: 0.15)) {
                flipped = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                displayText = text
                flipped = false
            }
        }
        .onAppear {
            displayText = text
            nextText = text
        }
    }
}

// MARK: - Wheel Picker

private struct HMSWheelPicker: View {
    @Binding var hour: Int
    @Binding var minute: Int
    @Binding var second: Int

    var body: some View {
        HStack(spacing: 0) {
            wheel(title: "hours", range: 0...23, selection: $hour)
            wheel(title: "min",   range: 0...59, selection: $minute)
            wheel(title: "sec",   range: 0...59, selection: $second)
        }
        .pickerStyle(.wheel)
    }

    private func wheel(title: String, range: ClosedRange<Int>, selection: Binding<Int>) -> some View {
        VStack(spacing: 4) {
            Picker("", selection: selection) {
                ForEach(Array(range), id: \.self) { v in
                    Text("\(v)")
                        .foregroundColor(.black)
                        .tag(v)
                }
            }
            .labelsHidden()
            .colorScheme(.light)

            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.black.opacity(0.45))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Popup

struct FocusPopup: View {
    let message: String
    let onOK: () -> Void
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            Color.black.opacity(0.18).ignoresSafeArea()

            VStack(spacing: 12) {
                Text(message)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.top, 14)

                Divider().opacity(0.12)

                Button(action: onOK) {
                    Text("OK")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(appState.themeColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
            }
            .frame(width: 260)
            .background(Color.white.opacity(0.92))
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.12), radius: 18, x: 0, y: 10)
        }
    }
}

#Preview {
    FocusView(selectedTab: .constant(.focus))
        .environmentObject(AppState())
}

// MARK: - Music Track Model

enum MusicTrack: String, CaseIterable, Identifiable {
    case piano   = "piano"
    case rain    = "rain"
    case caffee  = "caffee"
    case wind    = "wind"
    case forest  = "forest"
    case ambient = "Ambient Drone Solfeggio"

    var id: String { rawValue }
    var fileName: String { rawValue }

    var displayName: String {
        switch self {
        case .piano:   return "Piano"
        case .rain:    return "Rain"
        case .caffee:  return "Café"
        case .wind:    return "Wind"
        case .forest:  return "Forest"
        case .ambient: return "Ambient Drone"
        }
    }

    var icon: String {
        switch self {
        case .piano:   return "pianokeys"
        case .rain:    return "cloud.rain.fill"
        case .caffee:  return "cup.and.saucer.fill"
        case .wind:    return "wind"
        case .forest:  return "tree.fill"
        case .ambient: return "waveform.path.ecg"
        }
    }
}

// MARK: - Music Picker Sheet

struct MusicPickerSheet: View {
    @Binding var selectedMusic: MusicTrack?
    let themeColor: Color
    let onSelect: (MusicTrack?) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Handle bar
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.black.opacity(0.15))
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 16)

            Text("Background Music")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
                .padding(.bottom, 16)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    // No music option
                    musicRow(
                        icon: "speaker.slash.fill",
                        name: "No Music",
                        isSelected: selectedMusic == nil
                    ) {
                        selectedMusic = nil
                        onSelect(nil)
                        dismiss()
                    }

                    ForEach(MusicTrack.allCases) { track in
                        musicRow(
                            icon: track.icon,
                            name: track.displayName,
                            isSelected: selectedMusic == track
                        ) {
                            selectedMusic = track
                            onSelect(track)
                            dismiss()
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .background(Color(UIColor.systemBackground))
    }

    private func musicRow(icon: String, name: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? themeColor.opacity(0.15) : Color.black.opacity(0.06))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(isSelected ? themeColor : AppTheme.textSecondary)
                }
                Text(name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(themeColor)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? themeColor.opacity(0.07) : Color.black.opacity(0.03))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? themeColor.opacity(0.2) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Task Picker Sheet

struct TaskPickerSheet: View {
    @EnvironmentObject var appState: AppState
    @Binding var linkedTaskId: UUID?
    let themeColor: Color
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.black.opacity(0.2))
                .frame(width: 36, height: 4)
                .padding(.top, 10).padding(.bottom, 14)

            Text("Link a Task")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
                .padding(.bottom, 14)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 8) {
                    taskRow(id: nil, title: "No task (Untitled Session)", subtitle: nil, isSelected: linkedTaskId == nil)
                    ForEach(appState.tasks.filter { !$0.isDone }) { task in
                        let sub: String? = task.isCountdown
                            ? "⏱ \(task.displayTime.isEmpty ? "0 / \(formatSecs(task.targetSeconds))" : task.displayTime)"
                            : (task.displayTime.isEmpty ? nil : "▶ \(task.displayTime)")
                        taskRow(id: task.id, title: task.title, subtitle: sub, isSelected: linkedTaskId == task.id)
                    }
                }
                .padding(.horizontal, 20).padding(.bottom, 24)
            }
        }
        .background(appState.bgColor)
        .colorScheme(.light)
    }

    private func taskRow(id: UUID?, title: String, subtitle: String?, isSelected: Bool) -> some View {
        Button {
            linkedTaskId = id
            dismiss()
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? themeColor.opacity(0.15) : Color.black.opacity(0.06))
                        .frame(width: 40, height: 40)
                    Image(systemName: id == nil ? "square.dashed" : "checkmark.circle")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(isSelected ? themeColor : AppTheme.textSecondary)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.system(size: 15, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                    if let sub = subtitle {
                        Text(sub).font(.system(size: 12, weight: .medium)).foregroundStyle(AppTheme.textSecondary)
                    }
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill").font(.system(size: 20)).foregroundStyle(themeColor)
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
            .background(RoundedRectangle(cornerRadius: 14).fill(isSelected ? themeColor.opacity(0.07) : Color.black.opacity(0.03)))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(isSelected ? themeColor.opacity(0.2) : Color.clear, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func formatSecs(_ s: Int) -> String {
        let h = s / 3600; let m = (s % 3600) / 60
        return h > 0 ? "\(h)h \(m)min" : "\(m)min"
    }
}
