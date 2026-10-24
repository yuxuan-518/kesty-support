//
//
//import SwiftUI
//
//// MARK: - Root Tab View
//
//enum AppTab: Hashable {
//    case tasks, focus, settings
//}
//
//struct TasksView: View {
//    @EnvironmentObject var appState: AppState
//    @State private var selectedTab: AppTab = .tasks
//
//    var body: some View {
//        TabView(selection: $selectedTab) {
//            TasksScreen(selectedTab: $selectedTab)
//                .tabItem { Label("Tasks", systemImage: "list.bullet") }
//                .tag(AppTab.tasks)
//            StartFocusScreen(selectedTab: $selectedTab)
//                .tabItem { Label("Start Focus", systemImage: "play.fill") }
//                .tag(AppTab.focus)
//            SettingsScreen()
//                .tabItem { Label("Settings", systemImage: "gearshape") }
//                .tag(AppTab.settings)
//        }
//        .tint(appState.themeColor)
//    }
//}
//
//// MARK: - Tasks Screen
//
//struct TasksScreen: View {
//    @EnvironmentObject var appState: AppState
//    @Binding var selectedTab: AppTab
//
//    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
//    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
//    @State private var showAddTask = false
//    @State private var newTaskTitle = ""
//
//    private let months = ["Jan","Feb","Mar","Apr","May","Jun",
//                          "Jul","Aug","Sep","Oct","Nov","Dec"]
//    private let years = Array(2024...2029)
//
//    var calendarCells: [(day: Int, hours: Double, highlighted: Bool)] {
//        (1...daysInMonth).map { day in
//            let h = appState.hoursForDay(day, month: selectedMonth, year: selectedYear)
//            return (day, h, h > 0)
//        }
//    }
//
//    var daysInMonth: Int {
//        var comps = DateComponents()
//        comps.year = selectedYear
//        comps.month = selectedMonth
//        return Calendar.current.range(of: .day, in: .month,
//            for: Calendar.current.date(from: comps)!)?.count ?? 30
//    }
//
//    var progressValue: Double {
//        let target = Double(appState.dailyTargetHours * 60)
//        guard target > 0 else { return 0 }
//        return min(Double(appState.todayMinutes) / target, 1.0)
//    }
//
//    var body: some View {
//        ZStack {
//            appState.bgColor.ignoresSafeArea()
//            VStack(spacing: 0) {
//                ProfileHeader()
//                Divider()
//                ScrollView(showsIndicators: false) {
//                    VStack(spacing: 16) {
//                        TasksListCard(showAddTask: $showAddTask, newTaskTitle: $newTaskTitle, selectedTab: $selectedTab)
//                        monthYearPickers
//                        GoalsSection(selectedMonth: selectedMonth, selectedYear: selectedYear)
//                        StatsSection(
//                            minutes: appState.todayMinutes,
//                            progress: progressValue,
//                            calendarCells: calendarCells
//                        )
//                    }
//                    .padding(.horizontal, 18)
//                    .padding(.top, 16)
//                    .padding(.bottom, 120)
//                }
//            }
//            if showAddTask {
//                AddTaskOverlay(show: $showAddTask) { title, mode, targetSecs in
//                    appState.addTask(title, timerMode: mode, targetSeconds: targetSecs)
//                    showAddTask = false
//                }
//            }
//        }
//        .onAppear { appState.checkDailyReset() }
//    }
//
//    private var monthYearPickers: some View {
//        HStack(spacing: 12) {
//            Picker("", selection: $selectedMonth) {
//                ForEach(1...12, id: \.self) { m in Text(months[m-1]).tag(m) }
//            }
//            .pickerStyle(.menu)
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .padding(.horizontal, 12).padding(.vertical, 10)
//            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
//            .overlay(RoundedRectangle(cornerRadius: 12).stroke(appState.themeColor.opacity(0.12), lineWidth: 1))
//            .tint(appState.themeColor)
//
//            Picker("", selection: $selectedYear) {
//                ForEach(years, id: \.self) { y in Text(String(y)).tag(y) }
//            }
//            .pickerStyle(.menu)
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .padding(.horizontal, 12).padding(.vertical, 10)
//            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
//            .overlay(RoundedRectangle(cornerRadius: 12).stroke(appState.themeColor.opacity(0.12), lineWidth: 1))
//            .tint(appState.themeColor)
//        }
//    }
//}
//
//// MARK: - Profile Header
//
//struct ProfileHeader: View {
//    @EnvironmentObject var appState: AppState
//
//    var body: some View {
//        HStack(spacing: 14) {
//            Circle()
//                .fill(appState.themeColor.opacity(0.2))
//                .frame(width: 50, height: 50)
//                .overlay {
//                    if let data = appState.currentUser.avatarData,
//                       let img = UIImage(data: data) {
//                        Image(uiImage: img)
//                            .resizable().scaledToFill()
//                            .frame(width: 50, height: 50)
//                            .clipShape(Circle())
//                    } else {
//                        Image(systemName: "person.fill")
//                            .foregroundColor(appState.themeColor)
//                    }
//                }
//            VStack(alignment: .leading, spacing: 4) {
//                Text("Name: \(appState.currentUser.name)")
//                Text("Today: \(String(format: "%.1f", appState.todayHours))h")
//                Text("Total tasks: \(appState.totalTasksCount)")
//                Text("Completed: \(appState.completedTasksCount)")
//            }
//            .font(.system(size: 15, weight: .semibold))
//            .foregroundStyle(AppTheme.textPrimary)
//            Spacer()
//        }
//        .padding(18)
//    }
//}
//
//// MARK: - Tasks List Card
//
//struct TasksListCard: View {
//    @EnvironmentObject var appState: AppState
//    @Binding var showAddTask: Bool
//    @Binding var newTaskTitle: String
//    @Binding var selectedTab: AppTab
//
//    @State private var editingTaskId: UUID? = nil
//    @State private var editingText: String = ""
//    @FocusState private var editFieldFocused: Bool
//
//    private let cardStroke = Color(white: 0.0, opacity: 0.06)
//    private let cardFill = Color(white: 1.0, opacity: 0.7)
//    private let dividerOpacity: Double = 0.08
//
//    var body: some View {
//        VStack(spacing: 0) {
//            taskRows
//            addButton
//        }
//        .background(RoundedRectangle(cornerRadius: 16).fill(cardFill))
//        .overlay(RoundedRectangle(cornerRadius: 16).stroke(cardStroke, lineWidth: 1))
//        .onTapGesture { if editingTaskId != nil { commitEdit() } }
//    }
//
//    private var taskRows: some View {
//        ForEach(Array(appState.tasks.enumerated()), id: \.element.id) { i, task in
//            VStack(spacing: 0) {
//                SwipeToDeleteRow {
//                    singleTaskRow(i: i, task: task)
//                } onDelete: {
//                    deleteTask(at: i)
//                }
//                if i < appState.tasks.count - 1 {
//                    Rectangle()
//                        .fill(Color(white: 0.0, opacity: dividerOpacity))
//                        .frame(height: 0.5)
//                        .padding(.horizontal, 12)
//                }
//            }
//        }
//    }
//
//    private var addButton: some View {
//        VStack(spacing: 0) {
//            Rectangle()
//                .fill(Color(white: 0.0, opacity: dividerOpacity))
//                .frame(height: 0.5)
//                .padding(.horizontal, 12)
//            Button { showAddTask = true } label: {
//                HStack(spacing: 6) {
//                    Image(systemName: "plus.circle.fill").font(.system(size: 16, weight: .semibold))
//                    Text("Add Task").font(.system(size: 14, weight: .semibold))
//                }
//                .foregroundStyle(appState.themeColor)
//                .padding(.vertical, 10)
//                .padding(.horizontal, 12)
//                .frame(maxWidth: .infinity, alignment: .leading)
//            }
//            .buttonStyle(.plain)
//        }
//    }
//
//    private func deleteTask(at index: Int) {
//        guard index < appState.tasks.count else { return }
//        withAnimation { appState.tasks.remove(at: index) }
//    }
//
//    @ViewBuilder
//    private func singleTaskRow(i: Int, task: TaskItem) -> some View {
//        HStack(spacing: 10) {
//            Image(systemName: "line.3.horizontal")
//                .font(.system(size: 14, weight: .medium))
//                .foregroundColor(AppTheme.textSecondary.opacity(0.5))
//                .frame(width: 20)
//
//            VStack(alignment: .leading, spacing: 2) {
//                taskTitleView(task: task)
//                if !task.displayTime.isEmpty {
//                    Text(task.displayTime)
//                        .font(.system(size: 11, weight: .semibold))
//                        .foregroundStyle(task.isCountdown && task.progressFraction >= 1.0
//                            ? appState.themeColor : AppTheme.textSecondary)
//                }
//            }
//
//            Spacer()
//
//            if task.isDone {
//                Image(systemName: "checkmark.circle.fill")
//                    .font(.system(size: 20))
//                    .foregroundStyle(appState.themeColor)
//                    .onTapGesture { appState.toggleTask(task) }
//            } else {
//                Button {
//                    appState.focusTaskId = task.id
//                    selectedTab = .focus
//                } label: {
//                    Text("Start")
//                        .font(.system(size: 12, weight: .bold))
//                        .foregroundStyle(.white)
//                        .padding(.horizontal, 12)
//                        .padding(.vertical, 6)
//                        .background(Capsule().fill(appState.themeColor))
//                }
//                .buttonStyle(.plain)
//            }
//        }
//        .padding(.horizontal, 12)
//        .padding(.vertical, 10)
//        .contentShape(Rectangle())
//    }
//
//    @ViewBuilder
//    private func taskTitleView(task: TaskItem) -> some View {
//        if editingTaskId == task.id {
//            TextField("", text: $editingText)
//                .font(.system(size: 15, weight: .medium))
//                .foregroundColor(AppTheme.textPrimary)
//                .focused($editFieldFocused)
//                .submitLabel(.done)
//                .onSubmit { commitEdit() }
//                .frame(maxWidth: .infinity, alignment: .leading)
//        } else {
//            Text(task.title)
//                .font(.system(size: 15, weight: .medium))
//                .foregroundColor(task.isDone ? AppTheme.textSecondary : AppTheme.textPrimary)
//                .strikethrough(task.isDone, color: AppTheme.textSecondary)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .contentShape(Rectangle())
//                .onTapGesture(count: 2) {
//                    editingTaskId = task.id
//                    editingText = task.title
//                    editFieldFocused = true
//                }
//                .onTapGesture(count: 1) {}
//        }
//    }
//
//    private func commitEdit() {
//        guard let id = editingTaskId else { return }
//        let trimmed = editingText.trimmingCharacters(in: .whitespaces)
//        if !trimmed.isEmpty, let idx = appState.tasks.firstIndex(where: { $0.id == id }) {
//            appState.tasks[idx].title = trimmed
//        }
//        editingTaskId = nil
//        editingText = ""
//        editFieldFocused = false
//    }
//}
//
//// MARK: - Goals Section
//
//struct GoalsSection: View {
//    @EnvironmentObject var appState: AppState
//    @State private var showAddPlanSheet = false
//    @State private var selectedPlan: LongTermPlan? = nil
//
//    let selectedMonth: Int
//    let selectedYear: Int
//
//    // Plans whose time span includes the selected month
//    private var filteredPlans: [LongTermPlan] {
//        let sel = selectedYear * 12 + selectedMonth
//        return appState.longTermPlans.filter { plan in
//            let start = plan.startYear * 12 + plan.startMonth
//            let end   = plan.endYear   * 12 + plan.endMonth
//            return sel >= start && sel <= end
//        }
//    }
//
//    // Milestone items for the selected month (sub-goals with matching targetMonth/Year)
//    private struct MilestoneEntry: Identifiable {
//        let id: UUID
//        let planId: UUID
//        let planTitle: String
//        let goalItem: PlanGoalItem
//    }
//
//    private var milestones: [MilestoneEntry] {
//        filteredPlans.flatMap { plan in
//            plan.goalItems
//                .filter { item in item.hasMonth(selectedMonth, selectedYear) }
//                .map { item in
//                    MilestoneEntry(id: item.id, planId: plan.id, planTitle: plan.title, goalItem: item)
//                }
//        }
//    }
//
//    var body: some View {
//        VStack(spacing: 10) {
//            // Plan cards (existing behaviour)
//            ForEach(filteredPlans) { plan in
//                goalRow(plan: plan)
//            }
//
//            // Milestone sub-goals for this month
//            if !milestones.isEmpty {
//                VStack(alignment: .leading, spacing: 6) {
//                    HStack(spacing: 6) {
//                        Image(systemName: "flag.fill")
//                            .font(.system(size: 11, weight: .semibold))
//                            .foregroundStyle(appState.themeColor)
//                        Text("This Month's Milestones")
//                            .font(.system(size: 12, weight: .bold))
//                            .foregroundStyle(appState.themeColor)
//                    }
//                    .padding(.horizontal, 4)
//
//                    ForEach(milestones) { entry in
//                        milestoneRow(entry: entry)
//                    }
//                }
//            }
//
//            Button { showAddPlanSheet = true } label: {
//                HStack(spacing: 6) {
//                    Image(systemName: "plus").font(.system(size: 12, weight: .bold))
//                    Text("Add Goal").font(.system(size: 13, weight: .semibold))
//                }
//                .foregroundStyle(appState.themeColor)
//                .padding(.horizontal, 14).padding(.vertical, 8)
//                .background(Capsule().fill(appState.themeColor.opacity(0.10)))
//            }
//            .buttonStyle(.plain)
//        }
//        .sheet(isPresented: $showAddPlanSheet) {
//            AddPlanSheet().environmentObject(appState)
//        }
//        .sheet(item: $selectedPlan) { plan in
//            PlanDetailSheetWrapper(plan: plan).environmentObject(appState)
//        }
//    }
//
//    // Existing plan card row
//    private func goalRow(plan: LongTermPlan) -> some View {
//        Button { selectedPlan = plan } label: {
//            HStack(spacing: 12) {
//                Image(systemName: "checkmark")
//                    .font(.system(size: 13, weight: .bold))
//                    .foregroundStyle(appState.themeColor)
//                VStack(alignment: .leading, spacing: 2) {
//                    Text(plan.title)
//                        .font(.system(size: 15, weight: .semibold))
//                        .foregroundStyle(AppTheme.textPrimary)
//                    if !plan.dateRange.isEmpty {
//                        Text(plan.dateRange)
//                            .font(.system(size: 11, weight: .medium))
//                            .foregroundStyle(AppTheme.textSecondary)
//                    }
//                }
//                Spacer()
//                if plan.totalCount > 0 {
//                    Text("\(plan.completedCount)/\(plan.totalCount)")
//                        .font(.system(size: 12, weight: .semibold))
//                        .foregroundStyle(appState.themeColor.opacity(0.8))
//                }
//                Button { appState.deletePlan(plan) } label: {
//                    Image(systemName: "xmark")
//                        .font(.system(size: 11, weight: .bold))
//                        .foregroundStyle(AppTheme.textSecondary)
//                }
//                .buttonStyle(.plain)
//            }
//            .padding(.horizontal, 14).padding(.vertical, 10)
//            .background(RoundedRectangle(cornerRadius: 12).fill(appState.themeColor.opacity(0.10)))
//        }
//        .buttonStyle(.plain)
//    }
//
//    // Milestone row: sub-goal title + plan name subtitle + add-to-today button
//    private func milestoneRow(entry: MilestoneEntry) -> some View {
//        let alreadyInToday = appState.tasks.contains {
//            $0.title.lowercased() == entry.goalItem.title.lowercased()
//        }
//        return HStack(spacing: 12) {
//            // Done indicator from plan
//            Image(systemName: entry.goalItem.isDone ? "checkmark.circle.fill" : "circle")
//                .font(.system(size: 18, weight: .semibold))
//                .foregroundStyle(entry.goalItem.isDone ? appState.themeColor : appState.themeColor.opacity(0.35))
//
//            VStack(alignment: .leading, spacing: 2) {
//                Text(entry.goalItem.title)
//                    .font(.system(size: 14, weight: .semibold))
//                    .foregroundStyle(entry.goalItem.isDone ? AppTheme.textSecondary : AppTheme.textPrimary)
//                    .strikethrough(entry.goalItem.isDone, color: AppTheme.textSecondary)
//                // Plan name subtitle
//                Text(entry.planTitle)
//                    .font(.system(size: 11, weight: .medium))
//                    .foregroundStyle(appState.themeColor.opacity(0.7))
//            }
//
//            Spacer()
//
//            // Add to today's tasks button
//            if !alreadyInToday {
//                Button {
//                    appState.addTask(entry.goalItem.title)
//                } label: {
//                    HStack(spacing: 4) {
//                        Image(systemName: "plus")
//                            .font(.system(size: 10, weight: .bold))
//                        Text("Today")
//                            .font(.system(size: 11, weight: .semibold))
//                    }
//                    .foregroundStyle(appState.themeColor)
//                    .padding(.horizontal, 9).padding(.vertical, 5)
//                    .background(Capsule().fill(appState.themeColor.opacity(0.12)))
//                }
//                .buttonStyle(.plain)
//            } else {
//                Image(systemName: "sun.max.fill")
//                    .font(.system(size: 13))
//                    .foregroundStyle(appState.themeColor.opacity(0.5))
//            }
//        }
//        .padding(.horizontal, 14).padding(.vertical, 10)
//        .background(RoundedRectangle(cornerRadius: 12).fill(appState.themeColor.opacity(0.07)))
//        .overlay(RoundedRectangle(cornerRadius: 12).stroke(appState.themeColor.opacity(0.15), lineWidth: 1))
//    }
//}
//
//private struct PlanDetailSheetWrapper: View {
//    @EnvironmentObject var appState: AppState
//    let plan: LongTermPlan
//    var body: some View {
//        NavigationStack {
//            PlanDetailView(plan: plan).environmentObject(appState)
//        }
//    }
//}
//
//// MARK: - Stats Section
//
//struct StatsSection: View {
//    @EnvironmentObject var appState: AppState
//    let minutes: Int
//    let progress: Double
//    let calendarCells: [(day: Int, hours: Double, highlighted: Bool)]
//
//    var body: some View {
//        HStack(spacing: 16) {
//            progressRing
//            calendarGrid
//        }
//    }
//
//    private var progressRing: some View {
//        ZStack {
//            Circle()
//                .stroke(Color(white: 0.5, opacity: 0.2), lineWidth: 14)
//            Circle()
//                .trim(from: 0, to: progress)
//                .stroke(appState.themeColor, lineWidth: 14)
//                .rotationEffect(.degrees(-90))
//            VStack(spacing: 2) {
//                Text("\(minutes)")
//                    .font(.system(size: 18, weight: .bold))
//                    .foregroundStyle(AppTheme.textPrimary)
//                Text("min")
//                    .font(.system(size: 11, weight: .semibold))
//                    .foregroundStyle(AppTheme.textSecondary)
//            }
//        }
//        .frame(width: 120, height: 120)
//    }
//
//    private var calendarGrid: some View {
//        LazyVGrid(
//            columns: Array(repeating: .init(.flexible(), spacing: 5), count: 7),
//            spacing: 5
//        ) {
//            ForEach(calendarCells, id: \.day) { cell in
//                calendarCell(cell)
//            }
//        }
//    }
//
//    private func calendarCell(_ cell: (day: Int, hours: Double, highlighted: Bool)) -> some View {
//        let bgOpacity: Double = cell.highlighted ? 0.22 : 0.07
//        let textOpacity: Double = cell.highlighted ? 1.0 : 0.4
//        return VStack(spacing: 1) {
//            Text("\(cell.day)")
//                .font(.system(size: 10, weight: .bold))
//                .foregroundColor(AppTheme.textPrimary.opacity(textOpacity))
//            if cell.highlighted {
//                Text(String(format: "%.1fh", cell.hours))
//                    .font(.system(size: 7, weight: .semibold))
//                    .foregroundStyle(appState.themeColor)
//            }
//        }
//        .frame(height: 28)
//        .frame(maxWidth: .infinity)
//        .background(appState.themeColor.opacity(bgOpacity))
//        .cornerRadius(6)
//    }
//}
//
//// MARK: - Add Task Overlay
//
//struct AddTaskOverlay: View {
//    @EnvironmentObject var appState: AppState
//    @Binding var show: Bool
//    let onAdd: (String, TaskTimerMode, Int) -> Void
//
//    @State private var title = ""
//    @State private var mode: TaskTimerMode = .stopwatch
//    @State private var targetHour = 0
//    @State private var targetMin = 25
//    @State private var targetSec = 0
//    @FocusState private var focused: Bool
//
//    private var targetSeconds: Int { targetHour * 3600 + targetMin * 60 + targetSec }
//
//    var body: some View {
//        ZStack {
//            Color(white: 0.0, opacity: 0.3).ignoresSafeArea().onTapGesture { show = false }
//            VStack(spacing: 16) {
//                Text("New Task")
//                    .font(.system(size: 17, weight: .bold))
//                    .foregroundStyle(AppTheme.textPrimary)
//
//                // Title field
//                TextField("Task title...", text: $title)
//                    .font(.system(size: 15, weight: .medium))
//                    .foregroundColor(AppTheme.textPrimary)
//                    .padding(14)
//                    .background(RoundedRectangle(cornerRadius: 12).fill(appState.bgColor))
//                    .focused($focused)
//                    .submitLabel(.done)
//
//                // Mode picker
//                HStack(spacing: 0) {
//                    ForEach([TaskTimerMode.stopwatch, .countdown], id: \.rawValue) { m in
//                        Button {
//                            withAnimation(.easeInOut(duration: 0.2)) { mode = m }
//                        } label: {
//                            HStack(spacing: 6) {
//                                Image(systemName: m == .stopwatch ? "stopwatch" : "timer")
//                                    .font(.system(size: 13, weight: .semibold))
//                                Text(m == .stopwatch ? "Stopwatch" : "Countdown")
//                                    .font(.system(size: 13, weight: .semibold))
//                            }
//                            .foregroundStyle(mode == m ? .white : appState.themeColor)
//                            .frame(maxWidth: .infinity)
//                            .padding(.vertical, 9)
//                            .background(mode == m ? appState.themeColor : Color.clear)
//                        }
//                        .buttonStyle(.plain)
//                    }
//                }
//                .background(RoundedRectangle(cornerRadius: 10).fill(appState.themeColor.opacity(0.10)))
//                .clipShape(RoundedRectangle(cornerRadius: 10))
//
//                // Target duration picker (countdown only)
//                if mode == .countdown {
//                    VStack(spacing: 4) {
//                        Text("Target Duration")
//                            .font(.system(size: 12, weight: .bold))
//                            .foregroundStyle(AppTheme.textSecondary)
//                            .textCase(.uppercase)
//                        HStack(spacing: 0) {
//                            wheelCol(label: "h", range: 0...23, selection: $targetHour)
//                            wheelCol(label: "min", range: 0...59, selection: $targetMin)
//                            wheelCol(label: "sec", range: 0...59, selection: $targetSec)
//                        }
//                        .frame(height: 100)
//                        .background(RoundedRectangle(cornerRadius: 12).fill(appState.bgColor))
//                        .colorScheme(.light)
//                    }
//                }
//
//                // Buttons
//                HStack(spacing: 12) {
//                    Button("Cancel") { show = false }
//                        .font(.system(size: 15, weight: .semibold))
//                        .foregroundStyle(appState.themeColor)
//                        .frame(maxWidth: .infinity).padding(.vertical, 12)
//                        .background(Capsule().fill(appState.themeColor.opacity(0.10)))
//                        .buttonStyle(.plain)
//                    Button("Add") {
//                        let t = title.trimmingCharacters(in: .whitespaces)
//                        guard !t.isEmpty else { return }
//                        onAdd(t, mode, mode == .countdown ? targetSeconds : 0)
//                    }
//                    .font(.system(size: 15, weight: .bold))
//                    .foregroundStyle(Color.white)
//                    .frame(maxWidth: .infinity).padding(.vertical, 12)
//                    .background(Capsule().fill(title.trimmingCharacters(in: .whitespaces).isEmpty
//                        ? Color.gray.opacity(0.4) : appState.themeColor))
//                    .buttonStyle(.plain)
//                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
//                }
//            }
//            .padding(20)
//            .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
//            .padding(.horizontal, 32)
//        }
//        .onAppear { focused = true }
//    }
//
//    private func wheelCol(label: String, range: ClosedRange<Int>, selection: Binding<Int>) -> some View {
//        VStack(spacing: 2) {
//            Picker("", selection: selection) {
//                ForEach(Array(range), id: \.self) { v in Text("\(v)").tag(v) }
//            }
//            .labelsHidden()
//            .pickerStyle(.wheel)
//            .frame(maxWidth: .infinity)
//            .clipped()
//            Text(label)
//                .font(.system(size: 11, weight: .semibold))
//                .foregroundStyle(AppTheme.textSecondary)
//        }
//    }
//}
//
//// MARK: - Tab Wrappers
//
//struct StartFocusScreen: View {
//    @Binding var selectedTab: AppTab
//    var body: some View { FocusView(selectedTab: $selectedTab) }
//}
//
//struct SettingsScreen: View {
//    var body: some View { SettingsView() }
//}
//
//// MARK: - Swipe To Delete Row
//
//struct SwipeToDeleteRow<Content: View>: View {
//    let content: Content
//    let onDelete: () -> Void
//
//    @State private var offset: CGFloat = 0
//    private let deleteThreshold: CGFloat = 60
//    private let buttonWidth: CGFloat = 72
//
//    init(@ViewBuilder content: () -> Content, onDelete: @escaping () -> Void) {
//        self.content = content()
//        self.onDelete = onDelete
//    }
//
//    var body: some View {
//        ZStack(alignment: .trailing) {
//            // Delete button — behind content, only visible when swiped
//            if offset < -10 {
//                Button {
//                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { offset = 0 }
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { onDelete() }
//                } label: {
//                    ZStack {
//                        Color.red
//                        Image(systemName: "trash")
//                            .font(.system(size: 16, weight: .semibold))
//                            .foregroundColor(.white)
//                    }
//                    .frame(width: buttonWidth)
//                    .frame(maxHeight: .infinity)
//                }
//                .buttonStyle(.plain)
//                .transition(.opacity)
//            }
//
//            // Main content slides left
//            content
//                .offset(x: offset)
//                .gesture(
//                    DragGesture(minimumDistance: 8)
//                        .onChanged { value in
//                            let drag = value.translation.width
//                            if drag < 0 {
//                                offset = max(drag, -buttonWidth)
//                            } else if offset < 0 {
//                                offset = min(0, offset + drag)
//                            }
//                        }
//                        .onEnded { value in
//                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
//                                offset = value.translation.width < -deleteThreshold ? -buttonWidth : 0
//                            }
//                        }
//                )
//        }
//        .clipped()
//    }
//}




import SwiftUI

// MARK: - Root Tab View

enum AppTab: Hashable {
    case tasks, focus, settings
}

struct TasksView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: AppTab = .tasks

    var body: some View {
        TabView(selection: $selectedTab) {
            TasksScreen(selectedTab: $selectedTab)
                .tabItem { Label("Tasks", systemImage: "list.bullet") }
                .tag(AppTab.tasks)
            StartFocusScreen(selectedTab: $selectedTab)
                .tabItem { Label("Start Focus", systemImage: "play.fill") }
                .tag(AppTab.focus)
            SettingsScreen()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(AppTab.settings)
        }
        .tint(appState.themeColor)
    }
}

// MARK: - Tasks Screen

struct TasksScreen: View {
    @EnvironmentObject var appState: AppState
    @Binding var selectedTab: AppTab

    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var showAddTask = false
    @State private var newTaskTitle = ""

    private let months = ["Jan","Feb","Mar","Apr","May","Jun",
                          "Jul","Aug","Sep","Oct","Nov","Dec"]
    private let years = Array(2024...2029)

    var progressValue: Double {
        let target = Double(appState.dailyTargetHours * 60)
        guard target > 0 else { return 0 }
        return min(Double(appState.todayMinutes) / target, 1.0)
    }

    var body: some View {
        ZStack {
            appState.bgColor.ignoresSafeArea()
            VStack(spacing: 0) {
                ProfileHeader()
                Divider()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        TasksListCard(showAddTask: $showAddTask, newTaskTitle: $newTaskTitle, selectedTab: $selectedTab)
                        monthYearPickers
                        GoalsSection(selectedMonth: selectedMonth, selectedYear: selectedYear)
                        StatsSection(
                            minutes: appState.todayMinutes,
                            progress: progressValue,
                            selectedMonth: $selectedMonth,
                            selectedYear: $selectedYear
                        )
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 16)
                    .padding(.bottom, 120)
                }
            }
            if showAddTask {
                AddTaskOverlay(show: $showAddTask) { title, mode, targetSecs in
                    appState.addTask(title, timerMode: mode, targetSeconds: targetSecs)
                    showAddTask = false
                }
            }
        }
        .onAppear { appState.checkDailyReset() }
    }

    private var monthYearPickers: some View {
        HStack(spacing: 12) {
            Picker("", selection: $selectedMonth) {
                ForEach(1...12, id: \.self) { m in Text(months[m-1]).tag(m) }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12).padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(appState.themeColor.opacity(0.12), lineWidth: 1))
            .tint(appState.themeColor)

            Picker("", selection: $selectedYear) {
                ForEach(years, id: \.self) { y in Text(String(y)).tag(y) }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12).padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(appState.themeColor.opacity(0.12), lineWidth: 1))
            .tint(appState.themeColor)
        }
    }
}

// MARK: - Profile Header

struct ProfileHeader: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(appState.themeColor.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay {
                    if let data = appState.currentUser.avatarData,
                       let img = UIImage(data: data) {
                        Image(uiImage: img)
                            .resizable().scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.fill")
                            .foregroundColor(appState.themeColor)
                    }
                }
            VStack(alignment: .leading, spacing: 4) {
                Text("Name: \(appState.currentUser.name)")
                Text("Today: \(String(format: "%.1f", appState.todayHours))h")
                Text("Total tasks: \(appState.totalTasksCount)")
                Text("Completed: \(appState.completedTasksCount)")
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(AppTheme.textPrimary)
            Spacer()
        }
        .padding(18)
    }
}

// MARK: - Tasks List Card

struct TasksListCard: View {
    @EnvironmentObject var appState: AppState
    @Binding var showAddTask: Bool
    @Binding var newTaskTitle: String
    @Binding var selectedTab: AppTab

    @State private var editingTaskId: UUID? = nil
    @State private var editingText: String = ""
    @FocusState private var editFieldFocused: Bool

    private let cardStroke = Color(white: 0.0, opacity: 0.06)
    private let cardFill = Color(white: 1.0, opacity: 0.7)
    private let dividerOpacity: Double = 0.08

    var body: some View {
        VStack(spacing: 0) {
            taskRows
            addButton
        }
        .background(RoundedRectangle(cornerRadius: 16).fill(cardFill))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(cardStroke, lineWidth: 1))
        .onTapGesture { if editingTaskId != nil { commitEdit() } }
    }

    private var taskRows: some View {
        ForEach(Array(appState.tasks.enumerated()), id: \.element.id) { i, task in
            VStack(spacing: 0) {
                SwipeToDeleteRow {
                    singleTaskRow(i: i, task: task)
                } onDelete: {
                    deleteTask(at: i)
                }
                if i < appState.tasks.count - 1 {
                    Rectangle()
                        .fill(Color(white: 0.0, opacity: dividerOpacity))
                        .frame(height: 0.5)
                        .padding(.horizontal, 12)
                }
            }
        }
    }

    private var addButton: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color(white: 0.0, opacity: dividerOpacity))
                .frame(height: 0.5)
                .padding(.horizontal, 12)
            Button { showAddTask = true } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill").font(.system(size: 16, weight: .semibold))
                    Text("Add Task").font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(appState.themeColor)
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
        }
    }

    private func deleteTask(at index: Int) {
        guard index < appState.tasks.count else { return }
        withAnimation { appState.tasks.remove(at: index) }
    }

    @ViewBuilder
    private func singleTaskRow(i: Int, task: TaskItem) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.textSecondary.opacity(0.5))
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                taskTitleView(task: task)
                if !task.displayTime.isEmpty {
                    Text(task.displayTime)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(task.isCountdown && task.progressFraction >= 1.0
                            ? appState.themeColor : AppTheme.textSecondary)
                }
            }

            Spacer()

            if task.isDone {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(appState.themeColor)
                    .onTapGesture { appState.toggleTask(task) }
            } else {
                Button {
                    appState.focusTaskId = task.id
                    selectedTab = .focus
                } label: {
                    Text("Start")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(appState.themeColor))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private func taskTitleView(task: TaskItem) -> some View {
        if editingTaskId == task.id {
            TextField("", text: $editingText)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
                .focused($editFieldFocused)
                .submitLabel(.done)
                .onSubmit { commitEdit() }
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            Text(task.title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(task.isDone ? AppTheme.textSecondary : AppTheme.textPrimary)
                .strikethrough(task.isDone, color: AppTheme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture(count: 2) {
                    editingTaskId = task.id
                    editingText = task.title
                    editFieldFocused = true
                }
                .onTapGesture(count: 1) {}
        }
    }

    private func commitEdit() {
        guard let id = editingTaskId else { return }
        let trimmed = editingText.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty, let idx = appState.tasks.firstIndex(where: { $0.id == id }) {
            appState.tasks[idx].title = trimmed
        }
        editingTaskId = nil
        editingText = ""
        editFieldFocused = false
    }
}

// MARK: - Goals Section

struct GoalsSection: View {
    @EnvironmentObject var appState: AppState
    @State private var showAddPlanSheet = false
    @State private var selectedPlan: LongTermPlan? = nil

    let selectedMonth: Int
    let selectedYear: Int

    // Plans whose time span includes the selected month
    private var filteredPlans: [LongTermPlan] {
        let sel = selectedYear * 12 + selectedMonth
        return appState.longTermPlans.filter { plan in
            let start = plan.startYear * 12 + plan.startMonth
            let end   = plan.endYear   * 12 + plan.endMonth
            return sel >= start && sel <= end
        }
    }

    // Milestone items for the selected month (sub-goals with matching targetMonth/Year)
    private struct MilestoneEntry: Identifiable {
        let id: UUID
        let planId: UUID
        let planTitle: String
        let goalItem: PlanGoalItem
    }

    private var milestones: [MilestoneEntry] {
        filteredPlans.flatMap { plan in
            plan.goalItems
                .filter { item in item.hasMonth(selectedMonth, selectedYear) }
                .map { item in
                    MilestoneEntry(id: item.id, planId: plan.id, planTitle: plan.title, goalItem: item)
                }
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            // Plan cards (existing behaviour)
            ForEach(filteredPlans) { plan in
                goalRow(plan: plan)
            }

            // Milestone sub-goals for this month
            if !milestones.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "flag.fill")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(appState.themeColor)
                        Text("This Month's Milestones")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(appState.themeColor)
                    }
                    .padding(.horizontal, 4)

                    ForEach(milestones) { entry in
                        milestoneRow(entry: entry)
                    }
                }
            }

            Button { showAddPlanSheet = true } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus").font(.system(size: 12, weight: .bold))
                    Text("Add Goal").font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(appState.themeColor)
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(Capsule().fill(appState.themeColor.opacity(0.10)))
            }
            .buttonStyle(.plain)
        }
        .sheet(isPresented: $showAddPlanSheet) {
            AddPlanSheet().environmentObject(appState)
        }
        .sheet(item: $selectedPlan) { plan in
            PlanDetailSheetWrapper(plan: plan).environmentObject(appState)
        }
    }

    // Existing plan card row
    private func goalRow(plan: LongTermPlan) -> some View {
        Button { selectedPlan = plan } label: {
            HStack(spacing: 12) {
                Image(systemName: "checkmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(appState.themeColor)
                VStack(alignment: .leading, spacing: 2) {
                    Text(plan.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                    if !plan.dateRange.isEmpty {
                        Text(plan.dateRange)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
                Spacer()
                if plan.totalCount > 0 {
                    Text("\(plan.completedCount)/\(plan.totalCount)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(appState.themeColor.opacity(0.8))
                }
                Button { appState.deletePlan(plan) } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14).padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 12).fill(appState.themeColor.opacity(0.10)))
        }
        .buttonStyle(.plain)
    }

    // Milestone row: sub-goal title + plan name subtitle + add-to-today button
    private func milestoneRow(entry: MilestoneEntry) -> some View {
        let alreadyInToday = appState.tasks.contains {
            $0.title.lowercased() == entry.goalItem.title.lowercased()
        }
        return HStack(spacing: 12) {
            // Done indicator from plan
            Image(systemName: entry.goalItem.isDone ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(entry.goalItem.isDone ? appState.themeColor : appState.themeColor.opacity(0.35))

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.goalItem.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(entry.goalItem.isDone ? AppTheme.textSecondary : AppTheme.textPrimary)
                    .strikethrough(entry.goalItem.isDone, color: AppTheme.textSecondary)
                // Plan name subtitle
                Text(entry.planTitle)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(appState.themeColor.opacity(0.7))
            }

            Spacer()

            // Add to today's tasks button
            if !alreadyInToday {
                Button {
                    appState.addTask(entry.goalItem.title)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 10, weight: .bold))
                        Text("Today")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(appState.themeColor)
                    .padding(.horizontal, 9).padding(.vertical, 5)
                    .background(Capsule().fill(appState.themeColor.opacity(0.12)))
                }
                .buttonStyle(.plain)
            } else {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(appState.themeColor.opacity(0.5))
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 12).fill(appState.themeColor.opacity(0.07)))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(appState.themeColor.opacity(0.15), lineWidth: 1))
    }
}

private struct PlanDetailSheetWrapper: View {
    @EnvironmentObject var appState: AppState
    let plan: LongTermPlan
    var body: some View {
        NavigationStack {
            PlanDetailView(plan: plan).environmentObject(appState)
        }
    }
}

// MARK: - Stats Section

struct StatsSection: View {
    @EnvironmentObject var appState: AppState
    let minutes: Int
    let progress: Double
    @Binding var selectedMonth: Int
    @Binding var selectedYear: Int

    private let monthNames = ["Jan","Feb","Mar","Apr","May","Jun",
                               "Jul","Aug","Sep","Oct","Nov","Dec"]

    private var calendarCells: [(day: Int, hours: Double, highlighted: Bool)] {
        let days = daysInMonth
        return (1...days).map { day in
            let h = appState.hoursForDay(day, month: selectedMonth, year: selectedYear)
            return (day, h, h > 0)
        }
    }

    private var daysInMonth: Int {
        var comps = DateComponents()
        comps.year = selectedYear; comps.month = selectedMonth
        return Calendar.current.range(of: .day, in: .month,
            for: Calendar.current.date(from: comps)!)?.count ?? 30
    }

    private func prevMonth() {
        withAnimation(.easeInOut(duration: 0.2)) {
            if selectedMonth == 1 { selectedMonth = 12; selectedYear -= 1 }
            else { selectedMonth -= 1 }
        }
    }

    private func nextMonth() {
        withAnimation(.easeInOut(duration: 0.2)) {
            if selectedMonth == 12 { selectedMonth = 1; selectedYear += 1 }
            else { selectedMonth += 1 }
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 16) {
                progressRing
                calendarGrid
            }
            // Month navigator
            HStack(spacing: 0) {
                Button(action: prevMonth) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(appState.themeColor)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                Spacer()
                Text("\(monthNames[selectedMonth - 1]) \(selectedYear)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(appState.themeColor)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 4)
        }
    }

    private var progressRing: some View {
        ZStack {
            Circle()
                .stroke(Color(white: 0.5, opacity: 0.15), lineWidth: 14)
            Circle()
                .trim(from: 0, to: max(progress, progress == 0 ? 0 : 0.02))
                .stroke(
                    LinearGradient(colors: [appState.themeColor.opacity(0.7), appState.themeColor],
                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
            VStack(spacing: 2) {
                Text("\(minutes)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                Text("min")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .frame(width: 110, height: 110)
    }

    private var calendarGrid: some View {
        LazyVGrid(
            columns: Array(repeating: .init(.flexible(), spacing: 4), count: 7),
            spacing: 4
        ) {
            ForEach(calendarCells, id: \.day) { cell in
                calendarCell(cell)
            }
        }
    }

    private func calendarCell(_ cell: (day: Int, hours: Double, highlighted: Bool)) -> some View {
        let isToday = cell.day == Calendar.current.component(.day, from: Date())
            && selectedMonth == Calendar.current.component(.month, from: Date())
            && selectedYear == Calendar.current.component(.year, from: Date())
        let bgOpacity: Double = cell.highlighted ? 0.25 : 0.07
        let textOpacity: Double = cell.highlighted ? 1.0 : 0.35
        return VStack(spacing: 1) {
            Text("\(cell.day)")
                .font(.system(size: 9, weight: isToday ? .black : .bold))
                .foregroundColor(isToday ? appState.themeColor : AppTheme.textPrimary.opacity(textOpacity))
            if cell.highlighted {
                Text(String(format: "%.1fh", cell.hours))
                    .font(.system(size: 6, weight: .semibold))
                    .foregroundStyle(appState.themeColor)
            }
        }
        .frame(height: 26)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(isToday && !cell.highlighted
                    ? appState.themeColor.opacity(0.12)
                    : appState.themeColor.opacity(bgOpacity))
        )
        .overlay(
            isToday ? RoundedRectangle(cornerRadius: 5).stroke(appState.themeColor.opacity(0.4), lineWidth: 1) : nil
        )
    }
}

// MARK: - Add Task Overlay

struct AddTaskOverlay: View {
    @EnvironmentObject var appState: AppState
    @Binding var show: Bool
    let onAdd: (String, TaskTimerMode, Int) -> Void

    @State private var title = ""
    @State private var mode: TaskTimerMode = .stopwatch
    @State private var targetHour = 0
    @State private var targetMin = 25
    @State private var targetSec = 0
    @FocusState private var focused: Bool

    private var targetSeconds: Int { targetHour * 3600 + targetMin * 60 + targetSec }

    var body: some View {
        ZStack {
            Color(white: 0.0, opacity: 0.3).ignoresSafeArea().onTapGesture { show = false }
            VStack(spacing: 16) {
                Text("New Task")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)

                // Title field
                TextField("Task title...", text: $title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 12).fill(appState.bgColor))
                    .focused($focused)
                    .submitLabel(.done)

                // Mode picker
                HStack(spacing: 0) {
                    ForEach([TaskTimerMode.stopwatch, .countdown], id: \.rawValue) { m in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { mode = m }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: m == .stopwatch ? "stopwatch" : "timer")
                                    .font(.system(size: 13, weight: .semibold))
                                Text(m == .stopwatch ? "Stopwatch" : "Countdown")
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .foregroundStyle(mode == m ? .white : appState.themeColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 9)
                            .background(mode == m ? appState.themeColor : Color.clear)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .background(RoundedRectangle(cornerRadius: 10).fill(appState.themeColor.opacity(0.10)))
                .clipShape(RoundedRectangle(cornerRadius: 10))

                // Target duration picker (countdown only)
                if mode == .countdown {
                    VStack(spacing: 4) {
                        Text("Target Duration")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(AppTheme.textSecondary)
                            .textCase(.uppercase)
                        HStack(spacing: 0) {
                            wheelCol(label: "h", range: 0...23, selection: $targetHour)
                            wheelCol(label: "min", range: 0...59, selection: $targetMin)
                            wheelCol(label: "sec", range: 0...59, selection: $targetSec)
                        }
                        .frame(height: 100)
                        .background(RoundedRectangle(cornerRadius: 12).fill(appState.bgColor))
                        .colorScheme(.light)
                    }
                }

                // Buttons
                HStack(spacing: 12) {
                    Button("Cancel") { show = false }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(appState.themeColor)
                        .frame(maxWidth: .infinity).padding(.vertical, 12)
                        .background(Capsule().fill(appState.themeColor.opacity(0.10)))
                        .buttonStyle(.plain)
                    Button("Add") {
                        let t = title.trimmingCharacters(in: .whitespaces)
                        guard !t.isEmpty else { return }
                        onAdd(t, mode, mode == .countdown ? targetSeconds : 0)
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 12)
                    .background(Capsule().fill(title.trimmingCharacters(in: .whitespaces).isEmpty
                        ? Color.gray.opacity(0.4) : appState.themeColor))
                    .buttonStyle(.plain)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
            .padding(.horizontal, 32)
        }
        .onAppear { focused = true }
    }

    private func wheelCol(label: String, range: ClosedRange<Int>, selection: Binding<Int>) -> some View {
        VStack(spacing: 2) {
            Picker("", selection: selection) {
                ForEach(Array(range), id: \.self) { v in Text("\(v)").tag(v) }
            }
            .labelsHidden()
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
            .clipped()
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AppTheme.textSecondary)
        }
    }
}

// MARK: - Tab Wrappers

struct StartFocusScreen: View {
    @Binding var selectedTab: AppTab
    var body: some View { FocusView(selectedTab: $selectedTab) }
}

struct SettingsScreen: View {
    var body: some View { SettingsView() }
}

// MARK: - Swipe To Delete Row

struct SwipeToDeleteRow<Content: View>: View {
    let content: Content
    let onDelete: () -> Void

    @State private var offset: CGFloat = 0
    private let deleteThreshold: CGFloat = 60
    private let buttonWidth: CGFloat = 72

    init(@ViewBuilder content: () -> Content, onDelete: @escaping () -> Void) {
        self.content = content()
        self.onDelete = onDelete
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete button — behind content, only visible when swiped
            if offset < -10 {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { offset = 0 }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { onDelete() }
                } label: {
                    ZStack {
                        Color.red
                        Image(systemName: "trash")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(width: buttonWidth)
                    .frame(maxHeight: .infinity)
                }
                .buttonStyle(.plain)
                .transition(.opacity)
            }

            // Main content slides left
            content
                .offset(x: offset)
                .gesture(
                    DragGesture(minimumDistance: 8)
                        .onChanged { value in
                            let drag = value.translation.width
                            if drag < 0 {
                                offset = max(drag, -buttonWidth)
                            } else if offset < 0 {
                                offset = min(0, offset + drag)
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                offset = value.translation.width < -deleteThreshold ? -buttonWidth : 0
                            }
                        }
                )
        }
        .clipped()
    }
}
