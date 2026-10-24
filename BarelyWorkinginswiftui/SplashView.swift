import SwiftUI
import AVFoundation

// MARK: - Splash Sound Player

private class SplashSoundPlayer {
    static let shared = SplashSoundPlayer()
    private var player: AVAudioPlayer?

    func playCorrect() {
        // Use system sound as fallback — sound ID 1057 is a clean "ding"
        // We generate a short cheerful tone programmatically via AudioServicesPlaySystemSound
        AudioServicesPlaySystemSound(1057)
    }
}

// MARK: - Splash View

struct SplashView: View {
    @EnvironmentObject var appState: AppState

    // Phase control
    @State private var phase: SplashPhase = .hidden

    // Letter-by-letter reveal for "Kesty"
    private let kestyLetters: [String] = ["K", "e", "s", "t", "y"]
    @State private var visibleLetters: Int = 0

    // Checkmark
    @State private var checkScale: CGFloat = 0
    @State private var checkOpacity: Double = 0

    // Text morph
    @State private var showKeepStudy: Bool = false
    @State private var kestyOpacity: Double = 1
    @State private var keepStudyOpacity: Double = 0

    enum SplashPhase {
        case hidden, revealingLetters, showingCheck, morphingText, done
    }

    var body: some View {
        ZStack {
            appState.bgColor.ignoresSafeArea()
            appState.themeColor.opacity(0.12).ignoresSafeArea()

            VStack(spacing: 0) {
                // Main text area
                ZStack(alignment: .center) {

                    // "Kesty" — letter by letter
                    HStack(spacing: 0) {
                        ForEach(0..<kestyLetters.count, id: \.self) { i in
                            Text(kestyLetters[i])
                                .font(.system(size: 54, weight: .heavy, design: .rounded))
                                .foregroundColor(AppTheme.textPrimary)
                                .opacity(visibleLetters > i ? 1 : 0)
                                .offset(y: visibleLetters > i ? 0 : 18)
                                .animation(
                                    .spring(response: 0.35, dampingFraction: 0.65)
                                    .delay(Double(i) * 0.09),
                                    value: visibleLetters
                                )
                        }

                        // Green checkmark — appears right after "K"
                        ZStack {
                            // Glow behind checkmark
                            Image(systemName: "checkmark")
                                .font(.system(size: 22, weight: .black))
                                .foregroundColor(.green.opacity(0.3))
                                .blur(radius: 6)
                                .scaleEffect(checkScale * 1.4)
                                .opacity(checkOpacity)

                            Image(systemName: "checkmark")
                                .font(.system(size: 22, weight: .black))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(red: 0.4, green: 0.9, blue: 0.3),
                                                 Color(red: 0.2, green: 0.75, blue: 0.2)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .scaleEffect(checkScale)
                                .opacity(checkOpacity)
                                .shadow(color: .green.opacity(0.4), radius: 4, x: 0, y: 2)
                        }
                        .frame(width: 30, height: 30)
                        .offset(x: -4, y: -14) // float above baseline, next to K's top-right
                        .opacity(kestyOpacity)
                    }
                    .opacity(kestyOpacity)
                    .shadow(color: AppTheme.textPrimary.opacity(0.2), radius: 0, x: 0, y: 4)

                    // "Keep Study" — fades in on morph
                    Text("Keep Study")
                        .font(.system(size: 54, weight: .heavy, design: .rounded))
                        .foregroundColor(AppTheme.textPrimary)
                        .opacity(keepStudyOpacity)
                        .scaleEffect(keepStudyOpacity == 0 ? 0.88 : 1.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.72), value: keepStudyOpacity)
                        .shadow(color: AppTheme.textPrimary.opacity(0.2), radius: 0, x: 0, y: 4)
                }

                // Subtle tagline (appears with Keep Study)
                Text("stay consistent. stay winning.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary.opacity(0.4))
                    .opacity(keepStudyOpacity)
                    .offset(y: keepStudyOpacity == 0 ? 6 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.15), value: keepStudyOpacity)
                    .padding(.top, 10)
            }
        }
        .onAppear { startSequence() }
    }

    // MARK: - Animation Sequence

    private func startSequence() {
        // Step 1: Reveal "Kesty" letters one by one
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation { visibleLetters = kestyLetters.count }
        }

        // Step 2: Pop in checkmark + play sound
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.45)) {
                checkScale = 1.0
                checkOpacity = 1.0
            }
            SplashSoundPlayer.shared.playCorrect()
        }

        // Step 3: Bounce the checkmark once
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.3)) {
                checkScale = 1.25
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    checkScale = 1.0
                }
            }
        }

        // Step 4: Morph "Kesty" → "Keep Study"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.65) {
            withAnimation(.easeIn(duration: 0.22)) {
                kestyOpacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                withAnimation(.spring(response: 0.48, dampingFraction: 0.7)) {
                    keepStudyOpacity = 1
                }
            }
        }
    }
}

#Preview {
    SplashView()
        .environmentObject(AppState())
}
