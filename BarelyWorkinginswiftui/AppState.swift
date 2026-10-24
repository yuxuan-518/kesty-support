//
//
//import SwiftUI
//import Combine
//
//// MARK: - Central App State
//
//class AppState: ObservableObject {
//
//    // MARK: Auth
//    @AppStorage("is_logged_in") var isLoggedIn: Bool = false
//
//    // MARK: Settings (global — not per-user, intentional)
//    @AppStorage("selected_theme_color") var selectedThemeColor: String = "Teal"
//    @AppStorage("selected_bg_color")    var selectedBgColor: String    = "Mint"
//    @AppStorage("selected_language")    var selectedLanguage: String   = "English"
//    @AppStorage("cloud_sync_enabled")   var cloudSyncEnabled: Bool     = true
//    @AppStorage("daily_target_hours")   var dailyTargetHours: Int      = 2
//
//    // FIX #4: currentStreak is now fully per-user managed via loadUserData/saveUserData.
//    // Removed @AppStorage("current_streak") to eliminate the global-key conflict.
//    @Published var currentStreak: Int = 0
//
//    // MARK: Focus routing
//    @Published var focusTaskId: UUID? = nil
//
//    // MARK: User
//    @Published var currentUser: UserProfile = UserProfile() {
//        didSet { if !isLoadingUserData { saveUser() } }
//    }
//
//    // MARK: Tasks
//    @Published var tasks: [TaskItem] = [] {
//        didSet { if !isLoadingUserData { saveTasks() } }
//    }
//
//    // MARK: Goals / Plans
//    @Published var goals: [GoalItem] = [] {
//        didSet { if !isLoadingUserData { saveGoals() } }
//    }
//    @Published var longTermPlans: [LongTermPlan] = [] {
//        didSet { if !isLoadingUserData { savePlans() } }
//    }
//
//    // MARK: Focus Sessions
//    // FIX #2: Full history kept in memory so hoursForDay() works for past months.
//    // todayHours / todayMinutes already filter by date — no need to strip on load.
//    @Published var focusSessions: [FocusSession] = [] {
//        didSet { if !isLoadingUserData { saveSessions() } }
//    }
//
//    // MARK: Streak
//    @Published var isNewRecord: Bool = false
//
//    // MARK: Daily Reset
//    @Published var lastResetDate: Date = Date.distantPast {
//        didSet {
//            if !isLoadingUserData, !currentUser.email.isEmpty {
//                UserDefaults.standard.set(lastResetDate,
//                    forKey: storageKey("last_reset_date", for: currentUser.email))
//            }
//        }
//    }
//    @Published var dailyTaskHistory: [String: [TaskItem]] = [:] {
//        didSet { if !isLoadingUserData { saveHistory() } }
//    }
//
//    private var isLoadingUserData = false
//
//    // MARK: Init
//    init() { loadComplexData() }
//
//    // MARK: Computed
//    var completedTasksCount: Int { tasks.filter { $0.isDone }.count }
//    var totalTasksCount: Int { tasks.count }
//
//    var todayHours: Double {
//        let today = Calendar.current.startOfDay(for: Date())
//        return focusSessions
//            .filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
//            .reduce(0) { $0 + $1.duration } / 3600
//    }
//    var todayMinutes: Int {
//        let today = Calendar.current.startOfDay(for: Date())
//        return Int(focusSessions
//            .filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
//            .reduce(0) { $0 + $1.duration } / 60)
//    }
//
//    var themeColor: Color {
//        AppTheme.themeColors.first(where: { $0.name == selectedThemeColor })?.color ?? AppTheme.primary
//    }
//    var bgColor: Color {
//        AppTheme.bgColors.first(where: { $0.name == selectedBgColor })?.color ?? AppTheme.bg
//    }
//
//    // MARK: Storage Keys
//    // All per-user data is namespaced under "u:<email>:<key>" to guarantee isolation.
//    private func storageKey(_ base: String, for email: String) -> String {
//        "u:\(email):\(base)"
//    }
//
//    private func hashPassword(_ password: String, email: String) -> String {
//        let salted = "bw_\(email.lowercased())_\(password)"
//        var h: UInt64 = 14695981039346656037
//        for byte in salted.utf8 { h ^= UInt64(byte); h = h &* 1099511628211 }
//        return String(h, radix: 16)
//    }
//
//    // MARK: Auth
//
//    func login(name: String, email: String, password: String) -> Bool {
//        let ud = UserDefaults.standard
//        let emailLow = email.lowercased().trimmingCharacters(in: .whitespaces)
//        guard !emailLow.isEmpty, !password.isEmpty else { return false }
//        let passKey = storageKey("password_hash", for: emailLow)
//        guard let savedHash = ud.string(forKey: passKey) else { return false }
//        guard hashPassword(password, email: emailLow) == savedHash else { return false }
//        // Save any in-flight data for the previously logged-in user before switching
//        if !currentUser.email.isEmpty { saveUserData(for: currentUser.email) }
//        isLoadingUserData = true
//        let userKey = storageKey("current_user", for: emailLow)
//        if let data = ud.data(forKey: userKey),
//           let savedUser = try? JSONDecoder().decode(UserProfile.self, from: data) {
//            currentUser = savedUser
//        }
//        isLoadingUserData = false
//        loadUserData(for: emailLow)
//        ud.set(emailLow, forKey: "user_email")
//        isLoggedIn = true
//        return true
//    }
//
//    func register(name: String, email: String, password: String) -> Bool {
//        let ud = UserDefaults.standard
//        let emailLow = email.lowercased().trimmingCharacters(in: .whitespaces)
//        guard !name.isEmpty, !emailLow.isEmpty, password.count >= 6 else { return false }
//        let passKey = storageKey("password_hash", for: emailLow)
//        if ud.string(forKey: passKey) != nil { return false }  // already registered
//        ud.set(hashPassword(password, email: emailLow), forKey: passKey)
//        isLoadingUserData = true
//        currentUser = UserProfile(name: name, email: emailLow, skills: [])
//        tasks = []; goals = []; longTermPlans = []; focusSessions = []
//        dailyTaskHistory = [:]; currentStreak = 0; lastResetDate = Date.distantPast
//        isLoadingUserData = false
//        ud.set(emailLow, forKey: "user_email")
//        saveUserData(for: emailLow)
//        isLoggedIn = true
//        return true
//    }
//
//    func resetPassword(email: String, newPassword: String) -> Bool {
//        let ud = UserDefaults.standard
//        let emailLow = email.lowercased().trimmingCharacters(in: .whitespaces)
//        guard !emailLow.isEmpty, newPassword.count >= 6 else { return false }
//        let passKey = storageKey("password_hash", for: emailLow)
//        guard ud.string(forKey: passKey) != nil else { return false }
//        ud.set(hashPassword(newPassword, email: emailLow), forKey: passKey)
//        return true
//    }
//
//    func logout() {
//        if !currentUser.email.isEmpty { saveUserData(for: currentUser.email) }
//        // Wipe all in-memory state so the next login starts completely clean
//        isLoadingUserData = true
//        currentUser = UserProfile()
//        tasks = []; goals = []; longTermPlans = []; focusSessions = []
//        dailyTaskHistory = [:]; currentStreak = 0; lastResetDate = Date.distantPast
//        isNewRecord = false; focusTaskId = nil
//        isLoadingUserData = false
//        UserDefaults.standard.removeObject(forKey: "user_email")
//        isLoggedIn = false
//    }
//
//    // MARK: Per-user Save / Load
//
//    private func saveUserData(for email: String) {
//        let ud = UserDefaults.standard
//        let k = { [self] (base: String) in storageKey(base, for: email) }
//        if let d = try? JSONEncoder().encode(currentUser)      { ud.set(d, forKey: k("current_user")) }
//        if let d = try? JSONEncoder().encode(tasks)            { ud.set(d, forKey: k("tasks")) }
//        if let d = try? JSONEncoder().encode(goals)            { ud.set(d, forKey: k("goals")) }
//        if let d = try? JSONEncoder().encode(longTermPlans)    { ud.set(d, forKey: k("long_term_plans")) }
//        if let d = try? JSONEncoder().encode(focusSessions)    { ud.set(d, forKey: k("focus_sessions")) }
//        if let d = try? JSONEncoder().encode(dailyTaskHistory) { ud.set(d, forKey: k("daily_task_history")) }
//        ud.set(lastResetDate, forKey: k("last_reset_date"))
//        ud.set(currentStreak, forKey: k("current_streak"))
//    }
//
//    private func loadUserData(for email: String) {
//        isLoadingUserData = true
//        defer { isLoadingUserData = false }
//        let ud = UserDefaults.standard
//        let k = { [self] (base: String) in storageKey(base, for: email) }
//
//        tasks = (ud.data(forKey: k("tasks")).flatMap { try? JSONDecoder().decode([TaskItem].self, from: $0) }) ?? []
//        goals = (ud.data(forKey: k("goals")).flatMap { try? JSONDecoder().decode([GoalItem].self, from: $0) }) ?? []
//        longTermPlans = (ud.data(forKey: k("long_term_plans")).flatMap { try? JSONDecoder().decode([LongTermPlan].self, from: $0) }) ?? []
//
//        // FIX #2: Load ALL focus sessions (not just today's).
//        // todayHours/todayMinutes filter in-place; hoursForDay() needs the full history.
//        focusSessions = (ud.data(forKey: k("focus_sessions")).flatMap { try? JSONDecoder().decode([FocusSession].self, from: $0) }) ?? []
//
//        // Load daily task history — no hard date cutoff, keep everything stored
//        dailyTaskHistory = (ud.data(forKey: k("daily_task_history")).flatMap { try? JSONDecoder().decode([String: [TaskItem]].self, from: $0) }) ?? [:]
//
//        lastResetDate = (ud.object(forKey: k("last_reset_date")) as? Date) ?? Date.distantPast
//
//        // FIX #1 (partial): Read streak from per-user key only
//        currentStreak = ud.integer(forKey: k("current_streak"))
//    }
//
//    // MARK: Task Operations
//
//    func addTask(_ title: String, goalId: UUID? = nil) {
//        tasks.append(TaskItem(title: title, isDone: false, goalId: goalId))
//    }
//    func addTask(_ title: String, goalId: UUID? = nil, timerMode: TaskTimerMode, targetSeconds: Int) {
//        tasks.append(TaskItem(title: title, isDone: false, goalId: goalId,
//                              timerMode: timerMode, targetSeconds: targetSeconds))
//    }
//    func deleteTask(_ task: TaskItem) { tasks.removeAll { $0.id == task.id } }
//    func toggleTask(_ task: TaskItem) {
//        if let idx = tasks.firstIndex(where: { $0.id == task.id }) { tasks[idx].isDone.toggle() }
//    }
//    func moveTask(from source: IndexSet, to destination: Int) {
//        tasks.move(fromOffsets: source, toOffset: destination)
//    }
//    func addTime(_ seconds: Int, to taskId: UUID) {
//        guard let idx = tasks.firstIndex(where: { $0.id == taskId }) else { return }
//        tasks[idx].accumulatedSeconds += seconds
//        if tasks[idx].isCountdown && tasks[idx].accumulatedSeconds >= tasks[idx].targetSeconds {
//            tasks[idx].isDone = true
//        }
//    }
//
//    // MARK: Daily Reset
//
//    // FIX #3: Archive key uses lastReset directly (not yesterday), so tasks are always
//    // filed under the correct date even when the user skips multiple days.
//    func checkDailyReset() {
//        let calendar = Calendar.current
//        let today = calendar.startOfDay(for: Date())
//        let lastReset = calendar.startOfDay(for: lastResetDate)
//        guard today > lastReset else { return }
//
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//
//        // Archive tasks under the date they were active (lastReset), not yesterday
//        if lastResetDate != Date.distantPast && !tasks.isEmpty {
//            dailyTaskHistory[formatter.string(from: lastReset)] = tasks
//        }
//
//        // Reset task completion & accumulated time; preserve title/id/goal/timer settings
//        tasks = tasks.map {
//            TaskItem(id: $0.id, title: $0.title, isDone: false, goalId: $0.goalId,
//                     timerMode: $0.timerMode, targetSeconds: $0.targetSeconds)
//        }
//
//        lastResetDate = Date()
//        if !currentUser.email.isEmpty {
//            UserDefaults.standard.set(lastResetDate,
//                forKey: storageKey("last_reset_date", for: currentUser.email))
//            saveHistory()
//        }
//    }
//
//    // MARK: Focus Sessions
//
//    func recordSession(duration: TimeInterval) {
//        focusSessions.append(FocusSession(duration: duration, date: Date()))
//        updateStreak()
//    }
//
//    // FIX #5: resetStatistics also persists the cleared streak to the per-user key
//    // so it isn't restored from disk on the next app launch.
//    func resetStatistics() {
//        focusSessions = []
//        currentStreak = 0
//        isNewRecord = false
//        if !currentUser.email.isEmpty {
//            UserDefaults.standard.set(0, forKey: storageKey("current_streak", for: currentUser.email))
//        }
//    }
//
//    func resetAllAccountData() {
//        tasks = []; goals = []; longTermPlans = []; focusSessions = []
//        dailyTaskHistory = [:]; currentStreak = 0; isNewRecord = false; lastResetDate = Date.distantPast
//        if !currentUser.email.isEmpty { saveUserData(for: currentUser.email) }
//    }
//
//    // MARK: Goals / Plans
//
//    func addGoal(_ title: String) { goals.append(GoalItem(title: title)) }
//    func deleteGoal(_ goal: GoalItem) { goals.removeAll { $0.id == goal.id } }
//    func addPlan(_ plan: LongTermPlan) { longTermPlans.append(plan) }
//    func deletePlan(_ plan: LongTermPlan) { longTermPlans.removeAll { $0.id == plan.id } }
//
//    // MARK: Calendar
//
//    func hoursForDay(_ day: Int, month: Int, year: Int) -> Double {
//        let calendar = Calendar.current
//        return focusSessions.filter { session in
//            let comps = calendar.dateComponents([.day, .month, .year], from: session.date)
//            return comps.day == day && comps.month == month && comps.year == year
//        }.reduce(0) { $0 + $1.duration } / 3600
//    }
//
//    // MARK: Private Save Helpers
//    // Each saves only its own slice — called by didSet observers for incremental writes.
//
//    private func saveUser() {
//        guard !currentUser.email.isEmpty else { return }
//        if let d = try? JSONEncoder().encode(currentUser) {
//            UserDefaults.standard.set(d, forKey: storageKey("current_user", for: currentUser.email))
//        }
//    }
//    private func saveTasks() {
//        guard !currentUser.email.isEmpty else { return }
//        if let d = try? JSONEncoder().encode(tasks) {
//            UserDefaults.standard.set(d, forKey: storageKey("tasks", for: currentUser.email))
//        }
//    }
//    private func saveGoals() {
//        guard !currentUser.email.isEmpty else { return }
//        if let d = try? JSONEncoder().encode(goals) {
//            UserDefaults.standard.set(d, forKey: storageKey("goals", for: currentUser.email))
//        }
//    }
//    private func savePlans() {
//        guard !currentUser.email.isEmpty else { return }
//        if let d = try? JSONEncoder().encode(longTermPlans) {
//            UserDefaults.standard.set(d, forKey: storageKey("long_term_plans", for: currentUser.email))
//        }
//    }
//    private func saveSessions() {
//        guard !currentUser.email.isEmpty else { return }
//        if let d = try? JSONEncoder().encode(focusSessions) {
//            UserDefaults.standard.set(d, forKey: storageKey("focus_sessions", for: currentUser.email))
//        }
//    }
//    private func saveHistory() {
//        guard !currentUser.email.isEmpty else { return }
//        if let d = try? JSONEncoder().encode(dailyTaskHistory) {
//            UserDefaults.standard.set(d, forKey: storageKey("daily_task_history", for: currentUser.email))
//        }
//    }
//
//    // MARK: Boot Load
//
//    private func loadComplexData() {
//        let ud = UserDefaults.standard
//        if ud.string(forKey: "data_version") != "v3" {
//            let domain = Bundle.main.bundleIdentifier!
//            ud.removePersistentDomain(forName: domain)
//            ud.synchronize()
//            ud.set("v3", forKey: "data_version")
//            return
//        }
//        guard let email = ud.string(forKey: "user_email"), !email.isEmpty else { return }
//        let userKey = storageKey("current_user", for: email)
//        if let data = ud.data(forKey: userKey),
//           let user = try? JSONDecoder().decode(UserProfile.self, from: data) {
//            currentUser = user
//            loadUserData(for: email)
//            isLoggedIn = true
//        }
//    }
//
//    // MARK: Streak
//
//    // FIX #1: Write streak to per-user key, not the old global "current_streak" key.
//    // This guarantees each account maintains its own independent streak counter.
//    private func updateStreak() {
//        let calendar = Calendar.current
//        var streak = 0
//        var checkDate = calendar.startOfDay(for: Date())
//        while true {
//            if focusSessions.contains(where: { calendar.isDate($0.date, inSameDayAs: checkDate) }) {
//                streak += 1
//                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
//            } else { break }
//        }
//        if streak > currentStreak { isNewRecord = true }
//        currentStreak = streak
//        // FIX #1: per-user key only, no global key
//        if !currentUser.email.isEmpty {
//            UserDefaults.standard.set(streak, forKey: storageKey("current_streak", for: currentUser.email))
//        }
//    }
//}
//
//// MARK: - UserProfile
//
//struct UserProfile: Codable {
//    var name: String = ""
//    var email: String = ""
//    var skills: [String] = []
//    var institutions: [Institution] = []
//    var emails: [String] = []
//    var phone: String = ""
//    var avatarData: Data? = nil
//    var avatarColorHex: String = "7259B3"
//
//    // Resume sections
//    var workExperiences: [WorkExperienceEntry] = []
//    var projects: [ProjectEntry] = []
//    var awards: [AwardEntry] = []
//    var leadership: [LeadershipEntry] = []
//    var research: [ResearchEntry] = []
//    var volunteer: [VolunteerEntry] = []
//    var certifications: [CertificationEntry] = []
//    var publications: [PublicationEntry] = []
//    var extracurricular: [ExtracurricularEntry] = []
//    var languages: [LanguageEntry] = []
//
//    var avatarColor: Color { Color(hex: avatarColorHex) ?? AppTheme.primary }
//}
//
//// MARK: - Resume Entry Models
//// Bullet-based: Work, Project, Leadership, Research, Volunteer, Extracurricular
//// Note-based (single line): Award, Certification, Publication
//
//struct WorkExperienceEntry: Identifiable, Codable {
//    var id: UUID = UUID()
//    var company: String = ""
//    var role: String = ""
//    var location: String = ""
//    var startMonth: String = ""
//    var startYear: String = ""
//    var endMonth: String = ""
//    var endYear: String = ""
//    var isCurrent: Bool = false
//    var bullets: [String] = []
//}
//
//struct ProjectEntry: Identifiable, Codable {
//    var id: UUID = UUID()
//    var title: String = ""
//    var role: String = ""
//    var techStack: String = ""
//    var startMonth: String = ""
//    var startYear: String = ""
//    var endMonth: String = ""
//    var endYear: String = ""
//    var isOngoing: Bool = false
//    var link: String = ""
//    var bullets: [String] = []
//}
//
//struct AwardEntry: Identifiable, Codable {
//    var id: UUID = UUID()
//    var title: String = ""
//    var issuer: String = ""
//    var year: String = ""
//    var month: String = ""
//    var level: String = ""
//    var note: String = ""
//}
//
//struct LeadershipEntry: Identifiable, Codable {
//    var id: UUID = UUID()
//    var role: String = ""
//    var organization: String = ""
//    var location: String = ""
//    var startMonth: String = ""
//    var startYear: String = ""
//    var endMonth: String = ""
//    var endYear: String = ""
//    var isCurrent: Bool = false
//    var teamSize: String = ""
//    var bullets: [String] = []
//}
//
//struct ResearchEntry: Identifiable, Codable {
//    var id: UUID = UUID()
//    var title: String = ""
//    var institution: String = ""
//    var supervisor: String = ""
//    var startMonth: String = ""
//    var startYear: String = ""
//    var endMonth: String = ""
//    var endYear: String = ""
//    var isOngoing: Bool = false
//    var field: String = ""
//    var bullets: [String] = []
//}
//
//struct VolunteerEntry: Identifiable, Codable {
//    var id: UUID = UUID()
//    var role: String = ""
//    var organization: String = ""
//    var location: String = ""
//    var startMonth: String = ""
//    var startYear: String = ""
//    var endMonth: String = ""
//    var endYear: String = ""
//    var isCurrent: Bool = false
//    var hoursPerWeek: String = ""
//    var bullets: [String] = []
//}
//
//struct CertificationEntry: Identifiable, Codable {
//    var id: UUID = UUID()
//    var name: String = ""
//    var issuer: String = ""
//    var issueMonth: String = ""
//    var issueYear: String = ""
//    var expiryMonth: String = ""
//    var expiryYear: String = ""
//    var noExpiry: Bool = false
//    var credentialId: String = ""
//    var link: String = ""
//    var note: String = ""
//}
//
//struct PublicationEntry: Identifiable, Codable {
//    var id: UUID = UUID()
//    var title: String = ""
//    var authors: String = ""
//    var journal: String = ""
//    var year: String = ""
//    var month: String = ""
//    var doi: String = ""
//    var link: String = ""
//    var type: String = ""
//    var note: String = ""
//}
//
//struct ExtracurricularEntry: Identifiable, Codable {
//    var id: UUID = UUID()
//    var activityName: String = ""
//    var role: String = ""
//    var organization: String = ""
//    var startYear: String = ""
//    var endYear: String = ""
//    var isCurrent: Bool = false
//    var frequency: String = ""
//    var bullets: [String] = []
//}
//
//struct LanguageEntry: Identifiable, Codable {
//    var id: UUID = UUID()
//    var language: String = ""
//    var proficiency: String = "Conversational"
//    var certificate: String = ""
//}
//
//// MARK: - Color Extension
//
//extension Color {
//    init?(hex: String) {
//        var h = hex.trimmingCharacters(in: .alphanumerics.inverted)
//        if h.count == 6 { h = "FF" + h }
//        guard h.count == 8, let val = UInt64(h, radix: 16) else { return nil }
//        self.init(.sRGB,
//            red:   Double((val >> 16) & 0xFF) / 255,
//            green: Double((val >>  8) & 0xFF) / 255,
//            blue:  Double( val        & 0xFF) / 255,
//            opacity: Double((val >> 24) & 0xFF) / 255)
//    }
//}
//
//// MARK: - Institution
//
//enum InstitutionType: String, CaseIterable, Codable {
//    case university = "University"
//    case highSchool = "High School"
//    case other      = "Other"
//
//    var icon: String {
//        switch self {
//        case .university: return "building.columns.fill"
//        case .highSchool: return "graduationcap.fill"
//        case .other:      return "briefcase.fill"
//        }
//    }
//    var gradeOptions: [String] {
//        switch self {
//        case .university: return ["Freshman", "Sophomore", "Junior", "Senior", "Graduate"]
//        case .highSchool: return ["9th Grade", "10th Grade", "11th Grade", "12th Grade"]
//        case .other:      return ["Year 1", "Year 2", "Year 3", "Year 4", "Other"]
//        }
//    }
//}
//
//struct Institution: Identifiable, Codable {
//    let id: UUID
//    var type: InstitutionType
//    var icon: String
//    var title: String
//    var years: String
//    var startMonthIdx: Int
//    var startYear: Int
//    var endMonthIdx: Int
//    var endYear: Int
//    var major: String
//    var gpa: String
//    var grade: String
//    var transcriptData: Data?
//
//    private static let months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
//
//    static func buildYears(smi: Int, sy: Int, emi: Int, ey: Int) -> String {
//        let sm = months[smi]; let em = months[emi]
//        return sy == ey ? "\(sm) - \(em) \(sy)" : "\(sm) \(sy) - \(em) \(ey)"
//    }
//
//    init(id: UUID = UUID(), type: InstitutionType, title: String,
//         startMonthIdx: Int = 8, startYear: Int = Calendar.current.component(.year, from: Date()),
//         endMonthIdx: Int = 5, endYear: Int = Calendar.current.component(.year, from: Date()) + 4,
//         major: String = "", gpa: String = "", grade: String = "", transcriptData: Data? = nil) {
//        self.id = id; self.type = type; self.icon = type.icon; self.title = title
//        self.startMonthIdx = startMonthIdx; self.startYear = startYear
//        self.endMonthIdx = endMonthIdx; self.endYear = endYear
//        self.years = Institution.buildYears(smi: startMonthIdx, sy: startYear, emi: endMonthIdx, ey: endYear)
//        self.major = major; self.gpa = gpa
//        self.grade = grade.isEmpty ? (type.gradeOptions.first ?? "") : grade
//        self.transcriptData = transcriptData
//    }
//
//    init(id: UUID = UUID(), icon: String, title: String, years: String) {
//        self.id = id; self.type = .other; self.icon = icon; self.title = title; self.years = years
//        self.startMonthIdx = 0; self.startYear = 2020
//        self.endMonthIdx = 11; self.endYear = 2024
//        self.major = ""; self.gpa = ""; self.grade = ""; self.transcriptData = nil
//    }
//}
//
//// MARK: - Task Models
//
//enum TaskTimerMode: String, Codable {
//    case stopwatch
//    case countdown
//}
//
//struct TaskItem: Identifiable, Codable {
//    let id: UUID
//    var title: String
//    var isDone: Bool
//    var goalId: UUID?
//    var timerMode: TaskTimerMode
//    var targetSeconds: Int
//    var accumulatedSeconds: Int
//
//    init(id: UUID = UUID(), title: String, isDone: Bool, goalId: UUID? = nil,
//         timerMode: TaskTimerMode = .stopwatch, targetSeconds: Int = 0, accumulatedSeconds: Int = 0) {
//        self.id = id; self.title = title; self.isDone = isDone; self.goalId = goalId
//        self.timerMode = timerMode; self.targetSeconds = targetSeconds; self.accumulatedSeconds = accumulatedSeconds
//    }
//
//    var isCountdown: Bool { timerMode == .countdown }
//
//    var progressFraction: Double {
//        guard isCountdown && targetSeconds > 0 else { return 0 }
//        return min(1.0, Double(accumulatedSeconds) / Double(targetSeconds))
//    }
//
//    var displayTime: String {
//        let secs = accumulatedSeconds
//        let h = secs / 3600; let m = (secs % 3600) / 60; let s = secs % 60
//        if isCountdown {
//            let th = targetSeconds / 3600; let tm = (targetSeconds % 3600) / 60
//            let elapsed = h > 0 ? "\(h)h \(m)min" : "\(m)min\(s > 0 ? " \(s)s" : "")"
//            let target  = th > 0 ? "\(th)h \(tm)min" : "\(tm)min"
//            return "\(elapsed) / \(target)"
//        } else {
//            if secs == 0 { return "" }
//            return h > 0 ? "\(h)h \(m)min" : m > 0 ? "\(m)min" : "\(s)s"
//        }
//    }
//}
//
//struct GoalItem: Identifiable, Codable {
//    let id: UUID
//    var title: String
//    var isSelected: Bool
//    init(id: UUID = UUID(), title: String, isSelected: Bool = true) {
//        self.id = id; self.title = title; self.isSelected = isSelected
//    }
//}
//
//struct FocusSession: Identifiable, Codable {
//    let id: UUID
//    var duration: TimeInterval
//    var date: Date
//    init(id: UUID = UUID(), duration: TimeInterval, date: Date) {
//        self.id = id; self.duration = duration; self.date = date
//    }
//}
//
//struct LongTermPlan: Identifiable, Codable {
//    let id: UUID
//    var title: String
//    var dateRange: String
//    var description: String
//    var goalItems: [PlanGoalItem]
//    var startMonth: Int
//    var startYear: Int
//    var endMonth: Int
//    var endYear: Int
//    var completedCount: Int { goalItems.filter { $0.isDone }.count }
//    var totalCount: Int { goalItems.count }
//    init(id: UUID = UUID(), title: String, dateRange: String, description: String, goalItems: [PlanGoalItem],
//         startMonth: Int = 1, startYear: Int = 2026, endMonth: Int = 12, endYear: Int = 2026) {
//        self.id = id; self.title = title; self.dateRange = dateRange
//        self.description = description; self.goalItems = goalItems
//        self.startMonth = startMonth; self.startYear = startYear
//        self.endMonth = endMonth; self.endYear = endYear
//    }
//}
//
//struct PlanGoalItem: Identifiable, Codable {
//    let id: UUID
//    var title: String
//    var isDone: Bool
//    var targetMonths: [(month: Int, year: Int)]
//
//    enum CodingKeys: String, CodingKey { case id, title, isDone, targetMonthsData }
//
//    init(id: UUID = UUID(), title: String, isDone: Bool, targetMonths: [(month: Int, year: Int)] = []) {
//        self.id = id; self.title = title; self.isDone = isDone; self.targetMonths = targetMonths
//    }
//    init(from decoder: Decoder) throws {
//        let c = try decoder.container(keyedBy: CodingKeys.self)
//        id     = try c.decode(UUID.self,   forKey: .id)
//        title  = try c.decode(String.self, forKey: .title)
//        isDone = try c.decode(Bool.self,   forKey: .isDone)
//        let raw = try c.decodeIfPresent([[Int]].self, forKey: .targetMonthsData) ?? []
//        targetMonths = raw.compactMap { arr in arr.count == 2 ? (month: arr[0], year: arr[1]) : nil }
//    }
//    func encode(to encoder: Encoder) throws {
//        var c = encoder.container(keyedBy: CodingKeys.self)
//        try c.encode(id,    forKey: .id)
//        try c.encode(title, forKey: .title)
//        try c.encode(isDone, forKey: .isDone)
//        try c.encode(targetMonths.map { [$0.month, $0.year] }, forKey: .targetMonthsData)
//    }
//    var targetMonth: Int? { targetMonths.first?.month }
//    var targetYear:  Int? { targetMonths.first?.year }
//    mutating func toggleMonth(_ month: Int, _ year: Int) {
//        if let idx = targetMonths.firstIndex(where: { $0.month == month && $0.year == year }) {
//            targetMonths.remove(at: idx)
//        } else { targetMonths.append((month: month, year: year)) }
//    }
//    func hasMonth(_ month: Int, _ year: Int) -> Bool {
//        targetMonths.contains { $0.month == month && $0.year == year }
//    }
//}



import SwiftUI
import Combine

// MARK: - Central App State

class AppState: ObservableObject {

    // MARK: Auth
    @AppStorage("is_logged_in") var isLoggedIn: Bool = false

    // MARK: Settings (global — not per-user, intentional)
    @AppStorage("selected_theme_color") var selectedThemeColor: String = "Teal"
    @AppStorage("selected_bg_color")    var selectedBgColor: String    = "Mint"
    @AppStorage("selected_language")    var selectedLanguage: String   = "English"
    @AppStorage("cloud_sync_enabled")   var cloudSyncEnabled: Bool     = true
    @AppStorage("daily_target_hours")   var dailyTargetHours: Int      = 2

    // FIX #4: currentStreak is now fully per-user managed via loadUserData/saveUserData.
    // Removed @AppStorage("current_streak") to eliminate the global-key conflict.
    @Published var currentStreak: Int = 0

    // MARK: Focus routing
    @Published var focusTaskId: UUID? = nil

    // MARK: User
    @Published var currentUser: UserProfile = UserProfile() {
        didSet { if !isLoadingUserData { saveUser() } }
    }

    // MARK: Tasks
    @Published var tasks: [TaskItem] = [] {
        didSet { if !isLoadingUserData { saveTasks() } }
    }

    // MARK: Goals / Plans
    @Published var goals: [GoalItem] = [] {
        didSet { if !isLoadingUserData { saveGoals() } }
    }
    @Published var longTermPlans: [LongTermPlan] = [] {
        didSet { if !isLoadingUserData { savePlans() } }
    }

    // MARK: Focus Sessions
    // FIX #2: Full history kept in memory so hoursForDay() works for past months.
    // todayHours / todayMinutes already filter by date — no need to strip on load.
    @Published var focusSessions: [FocusSession] = [] {
        didSet { if !isLoadingUserData { saveSessions() } }
    }

    // MARK: Streak
    @Published var isNewRecord: Bool = false

    // MARK: Daily Reset
    @Published var lastResetDate: Date = Date.distantPast {
        didSet {
            if !isLoadingUserData, !currentUser.email.isEmpty {
                UserDefaults.standard.set(lastResetDate,
                    forKey: storageKey("last_reset_date", for: currentUser.email))
            }
        }
    }
    @Published var dailyTaskHistory: [String: [TaskItem]] = [:] {
        didSet { if !isLoadingUserData { saveHistory() } }
    }

    private var isLoadingUserData = false

    // MARK: Init
    init() { loadComplexData() }

    // MARK: Computed
    var completedTasksCount: Int { tasks.filter { $0.isDone }.count }
    var totalTasksCount: Int { tasks.count }

    var todayHours: Double {
        let today = Calendar.current.startOfDay(for: Date())
        return focusSessions
            .filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
            .reduce(0) { $0 + $1.duration } / 3600
    }
    var todayMinutes: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return Int(focusSessions
            .filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
            .reduce(0) { $0 + $1.duration } / 60)
    }

    var themeColor: Color {
        AppTheme.themeColors.first(where: { $0.name == selectedThemeColor })?.color ?? AppTheme.primary
    }
    var bgColor: Color {
        AppTheme.bgColors.first(where: { $0.name == selectedBgColor })?.color ?? AppTheme.bg
    }

    // MARK: Storage Keys
    // All per-user data is namespaced under "u:<email>:<key>" to guarantee isolation.
    private func storageKey(_ base: String, for email: String) -> String {
        "u:\(email):\(base)"
    }

    private func hashPassword(_ password: String, email: String) -> String {
        let salted = "bw_\(email.lowercased())_\(password)"
        var h: UInt64 = 14695981039346656037
        for byte in salted.utf8 { h ^= UInt64(byte); h = h &* 1099511628211 }
        return String(h, radix: 16)
    }

    // MARK: Auth

    func login(name: String, email: String, password: String) -> Bool {
        let ud = UserDefaults.standard
        let emailLow = email.lowercased().trimmingCharacters(in: .whitespaces)
        guard !emailLow.isEmpty, !password.isEmpty else { return false }
        let passKey = storageKey("password_hash", for: emailLow)
        guard let savedHash = ud.string(forKey: passKey) else { return false }
        guard hashPassword(password, email: emailLow) == savedHash else { return false }
        // Save any in-flight data for the previously logged-in user before switching
        if !currentUser.email.isEmpty { saveUserData(for: currentUser.email) }
        isLoadingUserData = true
        let userKey = storageKey("current_user", for: emailLow)
        if let data = ud.data(forKey: userKey),
           let savedUser = try? JSONDecoder().decode(UserProfile.self, from: data) {
            currentUser = savedUser
        }
        isLoadingUserData = false
        loadUserData(for: emailLow)
        ud.set(emailLow, forKey: "user_email")
        isLoggedIn = true
        return true
    }

    func register(name: String, email: String, password: String) -> Bool {
        let ud = UserDefaults.standard
        let emailLow = email.lowercased().trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty, !emailLow.isEmpty, password.count >= 6 else { return false }
        let passKey = storageKey("password_hash", for: emailLow)
        if ud.string(forKey: passKey) != nil { return false }  // already registered
        ud.set(hashPassword(password, email: emailLow), forKey: passKey)
        isLoadingUserData = true
        currentUser = UserProfile(name: name, email: emailLow, skills: [])
        tasks = []; goals = []; longTermPlans = []; focusSessions = []
        dailyTaskHistory = [:]; currentStreak = 0; lastResetDate = Date.distantPast
        isLoadingUserData = false
        ud.set(emailLow, forKey: "user_email")
        saveUserData(for: emailLow)
        isLoggedIn = true
        return true
    }

    func resetPassword(email: String, newPassword: String) -> Bool {
        let ud = UserDefaults.standard
        let emailLow = email.lowercased().trimmingCharacters(in: .whitespaces)
        guard !emailLow.isEmpty, newPassword.count >= 6 else { return false }
        let passKey = storageKey("password_hash", for: emailLow)
        guard ud.string(forKey: passKey) != nil else { return false }
        ud.set(hashPassword(newPassword, email: emailLow), forKey: passKey)
        return true
    }

    func logout() {
        if !currentUser.email.isEmpty { saveUserData(for: currentUser.email) }
        // Wipe all in-memory state so the next login starts completely clean
        isLoadingUserData = true
        currentUser = UserProfile()
        tasks = []; goals = []; longTermPlans = []; focusSessions = []
        dailyTaskHistory = [:]; currentStreak = 0; lastResetDate = Date.distantPast
        isNewRecord = false; focusTaskId = nil
        isLoadingUserData = false
        UserDefaults.standard.removeObject(forKey: "user_email")
        isLoggedIn = false
    }

    func deleteAccount() {
        let emailLow = currentUser.email.lowercased().trimmingCharacters(in: .whitespaces)
        if !emailLow.isEmpty {
            let ud = UserDefaults.standard
            let prefix = "u:\(emailLow):"
            let allKeys = ud.dictionaryRepresentation().keys
            for key in allKeys where key.hasPrefix(prefix) {
                ud.removeObject(forKey: key)
            }
        }
        isLoadingUserData = true
        currentUser = UserProfile()
        tasks = []; goals = []; longTermPlans = []; focusSessions = []
        dailyTaskHistory = [:]; currentStreak = 0; lastResetDate = Date.distantPast
        isNewRecord = false; focusTaskId = nil
        isLoadingUserData = false
        UserDefaults.standard.removeObject(forKey: "user_email")
        isLoggedIn = false
    }

    // MARK: Per-user Save / Load

    private func saveUserData(for email: String) {
        let ud = UserDefaults.standard
        let k = { [self] (base: String) in storageKey(base, for: email) }
        if let d = try? JSONEncoder().encode(currentUser)      { ud.set(d, forKey: k("current_user")) }
        if let d = try? JSONEncoder().encode(tasks)            { ud.set(d, forKey: k("tasks")) }
        if let d = try? JSONEncoder().encode(goals)            { ud.set(d, forKey: k("goals")) }
        if let d = try? JSONEncoder().encode(longTermPlans)    { ud.set(d, forKey: k("long_term_plans")) }
        if let d = try? JSONEncoder().encode(focusSessions)    { ud.set(d, forKey: k("focus_sessions")) }
        if let d = try? JSONEncoder().encode(dailyTaskHistory) { ud.set(d, forKey: k("daily_task_history")) }
        ud.set(lastResetDate, forKey: k("last_reset_date"))
        ud.set(currentStreak, forKey: k("current_streak"))
    }

    private func loadUserData(for email: String) {
        isLoadingUserData = true
        defer { isLoadingUserData = false }
        let ud = UserDefaults.standard
        let k = { [self] (base: String) in storageKey(base, for: email) }

        tasks = (ud.data(forKey: k("tasks")).flatMap { try? JSONDecoder().decode([TaskItem].self, from: $0) }) ?? []
        goals = (ud.data(forKey: k("goals")).flatMap { try? JSONDecoder().decode([GoalItem].self, from: $0) }) ?? []
        longTermPlans = (ud.data(forKey: k("long_term_plans")).flatMap { try? JSONDecoder().decode([LongTermPlan].self, from: $0) }) ?? []

        // FIX #2: Load ALL focus sessions (not just today's).
        // todayHours/todayMinutes filter in-place; hoursForDay() needs the full history.
        focusSessions = (ud.data(forKey: k("focus_sessions")).flatMap { try? JSONDecoder().decode([FocusSession].self, from: $0) }) ?? []

        // Load daily task history — no hard date cutoff, keep everything stored
        dailyTaskHistory = (ud.data(forKey: k("daily_task_history")).flatMap { try? JSONDecoder().decode([String: [TaskItem]].self, from: $0) }) ?? [:]

        lastResetDate = (ud.object(forKey: k("last_reset_date")) as? Date) ?? Date.distantPast

        // FIX #1 (partial): Read streak from per-user key only
        currentStreak = ud.integer(forKey: k("current_streak"))
    }

    // MARK: Task Operations

    func addTask(_ title: String, goalId: UUID? = nil) {
        tasks.append(TaskItem(title: title, isDone: false, goalId: goalId))
    }
    func addTask(_ title: String, goalId: UUID? = nil, timerMode: TaskTimerMode, targetSeconds: Int) {
        tasks.append(TaskItem(title: title, isDone: false, goalId: goalId,
                              timerMode: timerMode, targetSeconds: targetSeconds))
    }
    func deleteTask(_ task: TaskItem) { tasks.removeAll { $0.id == task.id } }
    func toggleTask(_ task: TaskItem) {
        if let idx = tasks.firstIndex(where: { $0.id == task.id }) { tasks[idx].isDone.toggle() }
    }
    func moveTask(from source: IndexSet, to destination: Int) {
        tasks.move(fromOffsets: source, toOffset: destination)
    }
    func addTime(_ seconds: Int, to taskId: UUID) {
        guard let idx = tasks.firstIndex(where: { $0.id == taskId }) else { return }
        tasks[idx].accumulatedSeconds += seconds
        if tasks[idx].isCountdown && tasks[idx].accumulatedSeconds >= tasks[idx].targetSeconds {
            tasks[idx].isDone = true
        }
    }

    // MARK: Daily Reset

    // FIX #3: Archive key uses lastReset directly (not yesterday), so tasks are always
    // filed under the correct date even when the user skips multiple days.
    func checkDailyReset() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastReset = calendar.startOfDay(for: lastResetDate)
        guard today > lastReset else { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        // Archive tasks under the date they were active (lastReset), not yesterday
        if lastResetDate != Date.distantPast && !tasks.isEmpty {
            dailyTaskHistory[formatter.string(from: lastReset)] = tasks
        }

        // Reset task completion & accumulated time; preserve title/id/goal/timer settings
        tasks = tasks.map {
            TaskItem(id: $0.id, title: $0.title, isDone: false, goalId: $0.goalId,
                     timerMode: $0.timerMode, targetSeconds: $0.targetSeconds)
        }

        lastResetDate = Date()
        if !currentUser.email.isEmpty {
            UserDefaults.standard.set(lastResetDate,
                forKey: storageKey("last_reset_date", for: currentUser.email))
            saveHistory()
        }
    }

    // MARK: Focus Sessions

    func recordSession(duration: TimeInterval) {
        focusSessions.append(FocusSession(duration: duration, date: Date()))
        updateStreak()
    }

    // FIX #5: resetStatistics also persists the cleared streak to the per-user key
    // so it isn't restored from disk on the next app launch.
    func resetStatistics() {
        focusSessions = []
        currentStreak = 0
        isNewRecord = false
        if !currentUser.email.isEmpty {
            UserDefaults.standard.set(0, forKey: storageKey("current_streak", for: currentUser.email))
        }
    }

    func resetAllAccountData() {
        tasks = []; goals = []; longTermPlans = []; focusSessions = []
        dailyTaskHistory = [:]; currentStreak = 0; isNewRecord = false; lastResetDate = Date.distantPast
        if !currentUser.email.isEmpty { saveUserData(for: currentUser.email) }
    }

    // MARK: Goals / Plans

    func addGoal(_ title: String) { goals.append(GoalItem(title: title)) }
    func deleteGoal(_ goal: GoalItem) { goals.removeAll { $0.id == goal.id } }
    func addPlan(_ plan: LongTermPlan) { longTermPlans.append(plan) }
    func deletePlan(_ plan: LongTermPlan) { longTermPlans.removeAll { $0.id == plan.id } }

    // MARK: Calendar

    func hoursForDay(_ day: Int, month: Int, year: Int) -> Double {
        let calendar = Calendar.current
        return focusSessions.filter { session in
            let comps = calendar.dateComponents([.day, .month, .year], from: session.date)
            return comps.day == day && comps.month == month && comps.year == year
        }.reduce(0) { $0 + $1.duration } / 3600
    }

    // MARK: Private Save Helpers
    // Each saves only its own slice — called by didSet observers for incremental writes.

    private func saveUser() {
        guard !currentUser.email.isEmpty else { return }
        if let d = try? JSONEncoder().encode(currentUser) {
            UserDefaults.standard.set(d, forKey: storageKey("current_user", for: currentUser.email))
        }
    }
    private func saveTasks() {
        guard !currentUser.email.isEmpty else { return }
        if let d = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(d, forKey: storageKey("tasks", for: currentUser.email))
        }
    }
    private func saveGoals() {
        guard !currentUser.email.isEmpty else { return }
        if let d = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(d, forKey: storageKey("goals", for: currentUser.email))
        }
    }
    private func savePlans() {
        guard !currentUser.email.isEmpty else { return }
        if let d = try? JSONEncoder().encode(longTermPlans) {
            UserDefaults.standard.set(d, forKey: storageKey("long_term_plans", for: currentUser.email))
        }
    }
    private func saveSessions() {
        guard !currentUser.email.isEmpty else { return }
        if let d = try? JSONEncoder().encode(focusSessions) {
            UserDefaults.standard.set(d, forKey: storageKey("focus_sessions", for: currentUser.email))
        }
    }
    private func saveHistory() {
        guard !currentUser.email.isEmpty else { return }
        if let d = try? JSONEncoder().encode(dailyTaskHistory) {
            UserDefaults.standard.set(d, forKey: storageKey("daily_task_history", for: currentUser.email))
        }
    }

    // MARK: Boot Load

    private func loadComplexData() {
        let ud = UserDefaults.standard
        if ud.string(forKey: "data_version") != "v3" {
            let domain = Bundle.main.bundleIdentifier!
            ud.removePersistentDomain(forName: domain)
            ud.synchronize()
            ud.set("v3", forKey: "data_version")
            return
        }
        guard let email = ud.string(forKey: "user_email"), !email.isEmpty else { return }
        let userKey = storageKey("current_user", for: email)
        if let data = ud.data(forKey: userKey),
           let user = try? JSONDecoder().decode(UserProfile.self, from: data) {
            currentUser = user
            loadUserData(for: email)
            isLoggedIn = true
        }
    }

    // MARK: Streak

    // FIX #1: Write streak to per-user key, not the old global "current_streak" key.
    // This guarantees each account maintains its own independent streak counter.
    private func updateStreak() {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())
        while true {
            if focusSessions.contains(where: { calendar.isDate($0.date, inSameDayAs: checkDate) }) {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else { break }
        }
        if streak > currentStreak { isNewRecord = true }
        currentStreak = streak
        // FIX #1: per-user key only, no global key
        if !currentUser.email.isEmpty {
            UserDefaults.standard.set(streak, forKey: storageKey("current_streak", for: currentUser.email))
        }
    }
}

// MARK: - UserProfile

struct UserProfile: Codable {
    var name: String = ""
    var email: String = ""
    var skills: [String] = []
    var institutions: [Institution] = []
    var emails: [String] = []
    var phone: String = ""
    var avatarData: Data? = nil
    var avatarColorHex: String = "7259B3"

    // Resume sections
    var workExperiences: [WorkExperienceEntry] = []
    var projects: [ProjectEntry] = []
    var awards: [AwardEntry] = []
    var leadership: [LeadershipEntry] = []
    var research: [ResearchEntry] = []
    var volunteer: [VolunteerEntry] = []
    var certifications: [CertificationEntry] = []
    var publications: [PublicationEntry] = []
    var extracurricular: [ExtracurricularEntry] = []
    var languages: [LanguageEntry] = []

    var avatarColor: Color { Color(hex: avatarColorHex) ?? AppTheme.primary }
}

// MARK: - Resume Entry Models
// Bullet-based: Work, Project, Leadership, Research, Volunteer, Extracurricular
// Note-based (single line): Award, Certification, Publication

struct WorkExperienceEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var company: String = ""
    var role: String = ""
    var location: String = ""
    var startMonth: String = ""
    var startYear: String = ""
    var endMonth: String = ""
    var endYear: String = ""
    var isCurrent: Bool = false
    var bullets: [String] = []
}

struct ProjectEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String = ""
    var role: String = ""
    var techStack: String = ""
    var startMonth: String = ""
    var startYear: String = ""
    var endMonth: String = ""
    var endYear: String = ""
    var isOngoing: Bool = false
    var link: String = ""
    var bullets: [String] = []
}

struct AwardEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String = ""
    var issuer: String = ""
    var year: String = ""
    var month: String = ""
    var level: String = ""
    var note: String = ""
}

struct LeadershipEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var role: String = ""
    var organization: String = ""
    var location: String = ""
    var startMonth: String = ""
    var startYear: String = ""
    var endMonth: String = ""
    var endYear: String = ""
    var isCurrent: Bool = false
    var teamSize: String = ""
    var bullets: [String] = []
}

struct ResearchEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String = ""
    var institution: String = ""
    var supervisor: String = ""
    var startMonth: String = ""
    var startYear: String = ""
    var endMonth: String = ""
    var endYear: String = ""
    var isOngoing: Bool = false
    var field: String = ""
    var bullets: [String] = []
}

struct VolunteerEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var role: String = ""
    var organization: String = ""
    var location: String = ""
    var startMonth: String = ""
    var startYear: String = ""
    var endMonth: String = ""
    var endYear: String = ""
    var isCurrent: Bool = false
    var hoursPerWeek: String = ""
    var bullets: [String] = []
}

struct CertificationEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String = ""
    var issuer: String = ""
    var issueMonth: String = ""
    var issueYear: String = ""
    var expiryMonth: String = ""
    var expiryYear: String = ""
    var noExpiry: Bool = false
    var credentialId: String = ""
    var link: String = ""
    var note: String = ""
}

struct PublicationEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String = ""
    var authors: String = ""
    var journal: String = ""
    var year: String = ""
    var month: String = ""
    var doi: String = ""
    var link: String = ""
    var type: String = ""
    var note: String = ""
}

struct ExtracurricularEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var activityName: String = ""
    var role: String = ""
    var organization: String = ""
    var startYear: String = ""
    var endYear: String = ""
    var isCurrent: Bool = false
    var frequency: String = ""
    var bullets: [String] = []
}

struct LanguageEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var language: String = ""
    var proficiency: String = "Conversational"
    var certificate: String = ""
}

// MARK: - Color Extension

extension Color {
    init?(hex: String) {
        var h = hex.trimmingCharacters(in: .alphanumerics.inverted)
        if h.count == 6 { h = "FF" + h }
        guard h.count == 8, let val = UInt64(h, radix: 16) else { return nil }
        self.init(.sRGB,
            red:   Double((val >> 16) & 0xFF) / 255,
            green: Double((val >>  8) & 0xFF) / 255,
            blue:  Double( val        & 0xFF) / 255,
            opacity: Double((val >> 24) & 0xFF) / 255)
    }
}

// MARK: - Institution

enum InstitutionType: String, CaseIterable, Codable {
    case university = "University"
    case highSchool = "High School"
    case other      = "Other"

    var icon: String {
        switch self {
        case .university: return "building.columns.fill"
        case .highSchool: return "graduationcap.fill"
        case .other:      return "briefcase.fill"
        }
    }
    var gradeOptions: [String] {
        switch self {
        case .university: return ["Freshman", "Sophomore", "Junior", "Senior", "Graduate"]
        case .highSchool: return ["9th Grade", "10th Grade", "11th Grade", "12th Grade"]
        case .other:      return ["Year 1", "Year 2", "Year 3", "Year 4", "Other"]
        }
    }
}

struct Institution: Identifiable, Codable {
    let id: UUID
    var type: InstitutionType
    var icon: String
    var title: String
    var years: String
    var startMonthIdx: Int
    var startYear: Int
    var endMonthIdx: Int
    var endYear: Int
    var major: String
    var gpa: String
    var grade: String
    var transcriptData: Data?

    private static let months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]

    static func buildYears(smi: Int, sy: Int, emi: Int, ey: Int) -> String {
        let sm = months[smi]; let em = months[emi]
        return sy == ey ? "\(sm) - \(em) \(sy)" : "\(sm) \(sy) - \(em) \(ey)"
    }

    init(id: UUID = UUID(), type: InstitutionType, title: String,
         startMonthIdx: Int = 8, startYear: Int = Calendar.current.component(.year, from: Date()),
         endMonthIdx: Int = 5, endYear: Int = Calendar.current.component(.year, from: Date()) + 4,
         major: String = "", gpa: String = "", grade: String = "", transcriptData: Data? = nil) {
        self.id = id; self.type = type; self.icon = type.icon; self.title = title
        self.startMonthIdx = startMonthIdx; self.startYear = startYear
        self.endMonthIdx = endMonthIdx; self.endYear = endYear
        self.years = Institution.buildYears(smi: startMonthIdx, sy: startYear, emi: endMonthIdx, ey: endYear)
        self.major = major; self.gpa = gpa
        self.grade = grade.isEmpty ? (type.gradeOptions.first ?? "") : grade
        self.transcriptData = transcriptData
    }

    init(id: UUID = UUID(), icon: String, title: String, years: String) {
        self.id = id; self.type = .other; self.icon = icon; self.title = title; self.years = years
        self.startMonthIdx = 0; self.startYear = 2020
        self.endMonthIdx = 11; self.endYear = 2024
        self.major = ""; self.gpa = ""; self.grade = ""; self.transcriptData = nil
    }
}

// MARK: - Task Models

enum TaskTimerMode: String, Codable {
    case stopwatch
    case countdown
}

struct TaskItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var isDone: Bool
    var goalId: UUID?
    var timerMode: TaskTimerMode
    var targetSeconds: Int
    var accumulatedSeconds: Int

    init(id: UUID = UUID(), title: String, isDone: Bool, goalId: UUID? = nil,
         timerMode: TaskTimerMode = .stopwatch, targetSeconds: Int = 0, accumulatedSeconds: Int = 0) {
        self.id = id; self.title = title; self.isDone = isDone; self.goalId = goalId
        self.timerMode = timerMode; self.targetSeconds = targetSeconds; self.accumulatedSeconds = accumulatedSeconds
    }

    var isCountdown: Bool { timerMode == .countdown }

    var progressFraction: Double {
        guard isCountdown && targetSeconds > 0 else { return 0 }
        return min(1.0, Double(accumulatedSeconds) / Double(targetSeconds))
    }

    var displayTime: String {
        let secs = accumulatedSeconds
        let h = secs / 3600; let m = (secs % 3600) / 60; let s = secs % 60
        if isCountdown {
            let th = targetSeconds / 3600; let tm = (targetSeconds % 3600) / 60
            let elapsed = h > 0 ? "\(h)h \(m)min" : "\(m)min\(s > 0 ? " \(s)s" : "")"
            let target  = th > 0 ? "\(th)h \(tm)min" : "\(tm)min"
            return "\(elapsed) / \(target)"
        } else {
            if secs == 0 { return "" }
            return h > 0 ? "\(h)h \(m)min" : m > 0 ? "\(m)min" : "\(s)s"
        }
    }
}

struct GoalItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var isSelected: Bool
    init(id: UUID = UUID(), title: String, isSelected: Bool = true) {
        self.id = id; self.title = title; self.isSelected = isSelected
    }
}

struct FocusSession: Identifiable, Codable {
    let id: UUID
    var duration: TimeInterval
    var date: Date
    init(id: UUID = UUID(), duration: TimeInterval, date: Date) {
        self.id = id; self.duration = duration; self.date = date
    }
}

struct LongTermPlan: Identifiable, Codable {
    let id: UUID
    var title: String
    var dateRange: String
    var description: String
    var goalItems: [PlanGoalItem]
    var startMonth: Int
    var startYear: Int
    var endMonth: Int
    var endYear: Int
    var completedCount: Int { goalItems.filter { $0.isDone }.count }
    var totalCount: Int { goalItems.count }
    init(id: UUID = UUID(), title: String, dateRange: String, description: String, goalItems: [PlanGoalItem],
         startMonth: Int = 1, startYear: Int = 2026, endMonth: Int = 12, endYear: Int = 2026) {
        self.id = id; self.title = title; self.dateRange = dateRange
        self.description = description; self.goalItems = goalItems
        self.startMonth = startMonth; self.startYear = startYear
        self.endMonth = endMonth; self.endYear = endYear
    }
}

struct PlanGoalItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var isDone: Bool
    var targetMonths: [(month: Int, year: Int)]

    enum CodingKeys: String, CodingKey { case id, title, isDone, targetMonthsData }

    init(id: UUID = UUID(), title: String, isDone: Bool, targetMonths: [(month: Int, year: Int)] = []) {
        self.id = id; self.title = title; self.isDone = isDone; self.targetMonths = targetMonths
    }
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id     = try c.decode(UUID.self,   forKey: .id)
        title  = try c.decode(String.self, forKey: .title)
        isDone = try c.decode(Bool.self,   forKey: .isDone)
        let raw = try c.decodeIfPresent([[Int]].self, forKey: .targetMonthsData) ?? []
        targetMonths = raw.compactMap { arr in arr.count == 2 ? (month: arr[0], year: arr[1]) : nil }
    }
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id,    forKey: .id)
        try c.encode(title, forKey: .title)
        try c.encode(isDone, forKey: .isDone)
        try c.encode(targetMonths.map { [$0.month, $0.year] }, forKey: .targetMonthsData)
    }
    var targetMonth: Int? { targetMonths.first?.month }
    var targetYear:  Int? { targetMonths.first?.year }
    mutating func toggleMonth(_ month: Int, _ year: Int) {
        if let idx = targetMonths.firstIndex(where: { $0.month == month && $0.year == year }) {
            targetMonths.remove(at: idx)
        } else { targetMonths.append((month: month, year: year)) }
    }
    func hasMonth(_ month: Int, _ year: Int) -> Bool {
        targetMonths.contains { $0.month == month && $0.year == year }
    }
}
