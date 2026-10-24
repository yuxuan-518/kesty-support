import SwiftUI

// MARK: - Theme Color

struct ThemeColorView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            appState.bgColor.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    // Top bar
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                        Text("Appearance")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        Color.clear.frame(width: 24)
                    }
                    .padding(.horizontal, 6)

                    // Preview card
                    HStack(spacing: 14) {
                        Circle()
                            .fill(appState.themeColor.opacity(0.18))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Image(systemName: "paintbrush.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(appState.themeColor)
                            )
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Current Theme")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                            HStack(spacing: 8) {
                                Circle().fill(appState.themeColor).frame(width: 14, height: 14)
                                Text(appState.selectedThemeColor)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                                Text("+")
                                    .foregroundColor(AppTheme.textSecondary)
                                Circle().fill(appState.bgColor).frame(width: 14, height: 14)
                                    .overlay(Circle().stroke(AppTheme.textSecondary.opacity(0.3), lineWidth: 1))
                                Text(appState.selectedBgColor)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                        }
                        Spacer()
                    }
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(white: 1.0, opacity: 0.7)))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(appState.themeColor.opacity(0.15), lineWidth: 1))

                    // MARK: Accent Color Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ACCENT COLOR")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(.horizontal, 4)

                        // Color swatches grid
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 6), spacing: 10) {
                            ForEach(AppTheme.themeColors) { option in
                                Button {
                                    appState.selectedThemeColor = option.name
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(option.color)
                                            .frame(width: 42, height: 42)
                                        if appState.selectedThemeColor == option.name {
                                            Circle()
                                                .stroke(.white, lineWidth: 3)
                                                .frame(width: 42, height: 42)
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(16)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color(white: 1.0, opacity: 0.7)))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(appState.themeColor.opacity(0.12), lineWidth: 1))

                        // Accent color list with names
                        VStack(spacing: 0) {
                            ForEach(AppTheme.themeColors) { option in
                                Button {
                                    appState.selectedThemeColor = option.name
                                } label: {
                                    HStack(spacing: 12) {
                                        Circle()
                                            .fill(option.color)
                                            .frame(width: 22, height: 22)
                                        Text(option.name)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(AppTheme.textPrimary)
                                        Spacer()
                                        if appState.selectedThemeColor == option.name {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(option.color)
                                                .font(.system(size: 18))
                                        }
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                                    .background(
                                        appState.selectedThemeColor == option.name
                                            ? option.color.opacity(0.08)
                                            : Color.clear
                                    )
                                }
                                .buttonStyle(.plain)
                                if option.id != AppTheme.themeColors.last?.id {
                                    Rectangle().fill(Color(white: 0.0, opacity: 0.12)).frame(height: 0.5).padding(.leading, 48)
                                }
                            }
                        }
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color(white: 1.0, opacity: 0.7)))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(appState.themeColor.opacity(0.12), lineWidth: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    // MARK: Background Color Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("BACKGROUND COLOR")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(.horizontal, 4)

                        // Background swatches grid
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                            ForEach(AppTheme.bgColors) { option in
                                Button {
                                    appState.selectedBgColor = option.name
                                } label: {
                                    VStack(spacing: 5) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(option.color)
                                                .frame(height: 52)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(
                                                            appState.selectedBgColor == option.name
                                                                ? appState.themeColor
                                                                : AppTheme.textSecondary.opacity(0.2),
                                                            lineWidth: appState.selectedBgColor == option.name ? 2.5 : 1
                                                        )
                                                )
                                            if appState.selectedBgColor == option.name {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.system(size: 18, weight: .bold))
                                                    .foregroundColor(appState.themeColor)
                                            }
                                        }
                                        Text(option.name)
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color(white: 1.0, opacity: 0.7)))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(appState.themeColor.opacity(0.12), lineWidth: 1))
                    }

                    Button { dismiss() } label: {
                        Text("Done")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Capsule().fill(appState.themeColor))
                            .shadow(color: appState.themeColor.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }
                .padding(.horizontal, 14)
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Language

struct LanguageView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var showRedirectAlert = false

    private let languages = [
        "English", "简体中文", "日本語", "한국어", "Español",
        "Français", "Deutsch", "Русский", "Italiano", "Português",
        "Nederlands", "Türkçe", "العربية", "ไทย", "हिन्दी",
        "Bahasa Indonesia", "中文 (繁體)", "Tiếng Việt"
    ]

    var body: some View {
        ZStack {
            appState.bgColor.ignoresSafeArea()

            ScrollView(showsIndicators: true) {
                VStack(spacing: 14) {
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                        Text("App Language")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        Color.clear.frame(width: 24)
                    }
                    .padding(.horizontal, 6)

                    // Info banner
                    HStack(spacing: 10) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(appState.themeColor)
                            .font(.system(size: 16))
                        Text("Language changes take effect after restarting the app. You may also need to update your device language in iOS Settings.")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(appState.themeColor.opacity(0.08)))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(appState.themeColor.opacity(0.15), lineWidth: 1))

                    VStack(spacing: 0) {
                        ForEach(languages, id: \.self) { lang in
                            Button {
                                appState.selectedLanguage = lang
                                showRedirectAlert = true
                            } label: {
                                HStack(spacing: 12) {
                                    Text(lang)
                                        .font(.system(size: 15, weight: appState.selectedLanguage == lang ? .bold : .semibold))
                                        .foregroundColor(appState.selectedLanguage == lang ? appState.themeColor : AppTheme.textPrimary)
                                    Spacer()
                                    if appState.selectedLanguage == lang {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(appState.themeColor)
                                            .font(.system(size: 18))
                                    }
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 13)
                                .background(
                                    appState.selectedLanguage == lang
                                        ? appState.themeColor.opacity(0.07)
                                        : Color.clear
                                )
                            }
                            .buttonStyle(.plain)

                            if lang != languages.last {
                                Rectangle().fill(Color(white: 0.0, opacity: 0.12)).frame(height: 0.5).padding(.leading, 14)
                            }
                        }
                    }
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(white: 1.0, opacity: 0.7)))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(appState.themeColor.opacity(0.12), lineWidth: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 14)
                .padding(.top, 10)
                .padding(.bottom, 20)
            }
        }
        .navigationBarHidden(true)
        .alert("Language Updated", isPresented: $showRedirectAlert) {
            Button("Go to iOS Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Later", role: .cancel) {}
        } message: {
            Text("To fully apply \(appState.selectedLanguage), please also change the language in your iPhone Settings > Barely Working.")
        }
    }
}

// MARK: - Daily Goals

struct DailyGoalsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var showAddItem = false
    @State private var newItemTitle = ""
    @State private var editingTaskId: UUID? = nil
    @State private var editingText: String = ""
    @FocusState private var editFieldFocused: Bool

    private var sortedHistoryDates: [String] {
        appState.dailyTaskHistory.keys.sorted().reversed()
    }

    private func displayDate(_ key: String) -> String {
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        guard let date = fmt.date(from: key) else { return key }
        let out = DateFormatter(); out.dateStyle = .medium
        return out.string(from: date)
    }

    private func commitTaskEdit() {
        guard let id = editingTaskId else { return }
        let trimmed = editingText.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty, let idx = appState.tasks.firstIndex(where: { $0.id == id }) {
            appState.tasks[idx].title = trimmed
        }
        editingTaskId = nil; editingText = ""; editFieldFocused = false
    }

    var body: some View {
        ZStack {
            appState.bgColor.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    dgNavBar
                    todayTasksCard
                    pastDaysCard
                }
                .padding(.horizontal, 14).padding(.top, 10).padding(.bottom, 24)
            }
        }
        .navigationBarHidden(true)
    }

    private var dgNavBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(appState.themeColor)
            }
            Spacer()
            Text("Daily Goals")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
            Spacer()
            Color.clear.frame(width: 24)
        }
        .padding(.horizontal, 6)
    }

    private var todayTasksCard: some View {
        SoftCardView {
            HStack {
                Text("Today's Tasks")
                    .font(.system(size: 16, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
                Spacer()
                Text("\(appState.completedTasksCount)/\(appState.totalTasksCount)")
                    .font(.system(size: 13, weight: .semibold)).foregroundStyle(appState.themeColor)
            }
            dgTaskList
        }
    }

    private func deleteDailyTask(at index: Int) {
        guard index < appState.tasks.count else { return }
        withAnimation { appState.tasks.remove(at: index) }
    }

    private var dgTaskList: some View {
        VStack(spacing: 0) {
            ForEach(Array(appState.tasks.enumerated()), id: \.element.id) { i, task in
                SwipeToDeleteRow {
                    dgTaskRow(task: task, index: i)
                        .padding(.vertical, 10).padding(.horizontal, 12)
                } onDelete: { deleteDailyTask(at: i) }
                if i < appState.tasks.count - 1 {
                    Rectangle().fill(Color(white: 0.0, opacity: 0.08)).frame(height: 0.5).padding(.horizontal, 12)
                }
            }
            if showAddItem {
                Rectangle().fill(Color(white: 0.0, opacity: 0.08)).frame(height: 0.5).padding(.horizontal, 12)
                HStack {
                    TextField("New task...", text: $newItemTitle)
                        .font(.system(size: 14, weight: .medium)).foregroundColor(AppTheme.textPrimary)
                        .submitLabel(.done)
                        .onSubmit {
                            if !newItemTitle.isEmpty { appState.addTask(newItemTitle); newItemTitle = "" }
                            showAddItem = false
                        }
                    Button("Add") {
                        if !newItemTitle.isEmpty { appState.addTask(newItemTitle); newItemTitle = "" }
                        showAddItem = false
                    }
                    .font(.system(size: 13, weight: .bold)).foregroundStyle(appState.themeColor)
                }
                .padding(.vertical, 10).padding(.horizontal, 12)
            }
            Rectangle().fill(Color(white: 0.0, opacity: 0.08)).frame(height: 0.5).padding(.horizontal, 12)
            Button { showAddItem = true } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus").font(.system(size: 14, weight: .bold)).foregroundStyle(appState.themeColor)
                    Text("Add new daily task").font(.system(size: 14, weight: .semibold)).foregroundStyle(appState.themeColor)
                    Spacer()
                }
                .padding(.vertical, 10).padding(.horizontal, 12)
            }
            .buttonStyle(.plain)
        }
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(white: 1.0, opacity: 0.28)))
    }

    private func dgTaskRow(task: TaskItem, index: Int) -> some View {
        HStack(spacing: 12) {
            Button { appState.toggleTask(task) } label: {
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(task.isDone ? appState.themeColor : AppTheme.textSecondary.opacity(0.5))
            }.buttonStyle(.plain)

            dgTaskContent(task: task)

            // Time display
            if !task.displayTime.isEmpty {
                Text(task.displayTime)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(task.isCountdown && task.progressFraction >= 1.0
                        ? appState.themeColor : AppTheme.textSecondary)
                    .lineLimit(1)
            }
        }
    }

    @ViewBuilder
    private func dgTaskContent(task: TaskItem) -> some View {
        if editingTaskId == task.id {
            TextField("", text: $editingText)
                .font(.system(size: 15, weight: .semibold)).foregroundColor(AppTheme.textPrimary)
                .focused($editFieldFocused).submitLabel(.done).onSubmit { commitTaskEdit() }
                .frame(maxWidth: .infinity, alignment: .leading)
            Button { commitTaskEdit() } label: {
                Image(systemName: "checkmark.circle.fill").foregroundColor(appState.themeColor).font(.system(size: 18))
            }.buttonStyle(.plain)
        } else {
            Text(task.title)
                .font(.system(size: 15, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                .strikethrough(task.isDone, color: AppTheme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture(count: 2) { editingTaskId = task.id; editingText = task.title; editFieldFocused = true }
                .onTapGesture(count: 1) {}
        }
    }

    // Always shown — empty state if no history
    private var pastDaysCard: some View {
        SoftCardView {
            HStack {
                Text("Past Days")
                    .font(.system(size: 16, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
                Spacer()
                if !sortedHistoryDates.isEmpty {
                    Text("\(sortedHistoryDates.count) days")
                        .font(.system(size: 12, weight: .semibold)).foregroundStyle(AppTheme.textSecondary)
                }
            }

            if sortedHistoryDates.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 28)).foregroundStyle(appState.themeColor.opacity(0.35))
                        Text("No past tasks yet")
                            .font(.system(size: 13, weight: .medium)).foregroundStyle(AppTheme.textSecondary)
                        Text("Completed tasks will appear here after midnight")
                            .font(.system(size: 11)).foregroundStyle(AppTheme.textSecondary.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 24)
                    Spacer()
                }
            } else {
                VStack(spacing: 8) {
                    ForEach(sortedHistoryDates, id: \.self) { dateKey in
                        pastDayRow(dateKey: dateKey)
                    }
                }
            }
        }
    }

    private func pastDayRow(dateKey: String) -> some View {
        let dayTasks = appState.dailyTaskHistory[dateKey] ?? []
        let done = dayTasks.filter { $0.isDone }.count
        let allDone = done == dayTasks.count && dayTasks.count > 0
        return DisclosureGroup {
            VStack(spacing: 0) {
                ForEach(dayTasks) { task in
                    HStack(spacing: 10) {
                        Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 14))
                            .foregroundStyle(task.isDone ? appState.themeColor : AppTheme.textSecondary.opacity(0.4))
                        Text(task.title)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(task.isDone ? AppTheme.textSecondary : AppTheme.textPrimary)
                            .strikethrough(task.isDone, color: AppTheme.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        // Show time for past tasks too
                        if !task.displayTime.isEmpty {
                            Text(task.displayTime)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                    }
                    .padding(.vertical, 8).padding(.horizontal, 12)
                    if task.id != dayTasks.last?.id {
                        Rectangle().fill(Color(white: 0.0, opacity: 0.08)).frame(height: 0.5).padding(.horizontal, 12)
                    }
                }
            }
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(white: 1.0, opacity: 0.28)))
            .padding(.top, 6)
        } label: {
            HStack {
                Text(displayDate(dateKey))
                    .font(.system(size: 14, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                Spacer()
                HStack(spacing: 4) {
                    if allDone { Image(systemName: "checkmark.circle.fill").font(.system(size: 12)).foregroundStyle(appState.themeColor) }
                    Text("\(done)/\(dayTasks.count)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(allDone ? appState.themeColor : AppTheme.textSecondary)
                }
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 14).fill(appState.themeColor.opacity(0.05)))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(appState.themeColor.opacity(0.10), lineWidth: 1))
        .tint(AppTheme.textPrimary)
    }
}

// MARK: - Long-Term Plans

struct LongTermPlansView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: LongTermPlan? = nil
    @State private var showAddPlan = false

    var body: some View {
        NavigationStack {
            ZStack {
                appState.bgColor.ignoresSafeArea()

                LinearGradient(
                    colors: [appState.themeColor.opacity(0.18), Color.clear, appState.themeColor.opacity(0.13)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        HStack {
                            Button { dismiss() } label: {
                                Image(systemName: "chevron.left").font(.system(size: 18, weight: .semibold)).foregroundStyle(appState.themeColor)
                            }
                            Spacer()
                            Text("Long-Term Plans").font(.system(size: 20, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
                            Spacer()
                            Color.clear.frame(width: 24)
                        }
                        .padding(.horizontal, 6)

                        ForEach(appState.longTermPlans) { plan in
                            NavigationLink {
                                PlanDetailView(plan: plan).environmentObject(appState)
                            } label: {
                                PlanCardView(plan: plan)
                            }
                            .buttonStyle(.plain)
                        }

                        // Add button
                        Button { showAddPlan = true } label: {
                            SoftCardView {
                                HStack(spacing: 10) {
                                    Image(systemName: "plus").font(.system(size: 16, weight: .bold)).foregroundStyle(appState.themeColor)
                                    Text("Add new long-term plan").font(.system(size: 15, weight: .semibold)).foregroundStyle(appState.themeColor)
                                    Spacer()
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 14).padding(.top, 10).padding(.bottom, 24)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showAddPlan) {
            AddPlanSheet().environmentObject(appState)
        }
    }
}

private struct PlanCardView: View {
    @EnvironmentObject var appState: AppState
    let plan: LongTermPlan

    var body: some View {
        SoftCardView {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(plan.title).font(.system(size: 18, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
                    Text(plan.dateRange).font(.system(size: 14, weight: .semibold)).foregroundStyle(AppTheme.textSecondary)
                    if plan.totalCount > 0 {
                        Text("\(plan.completedCount) / \(plan.totalCount) daily goals completed")
                            .font(.system(size: 13, weight: .semibold)).foregroundStyle(AppTheme.textSecondary)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 16, weight: .semibold)).foregroundStyle(AppTheme.textSecondary.opacity(0.7)).padding(.top, 2)
            }
        }
    }
}

// MARK: - Plan Detail

struct PlanDetailView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    let plan: LongTermPlan
    @State private var localPlan: LongTermPlan
    @State private var showAddGoal = false
    @State private var newGoalTitle = ""
    @State private var showEditSheet = false
    @State private var editingMilestoneIdx: Int? = nil
    @State private var milestonePickerMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var milestonePickerYear: Int  = Calendar.current.component(.year,  from: Date())
    @State private var editingTitleIdx: Int? = nil
    @State private var editingTitleText: String = ""

    init(plan: LongTermPlan) {
        self.plan = plan
        self._localPlan = State(initialValue: plan)
    }

    var body: some View {
        ZStack {
            appState.bgColor.ignoresSafeArea()

            LinearGradient(
                colors: [appState.themeColor.opacity(0.18), Color.clear, appState.themeColor.opacity(0.13)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(appState.themeColor)
                        }
                        Spacer()
                        Text(localPlan.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(AppTheme.textPrimary)
                        Spacer()
                        Button("Edit") { showEditSheet = true }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(appState.themeColor.opacity(0.9))
                    }
                    .padding(.horizontal, 6)

                    // Plan info card
                    SoftCardView {
                        Text(localPlan.title)
                            .font(.system(size: 18, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
                        if !localPlan.dateRange.isEmpty {
                            Text(localPlan.dateRange)
                                .font(.system(size: 14, weight: .semibold)).foregroundStyle(AppTheme.textSecondary)
                        }
                        if !localPlan.description.isEmpty {
                            Text(localPlan.description)
                                .font(.system(size: 14, weight: .medium)).foregroundStyle(AppTheme.textSecondary).padding(.top, 4)
                        }
                    }

                    // Sub-goals card
                    SoftCardView {
                        HStack {
                            Text("Sub-Goals")
                                .font(.system(size: 16, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
                            Spacer()
                            Text("\(localPlan.completedCount)/\(localPlan.totalCount)")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(appState.themeColor)
                        }

                        VStack(spacing: 0) {
                            ForEach(localPlan.goalItems.indices, id: \.self) { i in
                                VStack(spacing: 0) {
                                    SwipeActionRow(
                                        onEdit: {
                                            editingTitleIdx = i
                                            editingTitleText = localPlan.goalItems[i].title
                                            editingMilestoneIdx = nil
                                        },
                                        onDelete: {
                                            withAnimation {
                                                // Remove from today's tasks too if linked
                                                let title = localPlan.goalItems[i].title
                                                appState.tasks.removeAll { $0.title.lowercased() == title.lowercased() }
                                                localPlan.goalItems.remove(at: i)
                                                syncToAppState()
                                                if editingMilestoneIdx == i { editingMilestoneIdx = nil }
                                                if editingTitleIdx == i { editingTitleIdx = nil }
                                            }
                                        }
                                    ) {
                                        HStack(spacing: 12) {
                                            Button { toggleGoalItem(at: i) } label: {
                                                Image(systemName: localPlan.goalItems[i].isDone ? "checkmark.circle.fill" : "circle")
                                                    .font(.system(size: 22, weight: .semibold))
                                                    .foregroundStyle(localPlan.goalItems[i].isDone
                                                        ? appState.themeColor : appState.themeColor.opacity(0.3))
                                            }.buttonStyle(.plain)

                                            VStack(alignment: .leading, spacing: 2) {
                                                // Inline title edit or display
                                                if editingTitleIdx == i {
                                                    TextField("", text: $editingTitleText)
                                                        .font(.system(size: 15, weight: .semibold))
                                                        .foregroundColor(AppTheme.textPrimary)
                                                        .submitLabel(.done)
                                                        .onSubmit { commitTitleEdit(at: i) }
                                                } else {
                                                    Text(localPlan.goalItems[i].title)
                                                        .font(.system(size: 15, weight: .semibold))
                                                        .foregroundStyle(localPlan.goalItems[i].isDone
                                                            ? AppTheme.textSecondary : AppTheme.textPrimary)
                                                        .strikethrough(localPlan.goalItems[i].isDone, color: AppTheme.textSecondary)
                                                }
                                                // Target months badge
                                                let _months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
                                                if localPlan.goalItems[i].targetMonths.isEmpty {
                                                    Text("Tap 📅 to set months")
                                                        .font(.system(size: 11, weight: .medium))
                                                        .foregroundStyle(AppTheme.textSecondary.opacity(0.5))
                                                } else {
                                                    let labels = localPlan.goalItems[i].targetMonths
                                                        .sorted { $0.year == $1.year ? $0.month < $1.month : $0.year < $1.year }
                                                        .map { "\(_months[$0.month-1]) \($0.year)" }
                                                        .joined(separator: " · ")
                                                    Text("🎯 \(labels)")
                                                        .font(.system(size: 11, weight: .semibold))
                                                        .foregroundStyle(appState.themeColor)
                                                        .lineLimit(2)
                                                }
                                            }

                                            Spacer()

                                            // Confirm title edit button
                                            if editingTitleIdx == i {
                                                Button { commitTitleEdit(at: i) } label: {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .font(.system(size: 18))
                                                        .foregroundStyle(appState.themeColor)
                                                }.buttonStyle(.plain)
                                            }

                                            // Calendar toggle button
                                            Button {
                                                withAnimation(.easeInOut(duration: 0.2)) {
                                                    editingTitleIdx = nil
                                                    if editingMilestoneIdx == i {
                                                        editingMilestoneIdx = nil
                                                    } else {
                                                        editingMilestoneIdx = i
                                                        milestonePickerYear = localPlan.goalItems[i].targetMonths.first?.year ?? localPlan.startYear
                                                    }
                                                }
                                            } label: {
                                                Image(systemName: "calendar.badge.plus")
                                                    .font(.system(size: 15, weight: .semibold))
                                                    .foregroundStyle(editingMilestoneIdx == i
                                                        ? appState.themeColor : appState.themeColor.opacity(0.5))
                                            }.buttonStyle(.plain)

                                            if isTodayTask(localPlan.goalItems[i].title) {
                                                Image(systemName: "sun.max.fill")
                                                    .font(.system(size: 11))
                                                    .foregroundStyle(appState.themeColor.opacity(0.6))
                                            }
                                        }
                                        .padding(.horizontal, 12).padding(.vertical, 13)
                                    }

                                    // Circle month picker
                                    if editingMilestoneIdx == i {
                                        MonthCirclePicker(
                                            selectedMonths: localPlan.goalItems[i].targetMonths,
                                            startYear: localPlan.startYear,
                                            endYear: localPlan.endYear + 1,
                                            themeColor: appState.themeColor,
                                            onToggle: { month, year in
                                                localPlan.goalItems[i].toggleMonth(month, year)
                                                syncToAppState()
                                            },
                                            onClearAll: {
                                                localPlan.goalItems[i].targetMonths.removeAll()
                                                syncToAppState()
                                                editingMilestoneIdx = nil
                                            }
                                        )
                                        .padding(.horizontal, 12)
                                        .padding(.bottom, 12)
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                    }
                                }

                                if i != localPlan.goalItems.count - 1 {
                                    Rectangle().fill(Color(white: 0.0, opacity: 0.10)).frame(height: 0.5)
                                }
                            }

                            // Add goal inline
                            if showAddGoal {
                                HStack {
                                    TextField("Sub-goal title...", text: $newGoalTitle)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(AppTheme.textPrimary)
                                        .submitLabel(.done)
                                        .onSubmit { addGoalItem() }
                                    Button("Add") { addGoalItem() }
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(appState.themeColor)
                                }
                                .padding(.horizontal, 12).padding(.vertical, 10)
                            }

                            Button { showAddGoal = true } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(appState.themeColor)
                                    Text("Add goal")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(appState.themeColor)
                                    Spacer()
                                }
                                .padding(.horizontal, 12).padding(.vertical, 12)
                            }.buttonStyle(.plain)
                        }
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color(white: 1.0, opacity: 0.28)))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(white: 1.0, opacity: 0.55), lineWidth: 1))
                    }

                    // Info hint
                    HStack(spacing: 6) {
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(appState.themeColor.opacity(0.6))
                        Text("Sub-goals are also synced to today's task list")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .padding(.horizontal, 4)
                }
                .padding(.horizontal, 14).padding(.top, 10).padding(.bottom, 24)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showEditSheet) {
            EditPlanSheet(plan: localPlan) { updated in
                localPlan = updated
                syncToAppState()
            }
            .environmentObject(appState)
        }
        .onAppear {
            // Refresh localPlan from appState in case it changed
            if let updated = appState.longTermPlans.first(where: { $0.id == plan.id }) {
                localPlan = updated
            }
        }
    }

    // MARK: - Helpers

    private func commitTitleEdit(at i: Int) {
        let trimmed = editingTitleText.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            localPlan.goalItems[i].title = trimmed
            syncToAppState()
        }
        editingTitleIdx = nil
        editingTitleText = ""
    }

    private func isTodayTask(_ title: String) -> Bool {
        appState.tasks.contains { $0.title.lowercased() == title.lowercased() }
    }

    private func toggleGoalItem(at i: Int) {
        localPlan.goalItems[i].isDone.toggle()
        let title = localPlan.goalItems[i].title
        let isDone = localPlan.goalItems[i].isDone

        // Sync to today's tasks
        if let taskIdx = appState.tasks.firstIndex(where: {
            $0.title.lowercased() == title.lowercased()
        }) {
            // Task exists — sync its isDone
            if appState.tasks[taskIdx].isDone != isDone {
                appState.tasks[taskIdx].isDone = isDone
            }
        } else {
            // Task doesn't exist — add it to today's list
            appState.addTask(title)
            if isDone, let taskIdx = appState.tasks.firstIndex(where: {
                $0.title.lowercased() == title.lowercased()
            }) {
                appState.tasks[taskIdx].isDone = true
            }
        }

        syncToAppState()
    }

    private func addGoalItem() {
        let trimmed = newGoalTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { showAddGoal = false; return }

        // Add to plan's goalItems
        localPlan.goalItems.append(PlanGoalItem(title: trimmed, isDone: false))
        syncToAppState()

        // Also add to today's tasks if not already there
        if !appState.tasks.contains(where: { $0.title.lowercased() == trimmed.lowercased() }) {
            appState.addTask(trimmed)
        }

        newGoalTitle = ""
        showAddGoal = false
    }

    private func syncToAppState() {
        if let idx = appState.longTermPlans.firstIndex(where: { $0.id == localPlan.id }) {
            appState.longTermPlans[idx] = localPlan
        }
    }
}

// MARK: - Study Progress

struct StudyProgressView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    // MARK: Computed data

    private var totalHours: Double { appState.focusSessions.reduce(0) { $0 + $1.duration } / 3600 }
    private var totalSessions: Int { appState.focusSessions.count }
    private var avgSessionMins: Int {
        guard totalSessions > 0 else { return 0 }
        return Int(appState.focusSessions.reduce(0) { $0 + $1.duration } / Double(totalSessions) / 60)
    }
    private var longestSessionMins: Int {
        Int((appState.focusSessions.map { $0.duration }.max() ?? 0) / 60)
    }
    private var taskCompletionRate: Double {
        guard appState.totalTasksCount > 0 else { return 0 }
        return Double(appState.completedTasksCount) / Double(appState.totalTasksCount)
    }

    private var last7Days: [(label: String, minutes: Int, date: Date)] {
        let cal = Calendar.current
        return (0..<7).reversed().map { offset in
            let date = cal.date(byAdding: .day, value: -offset, to: Date())!
            let mins = Int(appState.focusSessions.filter { cal.isDate($0.date, inSameDayAs: date) }
                .reduce(0) { $0 + $1.duration } / 60)
            let fmt = DateFormatter(); fmt.dateFormat = "EEE"
            return (fmt.string(from: date), mins, date)
        }
    }

    private var last4Weeks: [(label: String, hours: Double)] {
        let cal = Calendar.current
        return (0..<4).reversed().map { weekOffset in
            let weekStart = cal.date(byAdding: .weekOfYear, value: -weekOffset, to: cal.startOfDay(for: Date()))!
            let weekEnd = cal.date(byAdding: .day, value: 7, to: weekStart)!
            let hrs = appState.focusSessions.filter { $0.date >= weekStart && $0.date < weekEnd }
                .reduce(0) { $0 + $1.duration } / 3600
            let fmt = DateFormatter(); fmt.dateFormat = "M/d"
            return ("W\(4 - weekOffset)\n\(fmt.string(from: weekStart))", hrs)
        }
    }

    private var hourlyDistribution: [(hour: Int, count: Int)] {
        let cal = Calendar.current
        var counts = [Int: Int]()
        for session in appState.focusSessions {
            let h = cal.component(.hour, from: session.date)
            counts[h, default: 0] += 1
        }
        return stride(from: 6, to: 24, by: 2).map { h in
            (h, counts[h, default: 0] + counts[h + 1, default: 0])
        }
    }

    private var planProgress: [(title: String, done: Int, total: Int)] {
        appState.longTermPlans.filter { $0.totalCount > 0 }.map {
            ($0.title, $0.completedCount, $0.totalCount)
        }
    }

    private var activeDays: Int {
        let cal = Calendar.current
        let uniqueDays = Set(appState.focusSessions.map { cal.startOfDay(for: $0.date) })
        return uniqueDays.count
    }

    private var bestDayMins: Int {
        let cal = Calendar.current
        var byDay = [Date: Int]()
        for s in appState.focusSessions {
            let d = cal.startOfDay(for: s.date)
            byDay[d, default: 0] += Int(s.duration / 60)
        }
        return byDay.values.max() ?? 0
    }

    private var thisWeekHours: Double {
        let cal = Calendar.current
        let weekStart = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        return appState.focusSessions.filter { $0.date >= weekStart }
            .reduce(0) { $0 + $1.duration } / 3600
    }

    var body: some View {
        ZStack {
            appState.bgColor.ignoresSafeArea()
            LinearGradient(colors: [appState.themeColor.opacity(0.18), Color.clear, appState.themeColor.opacity(0.13)],
                           startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {

                    // NAV
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left").font(.system(size: 18, weight: .semibold)).foregroundStyle(appState.themeColor)
                        }
                        Spacer()
                        Text("Study Progress").font(.system(size: 18, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
                        Spacer()
                        Color.clear.frame(width: 24)
                    }.padding(.horizontal, 6)

                    // ── TOP 6 STATS ──
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        StatMiniCard(title: "Total Hours", value: String(format: "%.1f", totalHours), icon: "clock.fill")
                        StatMiniCard(title: "Sessions", value: "\(totalSessions)", icon: "play.fill")
                        StatMiniCard(title: "Streak", value: "\(appState.currentStreak)d", icon: "flame.fill")
                        StatMiniCard(title: "Active Days", value: "\(activeDays)", icon: "calendar.badge.checkmark")
                        StatMiniCard(title: "Avg Session", value: "\(avgSessionMins)m", icon: "timer")
                        StatMiniCard(title: "Best Day", value: "\(bestDayMins)m", icon: "trophy.fill")
                    }

                    // ── TODAY'S PROGRESS ──
                    SoftCardView {
                        let targetMins = appState.dailyTargetHours * 60
                        let doneMins = appState.todayMinutes
                        let pct = targetMins > 0 ? min(Double(doneMins) / Double(targetMins), 1.0) : 0

                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Today's Progress").font(.system(size: 16, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
                                Text("Target: \(targetMins) min").font(.system(size: 12, weight: .medium)).foregroundStyle(AppTheme.textSecondary)
                            }
                            Spacer()
                            Text("\(Int(pct * 100))%")
                                .font(.system(size: 22, weight: .bold)).foregroundStyle(appState.themeColor)
                        }
                        HStack(spacing: 12) {
                            Text("\(doneMins) min").font(.system(size: 18, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8).fill(appState.themeColor.opacity(0.15)).frame(height: 14)
                                    RoundedRectangle(cornerRadius: 8).fill(
                                        LinearGradient(colors: [appState.themeColor.opacity(0.7), appState.themeColor],
                                                       startPoint: .leading, endPoint: .trailing))
                                        .frame(width: geo.size.width * CGFloat(pct), height: 14)
                                        .animation(.spring(), value: pct)
                                }
                            }.frame(height: 14)
                        }

                        // Today's sessions — only show sessions >= 1 min
                        let todaySessions = appState.focusSessions.filter {
                            Calendar.current.isDateInToday($0.date) && $0.duration >= 60
                        }
                        if !todaySessions.isEmpty {
                            Rectangle().fill(Color(white: 0.0, opacity: 0.15)).frame(height: 0.5)
                            Text("Today's Sessions").font(.system(size: 13, weight: .semibold)).foregroundStyle(AppTheme.textSecondary)
                            ForEach(todaySessions.sorted { $0.date > $1.date }) { s in
                                HStack {
                                    Image(systemName: "play.circle.fill").foregroundStyle(appState.themeColor).font(.system(size: 14))
                                    Text(s.date, style: .time).font(.system(size: 13, weight: .medium)).foregroundStyle(AppTheme.textPrimary)
                                    Spacer()
                                    let mins = Int(s.duration / 60)
                                    let secs = Int(s.duration) % 60
                                    Text(mins > 0 ? "\(mins) min" : "\(secs)s")
                                        .font(.system(size: 13, weight: .semibold)).foregroundStyle(appState.themeColor)
                                }
                            }
                        }
                    }

                    // ── THIS WEEK ──
                    SoftCardView {
                        HStack {
                            Text("This Week").font(.system(size: 16, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
                            Spacer()
                            Text(String(format: "%.1f h", thisWeekHours)).font(.system(size: 15, weight: .bold)).foregroundStyle(appState.themeColor)
                        }
                        let maxMin = max(last7Days.map { $0.minutes }.max() ?? 1, 1)
                        HStack(alignment: .bottom, spacing: 6) {
                            ForEach(last7Days, id: \.label) { day in
                                VStack(spacing: 4) {
                                    if day.minutes > 0 {
                                        Text("\(day.minutes)m").font(.system(size: 9, weight: .bold)).foregroundStyle(appState.themeColor)
                                    }
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Calendar.current.isDateInToday(day.date)
                                              ? appState.themeColor
                                              : day.minutes > 0 ? appState.themeColor.opacity(0.55) : appState.themeColor.opacity(0.12))
                                        .frame(height: max(CGFloat(day.minutes) / CGFloat(maxMin) * 110, 6))
                                        .overlay(
                                            Calendar.current.isDateInToday(day.date) ?
                                            RoundedRectangle(cornerRadius: 6).stroke(Color(white: 1.0, opacity: 0.4), lineWidth: 1.5) : nil
                                        )
                                    Text(day.label).font(.system(size: 10, weight: .semibold)).foregroundStyle(AppTheme.textSecondary)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .frame(height: 155)
                        .padding(.top, 4)

                        // Daily target line hint
                        let targetMins = appState.dailyTargetHours * 60
                        HStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 1).fill(appState.themeColor.opacity(0.5)).frame(width: 16, height: 2)
                            Text("Daily target: \(targetMins) min").font(.system(size: 11, weight: .medium)).foregroundStyle(AppTheme.textSecondary)
                        }
                    }

                    // ── 4-WEEK TREND ──
                    SoftCardView {
                        Text("4-Week Trend").font(.system(size: 16, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
                        let maxHrs = max(last4Weeks.map { $0.hours }.max() ?? 1, 1)
                        HStack(alignment: .bottom, spacing: 12) {
                            ForEach(last4Weeks, id: \.label) { week in
                                VStack(spacing: 6) {
                                    Text(String(format: "%.1fh", week.hours))
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(week.hours > 0 ? appState.themeColor : Color.clear)
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(week.hours > 0
                                              ? LinearGradient(colors: [appState.themeColor.opacity(0.6), appState.themeColor],
                                                               startPoint: .bottom, endPoint: .top)
                                              : LinearGradient(colors: [appState.themeColor.opacity(0.1), appState.themeColor.opacity(0.1)],
                                                               startPoint: .bottom, endPoint: .top))
                                        .frame(height: max(CGFloat(week.hours) / CGFloat(maxHrs) * 100, 8))
                                    Text(week.label)
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundStyle(AppTheme.textSecondary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .frame(height: 145)
                        .padding(.top, 4)

                        // Week total comparison
                        let hrs = last4Weeks.map { $0.hours }
                        if hrs.count >= 2 && hrs[hrs.count-2] > 0 {
                            let diff = hrs.last! - hrs[hrs.count-2]
                            let sign = diff >= 0 ? "+" : ""
                            HStack(spacing: 4) {
                                Image(systemName: diff >= 0 ? "arrow.up.right" : "arrow.down.right")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(diff >= 0 ? Color.green : Color.red)
                                Text("\(sign)\(String(format: "%.1f", diff))h vs last week")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                        }
                    }

                    // ── STUDY TIME OF DAY ──
                    SoftCardView {
                        Text("Study Time of Day").font(.system(size: 16, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
                        Text("When you focus most").font(.system(size: 12, weight: .medium)).foregroundStyle(AppTheme.textSecondary)
                        let maxCount = max(hourlyDistribution.map { $0.count }.max() ?? 1, 1)
                        HStack(alignment: .bottom, spacing: 4) {
                            ForEach(hourlyDistribution, id: \.hour) { slot in
                                VStack(spacing: 3) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(slot.count > 0 ? appState.themeColor.opacity(0.4 + 0.6 * Double(slot.count) / Double(maxCount)) : appState.themeColor.opacity(0.08))
                                        .frame(height: max(CGFloat(slot.count) / CGFloat(maxCount) * 70, 5))
                                    Text(slot.hour < 12 ? "\(slot.hour)a" : slot.hour == 12 ? "12p" : "\(slot.hour-12)p")
                                        .font(.system(size: 8, weight: .semibold))
                                        .foregroundStyle(AppTheme.textSecondary)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .frame(height: 90)
                        .padding(.top, 4)

                        // Peak time label
                        if let peak = hourlyDistribution.max(by: { $0.count < $1.count }), peak.count > 0 {
                            let h = peak.hour
                            let label = h < 12 ? "\(h):00 AM" : h == 12 ? "12:00 PM" : "\(h-12):00 PM"
                            HStack(spacing: 6) {
                                Image(systemName: "star.fill").font(.system(size: 11)).foregroundStyle(appState.themeColor)
                                Text("Peak time: \(label)").font(.system(size: 12, weight: .semibold)).foregroundStyle(AppTheme.textSecondary)
                            }
                        }
                    }

                    // ── TASK COMPLETION ──
                    SoftCardView {
                        HStack {
                            Text("Task Completion").font(.system(size: 16, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
                            Spacer()
                            Text("\(appState.completedTasksCount)/\(appState.totalTasksCount)")
                                .font(.system(size: 14, weight: .semibold)).foregroundStyle(appState.themeColor)
                        }

                        // Donut ring
                        ZStack {
                            Circle().stroke(appState.themeColor.opacity(0.12), lineWidth: 18).frame(width: 110, height: 110)
                            Circle()
                                .trim(from: 0, to: CGFloat(taskCompletionRate))
                                .stroke(appState.themeColor, style: StrokeStyle(lineWidth: 18, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                                .frame(width: 110, height: 110)
                                .animation(.spring(), value: taskCompletionRate)
                            VStack(spacing: 2) {
                                Text("\(Int(taskCompletionRate * 100))%")
                                    .font(.system(size: 22, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
                                Text("done").font(.system(size: 12, weight: .medium)).foregroundStyle(AppTheme.textSecondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)

                        // Row breakdown
                        HStack(spacing: 0) {
                            VStack(spacing: 4) {
                                Text("\(appState.completedTasksCount)").font(.system(size: 18, weight: .bold)).foregroundStyle(appState.themeColor)
                                Text("Completed").font(.system(size: 11, weight: .semibold)).foregroundStyle(AppTheme.textSecondary)
                            }.frame(maxWidth: .infinity)
                            Divider().frame(height: 36)
                            VStack(spacing: 4) {
                                Text("\(appState.totalTasksCount - appState.completedTasksCount)").font(.system(size: 18, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
                                Text("Remaining").font(.system(size: 11, weight: .semibold)).foregroundStyle(AppTheme.textSecondary)
                            }.frame(maxWidth: .infinity)
                            Divider().frame(height: 36)
                            VStack(spacing: 4) {
                                Text("\(appState.totalTasksCount)").font(.system(size: 18, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
                                Text("Total").font(.system(size: 11, weight: .semibold)).foregroundStyle(AppTheme.textSecondary)
                            }.frame(maxWidth: .infinity)
                        }
                    }

                    // ── LONG-TERM PLAN PROGRESS ──
                    if !planProgress.isEmpty {
                        SoftCardView {
                            Text("Long-Term Plan Progress").font(.system(size: 16, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
                            VStack(spacing: 12) {
                                ForEach(planProgress, id: \.title) { plan in
                                    let pct = plan.total > 0 ? Double(plan.done) / Double(plan.total) : 0
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack {
                                            Text(plan.title).font(.system(size: 14, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                                                .lineLimit(1)
                                            Spacer()
                                            Text("\(plan.done)/\(plan.total)").font(.system(size: 12, weight: .bold)).foregroundStyle(appState.themeColor)
                                        }
                                        GeometryReader { geo in
                                            ZStack(alignment: .leading) {
                                                RoundedRectangle(cornerRadius: 6).fill(appState.themeColor.opacity(0.12)).frame(height: 10)
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(LinearGradient(colors: [appState.themeColor.opacity(0.7), appState.themeColor],
                                                                         startPoint: .leading, endPoint: .trailing))
                                                    .frame(width: geo.size.width * CGFloat(pct), height: 10)
                                            }
                                        }.frame(height: 10)
                                        Text("\(Int(pct * 100))% complete").font(.system(size: 11, weight: .medium)).foregroundStyle(AppTheme.textSecondary)
                                    }
                                }
                            }
                        }
                    }

                    // ── LONGEST SESSION ──
                    SoftCardView {
                        Text("Session Records").font(.system(size: 16, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
                        HStack(spacing: 0) {
                            VStack(spacing: 4) {
                                Text("\(longestSessionMins)m").font(.system(size: 20, weight: .bold)).foregroundStyle(appState.themeColor)
                                Text("Longest").font(.system(size: 11, weight: .semibold)).foregroundStyle(AppTheme.textSecondary)
                            }.frame(maxWidth: .infinity)
                            Divider().frame(height: 40)
                            VStack(spacing: 4) {
                                Text("\(avgSessionMins)m").font(.system(size: 20, weight: .bold)).foregroundStyle(appState.themeColor)
                                Text("Average").font(.system(size: 11, weight: .semibold)).foregroundStyle(AppTheme.textSecondary)
                            }.frame(maxWidth: .infinity)
                            Divider().frame(height: 40)
                            VStack(spacing: 4) {
                                Text(String(format: "%.0fh", totalHours)).font(.system(size: 20, weight: .bold)).foregroundStyle(appState.themeColor)
                                Text("Total").font(.system(size: 11, weight: .semibold)).foregroundStyle(AppTheme.textSecondary)
                            }.frame(maxWidth: .infinity)
                        }
                        .padding(.vertical, 4)
                    }

                }
                .padding(.horizontal, 14).padding(.top, 10).padding(.bottom, 32)
            }
        }
        .navigationBarHidden(true)
    }
}

private struct StatMiniCard: View {
    @EnvironmentObject var appState: AppState
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(appState.themeColor)
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(white: 1.0, opacity: 0.7)))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(appState.themeColor.opacity(0.10), lineWidth: 1))
    }
}

// MARK: - Shared Soft Card

struct SoftCardView<Content: View>: View {
    @EnvironmentObject var appState: AppState
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) { content }
            .padding(14)
            .background(Color(white: 1.0, opacity: 0.45))
            .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(appState.themeColor.opacity(0.08)))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color(white: 1.0, opacity: 0.65), lineWidth: 1))
    }
}

// MARK: - Edit Plan Sheet

struct EditPlanSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    let plan: LongTermPlan
    let onSave: (LongTermPlan) -> Void

    @State private var title: String
    @State private var description: String
    @State private var startMonthIdx: Int
    @State private var startYear: Int
    @State private var endMonthIdx: Int
    @State private var endYear: Int

    private let months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
    private let currentYear = Calendar.current.component(.year, from: Date())
    private var years: [Int] { Array((currentYear - 3)...(currentYear + 5)) }

    private var dateRangeString: String {
        let sm = months[startMonthIdx]; let em = months[endMonthIdx]
        if startYear == endYear { return "\(sm) - \(em) \(startYear)" }
        return "\(sm) \(startYear) - \(em) \(endYear)"
    }

    private var isDateValid: Bool {
        (startYear * 12 + startMonthIdx) <= (endYear * 12 + endMonthIdx)
    }

    init(plan: LongTermPlan, onSave: @escaping (LongTermPlan) -> Void) {

        self.plan = plan
        self.onSave = onSave
        _title = State(initialValue: plan.title)
        _description = State(initialValue: plan.description)

        // Parse existing dateRange to pre-fill pickers
        // Format: "Jan - Jun 2025" or "Jan 2025 - Jun 2026"
        let months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
        let currentYear = Calendar.current.component(.year, from: Date())
        var smi = 0, sy = currentYear, emi = 5, ey = currentYear

        let parts = plan.dateRange.components(separatedBy: " - ")
        if parts.count == 2 {
            let startParts = parts[0].components(separatedBy: " ")
            let endParts = parts[1].components(separatedBy: " ")
            if let sm = months.firstIndex(of: startParts[0]) { smi = sm }
            if startParts.count > 1, let y = Int(startParts[1]) { sy = y }
            if let em = months.firstIndex(of: endParts[0]) { emi = em }
            if endParts.count > 1, let y = Int(endParts[1]) { ey = y }
            else if startParts.count == 1, endParts.count > 1, let y = Int(endParts[1]) {
                sy = y; ey = y
            }
        }
        _startMonthIdx = State(initialValue: smi)
        _startYear = State(initialValue: sy)
        _endMonthIdx = State(initialValue: emi)
        _endYear = State(initialValue: ey)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                appState.bgColor.ignoresSafeArea()
                appState.themeColor.opacity(0.08).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        // Title
                        fieldSection(label: "Plan Title") {
                            TextField("Plan title", text: $title)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(12)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color(white: 1.0, opacity: 0.7)))
                        }

                        // Description
                        fieldSection(label: "Description (optional)") {
                            TextField("What is this plan about?", text: $description, axis: .vertical)
                                .lineLimit(3...5)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(12)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color(white: 1.0, opacity: 0.7)))
                        }

                        // Date range
                        fieldSection(label: "Time Span") {
                            VStack(spacing: 0) {
                                HStack(spacing: 0) {
                                    Text("From")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(AppTheme.textSecondary)
                                        .frame(width: 44, alignment: .leading)
                                    monthYearPicker(monthIdx: $startMonthIdx, year: $startYear)
                                }
                                Divider().padding(.vertical, 4)
                                HStack(spacing: 0) {
                                    Text("To")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(AppTheme.textSecondary)
                                        .frame(width: 44, alignment: .leading)
                                    monthYearPicker(monthIdx: $endMonthIdx, year: $endYear)
                                }
                            }
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(white: 1.0, opacity: 0.7)))

                            if isDateValid {
                                Text(dateRangeString)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(appState.themeColor)
                                    .padding(.top, 2)
                            } else {
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 12))
                                    Text("\"From\" must be before \"To\"")
                                        .font(.system(size: 12, weight: .semibold))
                                }
                                .foregroundStyle(Color.red.opacity(0.8))
                                .padding(.top, 2)
                            }
                        }

                        // Save button
                        let canSave = !title.trimmingCharacters(in: .whitespaces).isEmpty && isDateValid
                        Button {
                            var updated = plan
                            updated.title = title.trimmingCharacters(in: .whitespaces)
                            updated.description = description
                            updated.dateRange = dateRangeString
                            onSave(updated)
                            dismiss()
                        } label: {
                            Text("Save Changes")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Capsule().fill(canSave ? appState.themeColor : Color(white: 0.5, opacity: 0.4)))
                        }
                        .buttonStyle(.plain)
                        .disabled(!canSave)
                    }
                    .padding(20)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Edit Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
    }

    @ViewBuilder
    private func fieldSection<C: View>(label: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppTheme.textSecondary)
                .textCase(.uppercase)
            content()
        }
    }

    @ViewBuilder
    private func monthYearPicker(monthIdx: Binding<Int>, year: Binding<Int>) -> some View {
        HStack(spacing: 0) {
            Picker("", selection: monthIdx) {
                ForEach(months.indices, id: \.self) { i in
                    Text(months[i]).tag(i)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80, height: 100)
            .clipped()
            .colorScheme(.light)

            Picker("", selection: year) {
                ForEach(years, id: \.self) { y in
                    Text(String(y)).tag(y)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 90, height: 100)
            .clipped()
            .colorScheme(.light)
        }
    }
}

// MARK: - Add Plan Sheet (used by both TasksView and LongTermPlansView)

struct AddPlanSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    // Title & description
    @State private var title = ""
    @State private var description = ""

    // Date range pickers
    private let months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
    private let currentYear = Calendar.current.component(.year, from: Date())
    @State private var startMonthIdx = 0
    @State private var startYear = Calendar.current.component(.year, from: Date())
    @State private var endMonthIdx = 5
    @State private var endYear = Calendar.current.component(.year, from: Date())

    // Sub-goals
    @State private var subGoals: [String] = [""]
    @FocusState private var focusedSubGoal: Int?

    private var years: [Int] { Array((currentYear - 1)...(currentYear + 5)) }

    private var dateRangeString: String {
        let sm = months[startMonthIdx]; let em = months[endMonthIdx]
        if startYear == endYear { return "\(sm) - \(em) \(startYear)" }
        return "\(sm) \(startYear) - \(em) \(endYear)"
    }

    private var isDateValid: Bool {
        (startYear * 12 + startMonthIdx) <= (endYear * 12 + endMonthIdx)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                appState.bgColor.ignoresSafeArea()
                appState.themeColor.opacity(0.08).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        // Title
                        fieldSection(label: "Plan Title") {
                            TextField("e.g. Cooper Summer STEM", text: $title)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(12)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color(white: 1.0, opacity: 0.7)))
                        }

                        // Description
                        fieldSection(label: "Description (optional)") {
                            TextField("What is this plan about?", text: $description, axis: .vertical)
                                .lineLimit(3...5)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(12)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color(white: 1.0, opacity: 0.7)))
                        }

                        // Date range
                        fieldSection(label: "Time Span") {
                            VStack(spacing: 0) {
                                HStack(spacing: 0) {
                                    Text("From").font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(AppTheme.textSecondary)
                                        .frame(width: 44, alignment: .leading)
                                    monthYearPicker(monthIdx: $startMonthIdx, year: $startYear)
                                }
                                .onChange(of: startMonthIdx) {
                                    if startYear * 12 + startMonthIdx > endYear * 12 + endMonthIdx {
                                        endMonthIdx = startMonthIdx
                                        endYear = startYear
                                    }
                                }
                                .onChange(of: startYear) {
                                    if startYear * 12 + startMonthIdx > endYear * 12 + endMonthIdx {
                                        endMonthIdx = startMonthIdx
                                        endYear = startYear
                                    }
                                }
                                Divider().padding(.vertical, 4)
                                HStack(spacing: 0) {
                                    Text("To").font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(AppTheme.textSecondary)
                                        .frame(width: 44, alignment: .leading)
                                    monthYearPicker(monthIdx: $endMonthIdx, year: $endYear)
                                }
                                .onChange(of: endMonthIdx) {
                                    if endYear * 12 + endMonthIdx < startYear * 12 + startMonthIdx {
                                        endMonthIdx = startMonthIdx
                                        endYear = startYear
                                    }
                                }
                                .onChange(of: endYear) {
                                    if endYear * 12 + endMonthIdx < startYear * 12 + startMonthIdx {
                                        endMonthIdx = startMonthIdx
                                        endYear = startYear
                                    }
                                }
                            }
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(white: 1.0, opacity: 0.7)))

                            // Preview
                            if isDateValid {
                                Text(dateRangeString)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(appState.themeColor)
                                    .padding(.top, 2)
                            } else {
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 12))
                                    Text("\"From\" must be before \"To\"")
                                        .font(.system(size: 12, weight: .semibold))
                                }
                                .foregroundStyle(Color.red.opacity(0.8))
                                .padding(.top, 2)
                            }
                        }

                        // Sub-goals
                        fieldSection(label: "Initial Sub-Goals") {
                            VStack(spacing: 8) {
                                ForEach(subGoals.indices, id: \.self) { i in
                                    HStack(spacing: 8) {
                                        Image(systemName: "circle")
                                            .font(.system(size: 11))
                                            .foregroundStyle(appState.themeColor.opacity(0.6))
                                        TextField("Sub-goal \(i + 1)", text: $subGoals[i])
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(AppTheme.textPrimary)
                                            .focused($focusedSubGoal, equals: i)
                                            .submitLabel(i == subGoals.count - 1 ? .done : .next)
                                            .onSubmit {
                                                if i == subGoals.count - 1 {
                                                    subGoals.append("")
                                                    focusedSubGoal = i + 1
                                                } else {
                                                    focusedSubGoal = i + 1
                                                }
                                            }
                                        if subGoals.count > 1 {
                                            Button {
                                                subGoals.remove(at: i)
                                            } label: {
                                                Image(systemName: "minus.circle.fill")
                                                    .foregroundStyle(Color.red.opacity(0.6))
                                                    .font(.system(size: 16))
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(10)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(white: 1.0, opacity: 0.7)))
                                }

                                Button {
                                    subGoals.append("")
                                    focusedSubGoal = subGoals.count - 1
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "plus").font(.system(size: 12, weight: .bold))
                                        Text("Add sub-goal").font(.system(size: 13, weight: .semibold))
                                    }
                                    .foregroundStyle(appState.themeColor)
                                    .padding(.vertical, 6)
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        // Save button
                        let canSave = !title.trimmingCharacters(in: .whitespaces).isEmpty && isDateValid
                        Button {
                            savePlan()
                        } label: {
                            Text("Save Plan")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Capsule().fill(canSave ? appState.themeColor : Color.gray.opacity(0.4)))
                        }
                        .buttonStyle(.plain)
                        .disabled(!canSave)
                    }
                    .padding(20)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("New Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
    }

    @ViewBuilder
    private func fieldSection<C: View>(label: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppTheme.textSecondary)
                .textCase(.uppercase)
            content()
        }
    }

    @ViewBuilder
    private func monthYearPicker(monthIdx: Binding<Int>, year: Binding<Int>) -> some View {
        HStack(spacing: 0) {
            Picker("", selection: monthIdx) {
                ForEach(months.indices, id: \.self) { i in
                    Text(months[i]).tag(i)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80, height: 100)
            .clipped()
            .colorScheme(.light)

            Picker("", selection: year) {
                ForEach(years, id: \.self) { y in
                    Text(String(y)).tag(y)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 90, height: 100)
            .clipped()
            .colorScheme(.light)
        }
    }

    private func savePlan() {
        let cleanedGoals = subGoals
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .map { PlanGoalItem(title: $0, isDone: false) }

        let plan = LongTermPlan(
            title: title.trimmingCharacters(in: .whitespaces),
            dateRange: dateRangeString,
            description: description,
            goalItems: cleanedGoals,
            startMonth: startMonthIdx + 1,
            startYear: startYear,
            endMonth: endMonthIdx + 1,
            endYear: endYear
        )
        appState.addPlan(plan)
        dismiss()
    }
}

// MARK: - Swipe Action Row (Edit / Delete)

struct SwipeActionRow<Content: View>: View {
    let onEdit: () -> Void
    let onDelete: () -> Void
    @ViewBuilder let content: () -> Content

    @State private var offset: CGFloat = 0
    private let actionWidth: CGFloat = 120

    var body: some View {
        ZStack(alignment: .trailing) {
            // Action buttons
            HStack(spacing: 8) {
                Button(action: {
                    withAnimation(.spring(response: 0.3)) { offset = 0 }
                    onEdit()
                }) {
                    VStack(spacing: 3) {
                        Image(systemName: "pencil")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Edit")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(width: 52, height: 44)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.blue.opacity(0.8)))
                }
                .buttonStyle(.plain)

                Button(action: {
                    withAnimation(.spring(response: 0.3)) { offset = 0 }
                    onDelete()
                }) {
                    VStack(spacing: 3) {
                        Image(systemName: "trash")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Delete")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(width: 52, height: 44)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.red.opacity(0.8)))
                }
                .buttonStyle(.plain)
            }
            .padding(.trailing, 4)
            .opacity(offset < -20 ? 1 : 0)

            // Main content
            content()
                .offset(x: offset)
                .gesture(
                    DragGesture(minimumDistance: 10, coordinateSpace: .local)
                        .onChanged { v in
                            let dx = v.translation.width
                            if dx < 0 { offset = max(-actionWidth, dx) }
                            else if offset < 0 { offset = min(0, -actionWidth + dx) }
                        }
                        .onEnded { v in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                offset = v.translation.width < -40 ? -actionWidth : 0
                            }
                        }
                )
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if offset != 0 { withAnimation(.spring(response: 0.3)) { offset = 0 } }
        }
    }
}

// MARK: - Month Circle Picker (multi-select)

struct MonthCirclePicker: View {
    let selectedMonths: [(month: Int, year: Int)]
    let startYear: Int
    let endYear: Int
    let themeColor: Color
    let onToggle: (Int, Int) -> Void
    let onClearAll: () -> Void

    @State private var displayYear: Int
    private let monthLabels = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]

    init(selectedMonths: [(month: Int, year: Int)], startYear: Int, endYear: Int,
         themeColor: Color, onToggle: @escaping (Int, Int) -> Void, onClearAll: @escaping () -> Void) {
        self.selectedMonths = selectedMonths
        self.startYear = startYear; self.endYear = endYear
        self.themeColor = themeColor
        self.onToggle = onToggle; self.onClearAll = onClearAll
        _displayYear = State(initialValue: selectedMonths.first?.year ?? startYear)
    }

    var body: some View {
        VStack(spacing: 10) {
            // Year navigation row
            HStack {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if displayYear > startYear { displayYear -= 1 }
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(displayYear > startYear ? themeColor : Color.gray.opacity(0.3))
                }.buttonStyle(.plain)

                Spacer()
                Text(String(displayYear))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if displayYear < endYear { displayYear += 1 }
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(displayYear < endYear ? themeColor : Color.gray.opacity(0.3))
                }.buttonStyle(.plain)
            }

            // 12 month pills — 2 rows of 6
            VStack(spacing: 8) {
                ForEach([0, 6], id: \.self) { rowStart in
                    HStack(spacing: 6) {
                        ForEach(rowStart..<rowStart+6, id: \.self) { m in
                            let monthNum = m + 1
                            let isOn = selectedMonths.contains { $0.month == monthNum && $0.year == displayYear }
                            Button { onToggle(monthNum, displayYear) } label: {
                                Text(monthLabels[m])
                                    .font(.system(size: 12, weight: isOn ? .bold : .medium))
                                    .foregroundColor(isOn ? .white : themeColor.opacity(0.8))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 7)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(isOn ? themeColor : themeColor.opacity(0.10))
                                    )
                            }
                            .buttonStyle(.plain)
                            .animation(.easeInOut(duration: 0.12), value: isOn)
                        }
                    }
                }
            }

            // Clear all if any selected in this year
            let hasAnyThisYear = selectedMonths.contains { $0.year == displayYear }
            if hasAnyThisYear {
                Button("Clear all") { onClearAll() }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.red.opacity(0.6))
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(themeColor.opacity(0.06)))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(themeColor.opacity(0.15), lineWidth: 1))
    }
}



// MARK: - Feedback View

struct FeedbackView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var feedbackText = ""
    @State private var selectedType = "Bug Report"
    @State private var showSentAlert = false
    @FocusState private var textFocused: Bool

    let feedbackTypes = ["Bug Report", "Feature Request", "General Feedback"]
    let contactEmail = "uxuan33@gmail.com"

    var body: some View {
        ZStack {
            appState.bgColor.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    ZStack {
                        Circle()
                            .fill(appState.themeColor.opacity(0.12))
                            .frame(width: 72, height: 72)
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundStyle(appState.themeColor)
                    }
                    .padding(.top, 16)

                    VStack(spacing: 6) {
                        Text("Send Feedback")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(AppTheme.textPrimary)
                        Text("We'd love to hear from you.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                    }

                    // Type picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("TYPE")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(AppTheme.textSecondary)
                            .padding(.horizontal, 4)

                        HStack(spacing: 8) {
                            ForEach(feedbackTypes, id: \.self) { type in
                                Button {
                                    selectedType = type
                                } label: {
                                    Text(type)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(selectedType == type ? .white : appState.themeColor)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 7)
                                        .background(
                                            Capsule()
                                                .fill(selectedType == type ? appState.themeColor : appState.themeColor.opacity(0.1))
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)

                    // Text input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("MESSAGE")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(AppTheme.textSecondary)
                            .padding(.horizontal, 4)

                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(appState.themeColor.opacity(0.06))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(appState.themeColor.opacity(0.15), lineWidth: 1)
                                )
                                .frame(minHeight: 140)

                            if feedbackText.isEmpty {
                                Text("Describe your feedback here...")
                                    .font(.system(size: 15))
                                    .foregroundStyle(AppTheme.textSecondary.opacity(0.5))
                                    .padding(14)
                            }

                            TextEditor(text: $feedbackText)
                                .font(.system(size: 15))
                                .foregroundStyle(AppTheme.textPrimary)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .frame(minHeight: 140)
                                .padding(10)
                                .focused($textFocused)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)

                    // Send button
                    Button {
                        sendFeedback()
                    } label: {
                        Text("Send Feedback")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                Capsule()
                                    .fill(feedbackText.trimmingCharacters(in: .whitespaces).isEmpty
                                          ? appState.themeColor.opacity(0.4)
                                          : appState.themeColor)
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(feedbackText.trimmingCharacters(in: .whitespaces).isEmpty)

                    // Email contact
                    VStack(spacing: 4) {
                        Text("Or email us directly at")
                            .font(.system(size: 13))
                            .foregroundStyle(AppTheme.textSecondary)
                        Text(contactEmail)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(appState.themeColor)
                            .onTapGesture {
                                UIPasteboard.general.string = contactEmail
                            }
                        Text("(tap to copy)")
                            .font(.system(size: 11))
                            .foregroundStyle(AppTheme.textSecondary.opacity(0.6))
                    }
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 20)
            }
            .onTapGesture { textFocused = false }
        }
        .navigationTitle("Send Feedback")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Feedback Sent!", isPresented: $showSentAlert) {
            Button("OK") { dismiss() }
        } message: {
            Text("Thanks for your feedback! We'll get back to you at \(contactEmail).")
        }
    }

    private func sendFeedback() {
        let subject = "\(selectedType) — Barely Working App"
        let body = feedbackText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "mailto:\(contactEmail)?subject=\(subjectEncoded)&body=\(body)"
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
        showSentAlert = true
    }
}
