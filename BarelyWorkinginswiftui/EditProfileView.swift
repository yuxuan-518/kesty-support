
import SwiftUI
import PhotosUI
import UIKit

// MARK: - Resume Section Type

enum ResumeSectionType: String, CaseIterable, Identifiable {
    case work          = "Work Experience"
    case project       = "Projects"
    case leadership    = "Leadership"
    case research      = "Research"
    case extracurricular = "Extracurricular"
    case volunteer     = "Volunteer"
    case award         = "Awards & Honors"
    case certification = "Certifications"
    case publication   = "Publications"
    case language      = "Languages"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .work:           return "briefcase.fill"
        case .project:        return "hammer.fill"
        case .leadership:     return "person.3.fill"
        case .research:       return "magnifyingglass"
        case .extracurricular: return "star.fill"
        case .volunteer:      return "heart.fill"
        case .award:          return "trophy.fill"
        case .certification:  return "checkmark.seal.fill"
        case .publication:    return "book.fill"
        case .language:       return "globe"
        }
    }
}

// MARK: - Bullet Input Section

struct BulletInputSection: View {
    let placeholder: String
    @Binding var bullets: [String]
    let themeColor: Color
    @State private var newBullet = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("BULLET POINTS")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(AppTheme.textSecondary)

            ForEach(bullets.indices, id: \.self) { i in
                HStack(alignment: .top, spacing: 10) {
                    Text("•").font(.system(size: 16, weight: .bold))
                        .foregroundColor(themeColor).frame(width: 14).padding(.top, 1)
                    Text(bullets[i]).font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Button { bullets.remove(at: i) } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16)).foregroundColor(Color.red.opacity(0.55))
                    }.buttonStyle(.plain)
                }
                .padding(.horizontal, 12).padding(.vertical, 9)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(white: 1.0, opacity: 0.65)))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(white: 0.0, opacity: 0.07), lineWidth: 1))
            }

            HStack(spacing: 8) {
                Text("•").font(.system(size: 16, weight: .bold))
                    .foregroundColor(themeColor.opacity(0.35)).frame(width: 14)
                TextField(placeholder, text: $newBullet)
                    .font(.system(size: 14)).foregroundColor(AppTheme.textPrimary)
                    .submitLabel(.done).onSubmit { commit() }
                Button("Add") { commit() }
                    .font(.system(size: 13, weight: .bold)).foregroundColor(themeColor)
            }
            .padding(.horizontal, 12).padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(white: 1.0, opacity: 0.75)))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.08), lineWidth: 1))

            if bullets.isEmpty {
                Text("Tip: Start with a strong verb — Led, Built, Increased…")
                    .font(.system(size: 11)).foregroundColor(AppTheme.textSecondary.opacity(0.6))
                    .padding(.top, 2)
            }
        }
    }
    private func commit() {
        let t = newBullet.trimmingCharacters(in: .whitespaces)
        guard !t.isEmpty else { return }
        bullets.append(t); newBullet = ""
    }
}

// MARK: - Edit Profile View

struct EditProfileView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var phone: String = ""
    @State private var newSkill: String = ""
    @State private var showAddSkill = false
    @State private var showAddInstitution = false
    @State private var showAddEmail = false
    @State private var newEmail = ""

    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var avatarImage: UIImage? = nil
    @State private var showAvatarSheet = false
    @State private var showCamera = false
    @State private var showPhotoLibrary = false

    // Section picker
    @State private var showAddSection = false
    @State private var activeSections: [ResumeSectionType] = []

    // Sheet states
    @State private var showAddWork = false
    @State private var showAddProject = false
    @State private var showAddAward = false
    @State private var showAddLeadership = false
    @State private var showAddResearch = false
    @State private var showAddVolunteer = false
    @State private var showAddCertification = false
    @State private var showAddPublication = false
    @State private var showAddExtracurricular = false
    @State private var showAddLanguage = false

    var availableSections: [ResumeSectionType] {
        ResumeSectionType.allCases.filter { !activeSections.contains($0) }
    }

    var body: some View {
        ZStack {
            appState.bgColor.ignoresSafeArea()
            LinearGradient(
                colors: [appState.themeColor.opacity(0.15), Color.clear, appState.themeColor.opacity(0.10)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ).ignoresSafeArea()

            VStack(spacing: 0) {
                navBar
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        avatarSection
                        nameSection
                        studyHistorySection
                        emailSection
                        skillsSection

                        // Active resume sections
                        if !activeSections.isEmpty {
                            HStack {
                                Rectangle().fill(appState.themeColor.opacity(0.2)).frame(height: 1)
                                Text("RESUME").font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(appState.themeColor.opacity(0.7)).padding(.horizontal, 8)
                                Rectangle().fill(appState.themeColor.opacity(0.2)).frame(height: 1)
                            }.padding(.top, 4)

                            ForEach(activeSections, id: \.self) { section in
                                resumeSectionView(for: section)
                            }
                        }

                        // Add Section button
                        if !availableSections.isEmpty {
                            Button { showAddSection = true } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(appState.themeColor)
                                    Text("Add Resume Section")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(appState.themeColor)
                                    Spacer()
                                }
                                .padding(.vertical, 14).padding(.horizontal, 16)
                                .background(RoundedRectangle(cornerRadius: 16).fill(appState.themeColor.opacity(0.08)))
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(appState.themeColor.opacity(0.2), lineWidth: 1.5))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16).padding(.bottom, 110)
                }
                bottomButtons
            }
        }
        .navigationBarHidden(true)
        .onAppear { loadProfile() }
        .confirmationDialog("Choose Photo Source", isPresented: $showAvatarSheet, titleVisibility: .visible) {
            Button("Photo Library") { showPhotoLibrary = true }
            if UIImagePickerController.isSourceTypeAvailable(.camera) { Button("Take Photo") { showCamera = true } }
            Button("Cancel", role: .cancel) {}
        }
        .photosPicker(isPresented: $showPhotoLibrary, selection: $selectedPhoto, matching: .images)
        .fullScreenCover(isPresented: $showCamera) { CameraView(image: $avatarImage).ignoresSafeArea() }
        .onChange(of: selectedPhoto) { _ in
            guard let item = selectedPhoto else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self), let img = UIImage(data: data) {
                    await MainActor.run { avatarImage = img }
                }
            }
        }
        // Section picker sheet
        .sheet(isPresented: $showAddSection) {
            AddSectionPickerSheet(available: availableSections, themeColor: appState.themeColor, bgColor: appState.bgColor) { selected in
                activeSections.append(selected)
            }
        }
        .sheet(isPresented: $showAddInstitution) {
            AddInstitutionSheet { inst in appState.currentUser.institutions.append(inst) }.environmentObject(appState)
        }
        .sheet(isPresented: $showAddWork) {
            AddWorkSheet { entry in appState.currentUser.workExperiences.append(entry) }.environmentObject(appState)
        }
        .sheet(isPresented: $showAddProject) {
            AddProjectSheet { entry in appState.currentUser.projects.append(entry) }.environmentObject(appState)
        }
        .sheet(isPresented: $showAddAward) {
            AddAwardSheet { entry in appState.currentUser.awards.append(entry) }.environmentObject(appState)
        }
        .sheet(isPresented: $showAddLeadership) {
            AddLeadershipSheet { entry in appState.currentUser.leadership.append(entry) }.environmentObject(appState)
        }
        .sheet(isPresented: $showAddResearch) {
            AddResearchSheet { entry in appState.currentUser.research.append(entry) }.environmentObject(appState)
        }
        .sheet(isPresented: $showAddVolunteer) {
            AddVolunteerSheet { entry in appState.currentUser.volunteer.append(entry) }.environmentObject(appState)
        }
        .sheet(isPresented: $showAddCertification) {
            AddCertificationSheet { entry in appState.currentUser.certifications.append(entry) }.environmentObject(appState)
        }
        .sheet(isPresented: $showAddPublication) {
            AddPublicationSheet { entry in appState.currentUser.publications.append(entry) }.environmentObject(appState)
        }
        .sheet(isPresented: $showAddExtracurricular) {
            AddExtracurricularSheet { entry in appState.currentUser.extracurricular.append(entry) }.environmentObject(appState)
        }
        .sheet(isPresented: $showAddLanguage) {
            AddLanguageSheet { entry in appState.currentUser.languages.append(entry) }.environmentObject(appState)
        }
    }

    // MARK: - Section Router
    @ViewBuilder
    private func resumeSectionView(for section: ResumeSectionType) -> some View {
        switch section {
        case .work:
            resumeSection(title: section.rawValue, icon: section.icon,
                entries: appState.currentUser.workExperiences,
                onAdd: { showAddWork = true },
                onDelete: { id in appState.currentUser.workExperiences.removeAll { $0.id == id } },
                onRemoveSection: { activeSections.removeAll { $0 == section } }
            ) { entry in
                ResumeEntryRow(title: entry.role.isEmpty ? entry.company : entry.role,
                    subtitle: entry.role.isEmpty ? nil : entry.company,
                    period: formatPeriod(entry.startMonth, entry.startYear, entry.endMonth, entry.endYear, entry.isCurrent),
                    tags: entry.location.isEmpty ? [] : [entry.location],
                    bullets: entry.bullets, themeColor: appState.themeColor)
            }
        case .project:
            resumeSection(title: section.rawValue, icon: section.icon,
                entries: appState.currentUser.projects,
                onAdd: { showAddProject = true },
                onDelete: { id in appState.currentUser.projects.removeAll { $0.id == id } },
                onRemoveSection: { activeSections.removeAll { $0 == section } }
            ) { entry in
                ResumeEntryRow(title: entry.title,
                    subtitle: entry.role.isEmpty ? nil : entry.role,
                    period: formatPeriod(entry.startMonth, entry.startYear, entry.endMonth, entry.endYear, entry.isOngoing),
                    tags: entry.techStack.isEmpty ? [] : entry.techStack.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) },
                    bullets: entry.bullets, themeColor: appState.themeColor)
            }
        case .leadership:
            resumeSection(title: section.rawValue, icon: section.icon,
                entries: appState.currentUser.leadership,
                onAdd: { showAddLeadership = true },
                onDelete: { id in appState.currentUser.leadership.removeAll { $0.id == id } },
                onRemoveSection: { activeSections.removeAll { $0 == section } }
            ) { entry in
                ResumeEntryRow(title: entry.role, subtitle: entry.organization,
                    period: formatPeriod(entry.startMonth, entry.startYear, entry.endMonth, entry.endYear, entry.isCurrent),
                    tags: entry.location.isEmpty ? [] : [entry.location],
                    bullets: entry.bullets, themeColor: appState.themeColor)
            }
        case .research:
            resumeSection(title: section.rawValue, icon: section.icon,
                entries: appState.currentUser.research,
                onAdd: { showAddResearch = true },
                onDelete: { id in appState.currentUser.research.removeAll { $0.id == id } },
                onRemoveSection: { activeSections.removeAll { $0 == section } }
            ) { entry in
                ResumeEntryRow(title: entry.title,
                    subtitle: entry.institution.isEmpty ? nil : entry.institution,
                    period: formatPeriod(entry.startMonth, entry.startYear, entry.endMonth, entry.endYear, entry.isOngoing),
                    tags: entry.field.isEmpty ? [] : [entry.field],
                    bullets: entry.bullets, themeColor: appState.themeColor)
            }
        case .extracurricular:
            resumeSection(title: section.rawValue, icon: section.icon,
                entries: appState.currentUser.extracurricular,
                onAdd: { showAddExtracurricular = true },
                onDelete: { id in appState.currentUser.extracurricular.removeAll { $0.id == id } },
                onRemoveSection: { activeSections.removeAll { $0 == section } }
            ) { entry in
                ResumeEntryRow(title: entry.activityName,
                    subtitle: entry.role.isEmpty ? nil : entry.role,
                    period: [entry.startYear, entry.isCurrent ? "Present" : entry.endYear].filter { !$0.isEmpty }.joined(separator: " – "),
                    tags: entry.frequency.isEmpty ? [] : [entry.frequency],
                    bullets: entry.bullets, themeColor: appState.themeColor)
            }
        case .volunteer:
            resumeSection(title: section.rawValue, icon: section.icon,
                entries: appState.currentUser.volunteer,
                onAdd: { showAddVolunteer = true },
                onDelete: { id in appState.currentUser.volunteer.removeAll { $0.id == id } },
                onRemoveSection: { activeSections.removeAll { $0 == section } }
            ) { entry in
                ResumeEntryRow(title: entry.role, subtitle: entry.organization,
                    period: formatPeriod(entry.startMonth, entry.startYear, entry.endMonth, entry.endYear, entry.isCurrent),
                    tags: entry.location.isEmpty ? [] : [entry.location],
                    bullets: entry.bullets, themeColor: appState.themeColor)
            }
        case .award:
            resumeSection(title: section.rawValue, icon: section.icon,
                entries: appState.currentUser.awards,
                onAdd: { showAddAward = true },
                onDelete: { id in appState.currentUser.awards.removeAll { $0.id == id } },
                onRemoveSection: { activeSections.removeAll { $0 == section } }
            ) { entry in
                ResumeEntryRow(title: entry.title,
                    subtitle: entry.issuer.isEmpty ? nil : entry.issuer,
                    period: [entry.month, entry.year].filter { !$0.isEmpty }.joined(separator: " "),
                    tags: entry.level.isEmpty ? [] : [entry.level],
                    note: entry.note, themeColor: appState.themeColor)
            }
        case .certification:
            resumeSection(title: section.rawValue, icon: section.icon,
                entries: appState.currentUser.certifications,
                onAdd: { showAddCertification = true },
                onDelete: { id in appState.currentUser.certifications.removeAll { $0.id == id } },
                onRemoveSection: { activeSections.removeAll { $0 == section } }
            ) { entry in
                ResumeEntryRow(title: entry.name,
                    subtitle: entry.issuer.isEmpty ? nil : entry.issuer,
                    period: [entry.issueMonth, entry.issueYear].filter { !$0.isEmpty }.joined(separator: " "),
                    tags: entry.noExpiry ? ["No Expiry"] : [],
                    note: entry.note, themeColor: appState.themeColor)
            }
        case .publication:
            resumeSection(title: section.rawValue, icon: section.icon,
                entries: appState.currentUser.publications,
                onAdd: { showAddPublication = true },
                onDelete: { id in appState.currentUser.publications.removeAll { $0.id == id } },
                onRemoveSection: { activeSections.removeAll { $0 == section } }
            ) { entry in
                ResumeEntryRow(title: entry.title,
                    subtitle: entry.journal.isEmpty ? nil : entry.journal,
                    period: [entry.month, entry.year].filter { !$0.isEmpty }.joined(separator: " "),
                    tags: entry.type.isEmpty ? [] : [entry.type],
                    note: entry.note, themeColor: appState.themeColor)
            }
        case .language:
            resumeSection(title: section.rawValue, icon: section.icon,
                entries: appState.currentUser.languages,
                onAdd: { showAddLanguage = true },
                onDelete: { id in appState.currentUser.languages.removeAll { $0.id == id } },
                onRemoveSection: { activeSections.removeAll { $0 == section } }
            ) { entry in
                ResumeEntryRow(title: entry.language, subtitle: nil, period: "",
                    tags: [entry.proficiency] + (entry.certificate.isEmpty ? [] : [entry.certificate]),
                    themeColor: appState.themeColor)
            }
        }
    }

    // MARK: - Nav Bar
    private var navBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left").font(.system(size: 18, weight: .semibold)).foregroundStyle(appState.themeColor)
            }
            Spacer()
            Text("Edit Profile").font(.system(size: 18, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark").font(.system(size: 18, weight: .semibold)).foregroundStyle(appState.themeColor)
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
    }

    // MARK: - Avatar
    private var avatarSection: some View {
        VStack(spacing: 10) {
            ZStack(alignment: .bottomTrailing) {
                Circle().fill(appState.themeColor.opacity(0.14)).frame(width: 110, height: 110)
                    .overlay {
                        if let img = avatarImage {
                            Image(uiImage: img).resizable().scaledToFill().frame(width: 110, height: 110).clipShape(Circle())
                        } else {
                            Image(systemName: "person").font(.system(size: 52, weight: .regular)).foregroundStyle(appState.themeColor.opacity(0.65))
                        }
                    }
                Circle().fill(appState.themeColor).frame(width: 30, height: 30)
                    .overlay(Image(systemName: "camera.fill").font(.system(size: 13, weight: .semibold)).foregroundColor(.white))
                    .offset(x: 4, y: 4)
            }.onTapGesture { showAvatarSheet = true }
            Button { showAvatarSheet = true } label: {
                HStack(spacing: 6) { Image(systemName: "camera.fill"); Text("Change Photo") }
                    .font(.system(size: 14, weight: .semibold)).foregroundStyle(appState.themeColor)
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(Capsule().fill(appState.themeColor.opacity(0.14)))
            }.buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity).padding(.top, 6)
    }

    // MARK: - Name
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Name").font(.system(size: 13, weight: .bold)).foregroundStyle(AppTheme.textSecondary)
            TextField("Your name", text: $name)
                .font(.system(size: 15, weight: .medium)).foregroundColor(AppTheme.textPrimary)
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color(white: 1.0, opacity: 0.75)))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(appState.themeColor.opacity(0.10), lineWidth: 1))
        }
    }

    // MARK: - Study History
    private var studyHistorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Study History").font(.system(size: 16, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
            VStack(spacing: 0) {
                ForEach(appState.currentUser.institutions) { inst in
                    institutionRow(inst)
                    Rectangle().fill(Color(white: 0.0, opacity: 0.08)).frame(height: 0.5)
                }
                Button { showAddInstitution = true } label: {
                    HStack(spacing: 10) {
                        IconBubble(icon: "plus", bg: appState.themeColor.opacity(0.12), fg: appState.themeColor)
                        Text("Add institution").font(.system(size: 15, weight: .semibold)).foregroundStyle(appState.themeColor)
                        Spacer()
                    }.padding(.vertical, 12).padding(.horizontal, 14)
                }.buttonStyle(.plain)
            }
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(white: 1.0, opacity: 0.75)))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(appState.themeColor.opacity(0.10), lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func institutionRow(_ inst: Institution) -> some View {
        HStack(spacing: 12) {
            IconBubble(icon: inst.icon, bg: appState.themeColor.opacity(0.18), fg: appState.themeColor)
            VStack(alignment: .leading, spacing: 3) {
                Text(inst.title).font(.system(size: 15, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                HStack(spacing: 6) {
                    Text(inst.type.rawValue).font(.system(size: 11, weight: .semibold)).foregroundStyle(appState.themeColor)
                        .padding(.horizontal, 7).padding(.vertical, 2).background(Capsule().fill(appState.themeColor.opacity(0.12)))
                    Text(inst.years).font(.system(size: 11, weight: .medium)).foregroundStyle(AppTheme.textSecondary)
                }
                if !inst.major.isEmpty { Text(inst.major).font(.system(size: 12, weight: .medium)).foregroundStyle(AppTheme.textSecondary) }
                if !inst.grade.isEmpty { Text(inst.grade).font(.system(size: 11, weight: .semibold)).foregroundStyle(AppTheme.textSecondary.opacity(0.7)) }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                if !inst.gpa.isEmpty {
                    VStack(spacing: 1) {
                        Text("GPA").font(.system(size: 9, weight: .bold)).foregroundStyle(AppTheme.textSecondary)
                        Text(inst.gpa).font(.system(size: 12, weight: .bold)).foregroundStyle(appState.themeColor)
                    }
                }
                if inst.transcriptData != nil {
                    Image(systemName: "doc.fill").font(.system(size: 12)).foregroundStyle(appState.themeColor.opacity(0.7))
                }
            }
            Button { appState.currentUser.institutions.removeAll { $0.id == inst.id } } label: {
                Image(systemName: "minus.circle.fill").font(.system(size: 18)).foregroundStyle(Color.red.opacity(0.75))
            }.buttonStyle(.plain)
        }
        .padding(.vertical, 12).padding(.horizontal, 14)
    }

    // MARK: - Email
    private var emailSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Email").font(.system(size: 16, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
            VStack(spacing: 0) {
                ForEach(appState.currentUser.emails, id: \.self) { email in
                    HStack(spacing: 12) {
                        IconBubble(icon: "envelope.fill", bg: appState.themeColor.opacity(0.18), fg: appState.themeColor)
                        Text(email).font(.system(size: 15, weight: .medium)).foregroundStyle(AppTheme.textPrimary)
                        Spacer()
                        Button { appState.currentUser.emails.removeAll { $0 == email } } label: {
                            Image(systemName: "minus.circle.fill").font(.system(size: 18)).foregroundStyle(Color.red.opacity(0.75))
                        }.buttonStyle(.plain)
                    }.padding(.vertical, 12).padding(.horizontal, 14)
                    Rectangle().fill(Color(white: 0.0, opacity: 0.08)).frame(height: 0.5)
                }
                if showAddEmail {
                    HStack(spacing: 10) {
                        TextField("Email address", text: $newEmail)
                            .font(.system(size: 14, weight: .medium)).foregroundColor(AppTheme.textPrimary)
                            .keyboardType(.emailAddress).autocapitalization(.none)
                            .submitLabel(.done).onSubmit { commitEmail() }
                        Button("Add") { commitEmail() }.font(.system(size: 13, weight: .bold)).foregroundStyle(appState.themeColor)
                        Button("Cancel") { showAddEmail = false; newEmail = "" }.font(.system(size: 13)).foregroundStyle(AppTheme.textSecondary)
                    }.padding(.vertical, 10).padding(.horizontal, 14)
                    Rectangle().fill(Color(white: 0.0, opacity: 0.08)).frame(height: 0.5)
                }
                Button { showAddEmail = true } label: {
                    HStack(spacing: 10) {
                        IconBubble(icon: "plus", bg: appState.themeColor.opacity(0.12), fg: appState.themeColor)
                        Text("Add email").font(.system(size: 15, weight: .semibold)).foregroundStyle(appState.themeColor)
                        Spacer()
                    }.padding(.vertical, 12).padding(.horizontal, 14)
                }.buttonStyle(.plain)
            }
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(white: 1.0, opacity: 0.75)))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(appState.themeColor.opacity(0.10), lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func commitEmail() {
        let t = newEmail.trimmingCharacters(in: .whitespaces)
        if !t.isEmpty { appState.currentUser.emails.append(t) }
        newEmail = ""; showAddEmail = false
    }

    // MARK: - Skills
    private var skillsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Skills").font(.system(size: 16, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
            VStack(alignment: .leading, spacing: 10) {
                if showAddSkill {
                    HStack {
                        TextField("New skill", text: $newSkill)
                            .font(.system(size: 14, weight: .medium)).foregroundColor(AppTheme.textPrimary)
                            .padding(10).background(RoundedRectangle(cornerRadius: 10).fill(appState.bgColor))
                            .submitLabel(.done).onSubmit { addSkill() }
                        Button("Add") { addSkill() }.font(.system(size: 13, weight: .bold)).foregroundStyle(appState.themeColor)
                    }.padding(.horizontal, 14).padding(.top, 12)
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        Button { showAddSkill = true } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "plus").font(.system(size: 11, weight: .bold))
                                Text("Add skill").font(.system(size: 13, weight: .semibold))
                            }
                            .foregroundStyle(appState.themeColor).padding(.horizontal, 12).padding(.vertical, 7)
                            .background(Capsule().fill(appState.themeColor.opacity(0.12)))
                        }.buttonStyle(.plain)
                        ForEach(appState.currentUser.skills, id: \.self) { skill in
                            HStack(spacing: 6) {
                                Text(skill).font(.system(size: 13, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
                                Button { appState.currentUser.skills.removeAll { $0 == skill } } label: {
                                    Image(systemName: "xmark").font(.system(size: 10, weight: .bold)).foregroundStyle(AppTheme.textSecondary)
                                }.buttonStyle(.plain)
                            }
                            .padding(.horizontal, 12).padding(.vertical, 7)
                            .background(Capsule().fill(Color(white: 1.0, opacity: 0.75)))
                            .overlay(Capsule().stroke(appState.themeColor.opacity(0.10), lineWidth: 1))
                        }
                    }.padding(.horizontal, 14).padding(.vertical, 12)
                }
            }
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(white: 1.0, opacity: 0.75)))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(appState.themeColor.opacity(0.10), lineWidth: 1))
        }
    }

    // MARK: - Generic Section Builder
    private func resumeSection<T: Identifiable, Content: View>(
        title: String, icon: String,
        entries: [T],
        onAdd: @escaping () -> Void,
        onDelete: @escaping (T.ID) -> Void,
        onRemoveSection: @escaping () -> Void,
        @ViewBuilder rowContent: @escaping (T) -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon).font(.system(size: 13, weight: .semibold)).foregroundStyle(appState.themeColor)
                Text(title).font(.system(size: 16, weight: .bold)).foregroundStyle(AppTheme.textPrimary)
                Spacer()
                Text("\(entries.count)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(entries.isEmpty ? AppTheme.textSecondary.opacity(0.4) : appState.themeColor)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Capsule().fill(appState.themeColor.opacity(entries.isEmpty ? 0.05 : 0.12)))
                Button { onRemoveSection() } label: {
                    Image(systemName: "xmark.circle").font(.system(size: 16)).foregroundStyle(AppTheme.textSecondary.opacity(0.5))
                }.buttonStyle(.plain).padding(.leading, 4)
            }
            VStack(spacing: 0) {
                ForEach(entries) { entry in
                    HStack(alignment: .top, spacing: 0) {
                        rowContent(entry).frame(maxWidth: .infinity, alignment: .leading)
                        Button { onDelete(entry.id) } label: {
                            Image(systemName: "minus.circle.fill").font(.system(size: 18)).foregroundStyle(Color.red.opacity(0.75))
                        }.buttonStyle(.plain).padding(.top, 14).padding(.trailing, 14)
                    }
                    Rectangle().fill(Color(white: 0.0, opacity: 0.08)).frame(height: 0.5)
                }
                Button(action: onAdd) {
                    HStack(spacing: 10) {
                        IconBubble(icon: "plus", bg: appState.themeColor.opacity(0.12), fg: appState.themeColor)
                        Text("Add \(title.lowercased())").font(.system(size: 15, weight: .semibold)).foregroundStyle(appState.themeColor)
                        Spacer()
                    }.padding(.vertical, 12).padding(.horizontal, 14)
                }.buttonStyle(.plain)
            }
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(white: 1.0, opacity: 0.75)))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(appState.themeColor.opacity(0.10), lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Bottom Buttons
    private var bottomButtons: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Text("Cancel").font(.system(size: 16, weight: .semibold)).foregroundStyle(appState.themeColor)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(Capsule().fill(Color(white: 1.0, opacity: 0.65)))
                    .overlay(Capsule().stroke(appState.themeColor.opacity(0.16), lineWidth: 1))
            }.buttonStyle(.plain)
            Button { saveProfile() } label: {
                Text("Save").font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(Capsule().fill(appState.themeColor))
                    .shadow(color: appState.themeColor.opacity(0.22), radius: 10, x: 0, y: 8)
            }.buttonStyle(.plain)
        }
        .padding(.horizontal, 16).padding(.bottom, 14).padding(.top, 10)
        .background(.ultraThinMaterial)
    }

    // MARK: - Helpers
    private func loadProfile() {
        name = appState.currentUser.name
        phone = appState.currentUser.phone
        if let data = appState.currentUser.avatarData, let img = UIImage(data: data) { avatarImage = img }
        // Restore active sections from existing data
        var sections: [ResumeSectionType] = []
        if !appState.currentUser.workExperiences.isEmpty { sections.append(.work) }
        if !appState.currentUser.projects.isEmpty { sections.append(.project) }
        if !appState.currentUser.leadership.isEmpty { sections.append(.leadership) }
        if !appState.currentUser.research.isEmpty { sections.append(.research) }
        if !appState.currentUser.extracurricular.isEmpty { sections.append(.extracurricular) }
        if !appState.currentUser.volunteer.isEmpty { sections.append(.volunteer) }
        if !appState.currentUser.awards.isEmpty { sections.append(.award) }
        if !appState.currentUser.certifications.isEmpty { sections.append(.certification) }
        if !appState.currentUser.publications.isEmpty { sections.append(.publication) }
        if !appState.currentUser.languages.isEmpty { sections.append(.language) }
        activeSections = sections
    }

    private func saveProfile() {
        if !name.isEmpty { appState.currentUser.name = name }
        if !phone.isEmpty { appState.currentUser.phone = phone }
        if let img = avatarImage, let data = img.jpegData(compressionQuality: 0.8) { appState.currentUser.avatarData = data }
        dismiss()
    }
    private func addSkill() {
        let t = newSkill.trimmingCharacters(in: .whitespaces)
        if !t.isEmpty { appState.currentUser.skills.append(t) }
        newSkill = ""; showAddSkill = false
    }
    private func formatPeriod(_ sm: String, _ sy: String, _ em: String, _ ey: String, _ current: Bool) -> String {
        let start = [sm, sy].filter { !$0.isEmpty }.joined(separator: " ")
        let end = current ? "Present" : [em, ey].filter { !$0.isEmpty }.joined(separator: " ")
        if start.isEmpty && end.isEmpty { return "" }
        if start.isEmpty { return end }
        if end.isEmpty { return start }
        return "\(start) – \(end)"
    }
}

// MARK: - Add Section Picker Sheet

struct AddSectionPickerSheet: View {
    let available: [ResumeSectionType]
    let themeColor: Color
    let bgColor: Color
    let onSelect: (ResumeSectionType) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                bgColor.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(available) { section in
                            Button {
                                onSelect(section); dismiss()
                            } label: {
                                HStack(spacing: 14) {
                                    Image(systemName: section.icon)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(themeColor)
                                        .frame(width: 36, height: 36)
                                        .background(Circle().fill(themeColor.opacity(0.12)))
                                    Text(section.rawValue)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(AppTheme.textPrimary)
                                    Spacer()
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundStyle(themeColor.opacity(0.7))
                                }
                                .padding(.horizontal, 16).padding(.vertical, 14)
                                .background(RoundedRectangle(cornerRadius: 14).fill(Color(white: 1.0, opacity: 0.75)))
                            }.buttonStyle(.plain)
                        }
                    }
                    .padding(16).padding(.bottom, 20)
                }
            }
            .navigationTitle("Add Section")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") { dismiss() }.foregroundStyle(AppTheme.textSecondary)
            }}
        }
    }
}

// MARK: - Shared Resume Row

struct ResumeEntryRow: View {
    let title: String
    let subtitle: String?
    let period: String
    let tags: [String]
    var bullets: [String] = []
    var note: String = ""
    let themeColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(.system(size: 15, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
            if let sub = subtitle, !sub.isEmpty {
                Text(sub).font(.system(size: 13, weight: .medium)).foregroundStyle(AppTheme.textSecondary)
            }
            if !period.isEmpty {
                Text(period).font(.system(size: 12, weight: .medium)).foregroundStyle(themeColor.opacity(0.8))
            }
            if !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(tags, id: \.self) { tag in
                            Text(tag).font(.system(size: 11, weight: .semibold)).foregroundStyle(themeColor)
                                .padding(.horizontal, 8).padding(.vertical, 3)
                                .background(Capsule().fill(themeColor.opacity(0.10)))
                        }
                    }
                }
            }
            if !bullets.isEmpty {
                VStack(alignment: .leading, spacing: 3) {
                    ForEach(bullets.prefix(3), id: \.self) { bullet in
                        HStack(alignment: .top, spacing: 6) {
                            Text("•").font(.system(size: 12, weight: .bold)).foregroundColor(themeColor).frame(width: 10)
                            Text(bullet).font(.system(size: 12)).foregroundStyle(AppTheme.textSecondary).lineLimit(2)
                        }
                    }
                }.padding(.top, 2)
            }
            if !note.isEmpty {
                Text(note).font(.system(size: 12)).foregroundStyle(AppTheme.textSecondary).lineLimit(1).padding(.top, 2)
            }
        }
        .padding(.vertical, 12).padding(.horizontal, 14)
    }
}

// MARK: - Shared Form Helpers

struct FormField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isOptional: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Text(label.uppercased()).font(.system(size: 11, weight: .bold)).foregroundStyle(AppTheme.textSecondary)
                if isOptional { Text("optional").font(.system(size: 10)).foregroundStyle(AppTheme.textSecondary.opacity(0.6)) }
            }
            TextField(placeholder, text: $text)
                .font(.system(size: 15, weight: .medium)).foregroundColor(AppTheme.textPrimary)
                .keyboardType(keyboardType).padding(14)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color(white: 1.0, opacity: 0.75)))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.08), lineWidth: 1))
        }
    }
}

struct PeriodPicker: View {
    let label: String
    @Binding var month: String
    @Binding var year: String
    @Binding var isCurrent: Bool
    var currentLabel: String = "Present"
    let months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
    let years: [String] = { let y = Calendar.current.component(.year, from: Date()); return (y-10...y+6).reversed().map { String($0) } }()

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased()).font(.system(size: 11, weight: .bold)).foregroundStyle(AppTheme.textSecondary)
            if isCurrent {
                Text(currentLabel).font(.system(size: 15, weight: .semibold)).foregroundStyle(AppTheme.textSecondary)
                    .padding(14).frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color(white: 1.0, opacity: 0.5)))
            } else {
                HStack(spacing: 10) {
                    Picker("Month", selection: $month) {
                        Text("Month").tag(""); ForEach(months, id: \.self) { Text($0).tag($0) }
                    }.pickerStyle(.menu).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color(white: 1.0, opacity: 0.75)))
                    Picker("Year", selection: $year) {
                        Text("Year").tag(""); ForEach(years, id: \.self) { Text($0).tag($0) }
                    }.pickerStyle(.menu).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color(white: 1.0, opacity: 0.75)))
                }
            }
        }
    }
}

struct CurrentToggle: View {
    let label: String
    @Binding var isCurrent: Bool
    let themeColor: Color
    var body: some View {
        Toggle(isOn: $isCurrent) {
            Text(label).font(.system(size: 14, weight: .semibold)).foregroundStyle(AppTheme.textPrimary)
        }
        .tint(themeColor).padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(white: 1.0, opacity: 0.75)))
    }
}

// MARK: - Work Sheet

struct AddWorkSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    let onAdd: (WorkExperienceEntry) -> Void
    @State private var company = ""; @State private var role = ""; @State private var location = ""
    @State private var startMonth = ""; @State private var startYear = ""
    @State private var endMonth = ""; @State private var endYear = ""; @State private var isCurrent = false
    @State private var bullets: [String] = []
    var canSave: Bool { !company.trimmingCharacters(in: .whitespaces).isEmpty && !role.trimmingCharacters(in: .whitespaces).isEmpty }
    var body: some View {
        NavigationStack {
            ZStack { appState.bgColor.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        FormField(label: "Company", placeholder: "e.g. Google, Startup Inc.", text: $company)
                        FormField(label: "Job Title / Role", placeholder: "e.g. Software Engineer Intern", text: $role)
                        FormField(label: "Location", placeholder: "e.g. San Francisco, CA", text: $location, isOptional: true)
                        CurrentToggle(label: "I currently work here", isCurrent: $isCurrent, themeColor: appState.themeColor)
                        PeriodPicker(label: "Start Date", month: $startMonth, year: $startYear, isCurrent: .constant(false))
                        PeriodPicker(label: "End Date", month: $endMonth, year: $endYear, isCurrent: $isCurrent, currentLabel: "Present")
                        BulletInputSection(placeholder: "e.g. Led a team of 5 engineers…", bullets: $bullets, themeColor: appState.themeColor)
                        Button { onAdd(WorkExperienceEntry(company: company, role: role, location: location, startMonth: startMonth, startYear: startYear, endMonth: endMonth, endYear: endYear, isCurrent: isCurrent, bullets: bullets)); dismiss() } label: {
                            Text("Add Experience").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                                .frame(maxWidth: .infinity).padding(.vertical, 16)
                                .background(Capsule().fill(canSave ? appState.themeColor : Color(white: 0.5, opacity: 0.4)))
                        }.buttonStyle(.plain).disabled(!canSave)
                    }.padding(20).padding(.bottom, 30)
                }
            }
            .navigationTitle("Work Experience").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() }.foregroundStyle(AppTheme.textSecondary) }}
        }
    }
}

// MARK: - Project Sheet

struct AddProjectSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    let onAdd: (ProjectEntry) -> Void
    @State private var title = ""; @State private var role = ""; @State private var techStack = ""; @State private var link = ""
    @State private var startMonth = ""; @State private var startYear = ""
    @State private var endMonth = ""; @State private var endYear = ""; @State private var isOngoing = false
    @State private var bullets: [String] = []
    var canSave: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }
    var body: some View {
        NavigationStack {
            ZStack { appState.bgColor.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        FormField(label: "Project Name", placeholder: "e.g. Barely Working App", text: $title)
                        FormField(label: "Your Role", placeholder: "e.g. Lead Developer", text: $role, isOptional: true)
                        FormField(label: "Tech Stack", placeholder: "e.g. Swift, Python, Figma", text: $techStack, isOptional: true)
                        CurrentToggle(label: "Ongoing project", isCurrent: $isOngoing, themeColor: appState.themeColor)
                        PeriodPicker(label: "Start Date", month: $startMonth, year: $startYear, isCurrent: .constant(false))
                        PeriodPicker(label: "End Date", month: $endMonth, year: $endYear, isCurrent: $isOngoing, currentLabel: "Ongoing")
                        FormField(label: "Link", placeholder: "https://github.com/...", text: $link, isOptional: true)
                        BulletInputSection(placeholder: "e.g. Built with SwiftUI, 500+ downloads…", bullets: $bullets, themeColor: appState.themeColor)
                        Button { onAdd(ProjectEntry(title: title, role: role, techStack: techStack, startMonth: startMonth, startYear: startYear, endMonth: endMonth, endYear: endYear, isOngoing: isOngoing, link: link, bullets: bullets)); dismiss() } label: {
                            Text("Add Project").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                                .frame(maxWidth: .infinity).padding(.vertical, 16)
                                .background(Capsule().fill(canSave ? appState.themeColor : Color(white: 0.5, opacity: 0.4)))
                        }.buttonStyle(.plain).disabled(!canSave)
                    }.padding(20).padding(.bottom, 30)
                }
            }
            .navigationTitle("Project").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() }.foregroundStyle(AppTheme.textSecondary) }}
        }
    }
}

// MARK: - Leadership Sheet

struct AddLeadershipSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    let onAdd: (LeadershipEntry) -> Void
    @State private var role = ""; @State private var organization = ""; @State private var location = ""; @State private var teamSize = ""
    @State private var startMonth = ""; @State private var startYear = ""
    @State private var endMonth = ""; @State private var endYear = ""; @State private var isCurrent = false
    @State private var bullets: [String] = []
    var canSave: Bool { !role.trimmingCharacters(in: .whitespaces).isEmpty && !organization.trimmingCharacters(in: .whitespaces).isEmpty }
    var body: some View {
        NavigationStack {
            ZStack { appState.bgColor.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        FormField(label: "Role / Title", placeholder: "e.g. President, Team Lead", text: $role)
                        FormField(label: "Organization", placeholder: "e.g. Student Council", text: $organization)
                        FormField(label: "Location", placeholder: "e.g. New York, NY", text: $location, isOptional: true)
                        FormField(label: "Team Size", placeholder: "e.g. 12 members", text: $teamSize, isOptional: true)
                        CurrentToggle(label: "Currently in this role", isCurrent: $isCurrent, themeColor: appState.themeColor)
                        PeriodPicker(label: "Start Date", month: $startMonth, year: $startYear, isCurrent: .constant(false))
                        PeriodPicker(label: "End Date", month: $endMonth, year: $endYear, isCurrent: $isCurrent)
                        BulletInputSection(placeholder: "e.g. Grew membership by 40%…", bullets: $bullets, themeColor: appState.themeColor)
                        Button { onAdd(LeadershipEntry(role: role, organization: organization, location: location, startMonth: startMonth, startYear: startYear, endMonth: endMonth, endYear: endYear, isCurrent: isCurrent, teamSize: teamSize, bullets: bullets)); dismiss() } label: {
                            Text("Add Leadership").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                                .frame(maxWidth: .infinity).padding(.vertical, 16)
                                .background(Capsule().fill(canSave ? appState.themeColor : Color(white: 0.5, opacity: 0.4)))
                        }.buttonStyle(.plain).disabled(!canSave)
                    }.padding(20).padding(.bottom, 30)
                }
            }
            .navigationTitle("Leadership").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() }.foregroundStyle(AppTheme.textSecondary) }}
        }
    }
}

// MARK: - Research Sheet

struct AddResearchSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    let onAdd: (ResearchEntry) -> Void
    @State private var title = ""; @State private var institution = ""; @State private var supervisor = ""; @State private var field = ""
    @State private var startMonth = ""; @State private var startYear = ""
    @State private var endMonth = ""; @State private var endYear = ""; @State private var isOngoing = false
    @State private var bullets: [String] = []
    var canSave: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }
    var body: some View {
        NavigationStack {
            ZStack { appState.bgColor.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        FormField(label: "Research Title", placeholder: "e.g. Deep Learning for Medical Imaging", text: $title)
                        FormField(label: "Institution / Lab", placeholder: "e.g. MIT CSAIL", text: $institution, isOptional: true)
                        FormField(label: "Supervisor / PI", placeholder: "e.g. Prof. John Smith", text: $supervisor, isOptional: true)
                        FormField(label: "Research Field", placeholder: "e.g. Computer Vision", text: $field, isOptional: true)
                        CurrentToggle(label: "Ongoing research", isCurrent: $isOngoing, themeColor: appState.themeColor)
                        PeriodPicker(label: "Start Date", month: $startMonth, year: $startYear, isCurrent: .constant(false))
                        PeriodPicker(label: "End Date", month: $endMonth, year: $endYear, isCurrent: $isOngoing, currentLabel: "Ongoing")
                        BulletInputSection(placeholder: "e.g. Developed novel algorithm improving accuracy by 15%…", bullets: $bullets, themeColor: appState.themeColor)
                        Button { onAdd(ResearchEntry(title: title, institution: institution, supervisor: supervisor, startMonth: startMonth, startYear: startYear, endMonth: endMonth, endYear: endYear, isOngoing: isOngoing, field: field, bullets: bullets)); dismiss() } label: {
                            Text("Add Research").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                                .frame(maxWidth: .infinity).padding(.vertical, 16)
                                .background(Capsule().fill(canSave ? appState.themeColor : Color(white: 0.5, opacity: 0.4)))
                        }.buttonStyle(.plain).disabled(!canSave)
                    }.padding(20).padding(.bottom, 30)
                }
            }
            .navigationTitle("Research").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() }.foregroundStyle(AppTheme.textSecondary) }}
        }
    }
}

// MARK: - Volunteer Sheet

struct AddVolunteerSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    let onAdd: (VolunteerEntry) -> Void
    @State private var role = ""; @State private var organization = ""; @State private var location = ""; @State private var hoursPerWeek = ""
    @State private var startMonth = ""; @State private var startYear = ""
    @State private var endMonth = ""; @State private var endYear = ""; @State private var isCurrent = false
    @State private var bullets: [String] = []
    var canSave: Bool { !role.trimmingCharacters(in: .whitespaces).isEmpty && !organization.trimmingCharacters(in: .whitespaces).isEmpty }
    var body: some View {
        NavigationStack {
            ZStack { appState.bgColor.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        FormField(label: "Role", placeholder: "e.g. Tutor, Event Coordinator", text: $role)
                        FormField(label: "Organization", placeholder: "e.g. Red Cross", text: $organization)
                        FormField(label: "Location", placeholder: "e.g. New York, NY", text: $location, isOptional: true)
                        FormField(label: "Hours Per Week", placeholder: "e.g. 5", text: $hoursPerWeek, keyboardType: .numberPad, isOptional: true)
                        CurrentToggle(label: "Currently volunteering", isCurrent: $isCurrent, themeColor: appState.themeColor)
                        PeriodPicker(label: "Start Date", month: $startMonth, year: $startYear, isCurrent: .constant(false))
                        PeriodPicker(label: "End Date", month: $endMonth, year: $endYear, isCurrent: $isCurrent)
                        BulletInputSection(placeholder: "e.g. Taught 20+ students weekly…", bullets: $bullets, themeColor: appState.themeColor)
                        Button { onAdd(VolunteerEntry(role: role, organization: organization, location: location, startMonth: startMonth, startYear: startYear, endMonth: endMonth, endYear: endYear, isCurrent: isCurrent, hoursPerWeek: hoursPerWeek, bullets: bullets)); dismiss() } label: {
                            Text("Add Volunteer").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                                .frame(maxWidth: .infinity).padding(.vertical, 16)
                                .background(Capsule().fill(canSave ? appState.themeColor : Color(white: 0.5, opacity: 0.4)))
                        }.buttonStyle(.plain).disabled(!canSave)
                    }.padding(20).padding(.bottom, 30)
                }
            }
            .navigationTitle("Volunteer").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() }.foregroundStyle(AppTheme.textSecondary) }}
        }
    }
}

// MARK: - Extracurricular Sheet

struct AddExtracurricularSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    let onAdd: (ExtracurricularEntry) -> Void
    @State private var activityName = ""; @State private var role = ""; @State private var organization = ""
    @State private var startYear = ""; @State private var endYear = ""; @State private var isCurrent = false; @State private var frequency = ""
    @State private var bullets: [String] = []
    let frequencies = ["Daily", "Weekly", "Bi-weekly", "Monthly", "Seasonal"]
    let years: [String] = (((Calendar.current.component(.year, from: Date()) - 10)...(Calendar.current.component(.year, from: Date()) + 2)).reversed()).map { String($0) }
    var canSave: Bool { !activityName.trimmingCharacters(in: .whitespaces).isEmpty }
    var body: some View {
        NavigationStack {
            ZStack { appState.bgColor.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        FormField(label: "Activity Name", placeholder: "e.g. Basketball Team, Chess Club", text: $activityName)
                        FormField(label: "Your Role", placeholder: "e.g. Captain, Member", text: $role, isOptional: true)
                        FormField(label: "Organization / School", placeholder: "e.g. Lincoln High School", text: $organization, isOptional: true)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("FREQUENCY").font(.system(size: 11, weight: .bold)).foregroundStyle(AppTheme.textSecondary)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(frequencies, id: \.self) { f in
                                        Button { frequency = f } label: {
                                            Text(f).font(.system(size: 13, weight: .semibold))
                                                .foregroundStyle(frequency == f ? .white : AppTheme.textPrimary)
                                                .padding(.horizontal, 14).padding(.vertical, 8)
                                                .background(Capsule().fill(frequency == f ? appState.themeColor : Color(white: 1.0, opacity: 0.7)))
                                        }.buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        CurrentToggle(label: "Currently active", isCurrent: $isCurrent, themeColor: appState.themeColor)
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("START YEAR").font(.system(size: 11, weight: .bold)).foregroundStyle(AppTheme.textSecondary)
                                Picker("Start", selection: $startYear) { Text("Year").tag(""); ForEach(years, id: \.self) { Text($0).tag($0) } }
                                    .pickerStyle(.menu).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color(white: 1.0, opacity: 0.75)))
                            }
                            if !isCurrent {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("END YEAR").font(.system(size: 11, weight: .bold)).foregroundStyle(AppTheme.textSecondary)
                                    Picker("End", selection: $endYear) { Text("Year").tag(""); ForEach(years, id: \.self) { Text($0).tag($0) } }
                                        .pickerStyle(.menu).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color(white: 1.0, opacity: 0.75)))
                                }
                            }
                        }
                        BulletInputSection(placeholder: "e.g. Won regional championship…", bullets: $bullets, themeColor: appState.themeColor)
                        Button { onAdd(ExtracurricularEntry(activityName: activityName, role: role, organization: organization, startYear: startYear, endYear: isCurrent ? "" : endYear, isCurrent: isCurrent, frequency: frequency, bullets: bullets)); dismiss() } label: {
                            Text("Add Activity").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                                .frame(maxWidth: .infinity).padding(.vertical, 16)
                                .background(Capsule().fill(canSave ? appState.themeColor : Color(white: 0.5, opacity: 0.4)))
                        }.buttonStyle(.plain).disabled(!canSave)
                    }.padding(20).padding(.bottom, 30)
                }
            }
            .navigationTitle("Extracurricular").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() }.foregroundStyle(AppTheme.textSecondary) }}
        }
    }
}

// MARK: - Award Sheet (note only)

struct AddAwardSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    let onAdd: (AwardEntry) -> Void
    @State private var title = ""; @State private var issuer = ""; @State private var year = ""; @State private var month = ""; @State private var level = ""; @State private var note = ""
    let levels = ["International", "National", "Regional", "School", "Department", "Other"]
    let months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
    let years: [String] = (((Calendar.current.component(.year, from: Date()) - 10)...(Calendar.current.component(.year, from: Date()) + 2)).reversed()).map { String($0) }
    var canSave: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }
    var body: some View {
        NavigationStack {
            ZStack { appState.bgColor.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        FormField(label: "Award Title", placeholder: "e.g. First Place, National Science Fair", text: $title)
                        FormField(label: "Issued By", placeholder: "e.g. MIT, ACM, UNESCO", text: $issuer, isOptional: true)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DATE").font(.system(size: 11, weight: .bold)).foregroundStyle(AppTheme.textSecondary)
                            HStack(spacing: 10) {
                                Picker("Month", selection: $month) { Text("Month").tag(""); ForEach(months, id: \.self) { Text($0).tag($0) } }
                                    .pickerStyle(.menu).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color(white: 1.0, opacity: 0.75)))
                                Picker("Year", selection: $year) { Text("Year").tag(""); ForEach(years, id: \.self) { Text($0).tag($0) } }
                                    .pickerStyle(.menu).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color(white: 1.0, opacity: 0.75)))
                            }
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            Text("LEVEL").font(.system(size: 11, weight: .bold)).foregroundStyle(AppTheme.textSecondary)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(levels, id: \.self) { l in
                                        Button { level = l } label: {
                                            Text(l).font(.system(size: 13, weight: .semibold))
                                                .foregroundStyle(level == l ? .white : AppTheme.textPrimary)
                                                .padding(.horizontal, 14).padding(.vertical, 8)
                                                .background(Capsule().fill(level == l ? appState.themeColor : Color(white: 1.0, opacity: 0.7)))
                                        }.buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        FormField(label: "Note", placeholder: "Brief note (optional)", text: $note, isOptional: true)
                        Button { onAdd(AwardEntry(title: title, issuer: issuer, year: year, month: month, level: level, note: note)); dismiss() } label: {
                            Text("Add Award").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                                .frame(maxWidth: .infinity).padding(.vertical, 16)
                                .background(Capsule().fill(canSave ? appState.themeColor : Color(white: 0.5, opacity: 0.4)))
                        }.buttonStyle(.plain).disabled(!canSave)
                    }.padding(20).padding(.bottom, 30)
                }
            }
            .navigationTitle("Award & Honor").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() }.foregroundStyle(AppTheme.textSecondary) }}
        }
    }
}

// MARK: - Certification Sheet (note only)

struct AddCertificationSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    let onAdd: (CertificationEntry) -> Void
    @State private var name = ""; @State private var issuer = ""; @State private var issueMonth = ""; @State private var issueYear = ""
    @State private var expiryMonth = ""; @State private var expiryYear = ""; @State private var noExpiry = false
    @State private var credentialId = ""; @State private var link = ""; @State private var note = ""
    let months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
    let years: [String] = (((Calendar.current.component(.year, from: Date()) - 5)...(Calendar.current.component(.year, from: Date()) + 10)).reversed()).map { String($0) }
    var canSave: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }
    var body: some View {
        NavigationStack {
            ZStack { appState.bgColor.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        FormField(label: "Certification Name", placeholder: "e.g. AWS Solutions Architect", text: $name)
                        FormField(label: "Issuing Organization", placeholder: "e.g. Amazon, Coursera", text: $issuer, isOptional: true)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("ISSUE DATE").font(.system(size: 11, weight: .bold)).foregroundStyle(AppTheme.textSecondary)
                            HStack(spacing: 10) {
                                Picker("Month", selection: $issueMonth) { Text("Month").tag(""); ForEach(months, id: \.self) { Text($0).tag($0) } }
                                    .pickerStyle(.menu).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color(white: 1.0, opacity: 0.75)))
                                Picker("Year", selection: $issueYear) { Text("Year").tag(""); ForEach(years, id: \.self) { Text($0).tag($0) } }
                                    .pickerStyle(.menu).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color(white: 1.0, opacity: 0.75)))
                            }
                        }
                        CurrentToggle(label: "No expiration date", isCurrent: $noExpiry, themeColor: appState.themeColor)
                        if !noExpiry {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("EXPIRY DATE").font(.system(size: 11, weight: .bold)).foregroundStyle(AppTheme.textSecondary)
                                HStack(spacing: 10) {
                                    Picker("Month", selection: $expiryMonth) { Text("Month").tag(""); ForEach(months, id: \.self) { Text($0).tag($0) } }
                                        .pickerStyle(.menu).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color(white: 1.0, opacity: 0.75)))
                                    Picker("Year", selection: $expiryYear) { Text("Year").tag(""); ForEach(years, id: \.self) { Text($0).tag($0) } }
                                        .pickerStyle(.menu).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color(white: 1.0, opacity: 0.75)))
                                }
                            }
                        }
                        FormField(label: "Credential ID", placeholder: "e.g. ABC-123456", text: $credentialId, isOptional: true)
                        FormField(label: "Verification URL", placeholder: "https://...", text: $link, isOptional: true)
                        FormField(label: "Note", placeholder: "Brief note (optional)", text: $note, isOptional: true)
                        Button { onAdd(CertificationEntry(name: name, issuer: issuer, issueMonth: issueMonth, issueYear: issueYear, expiryMonth: expiryMonth, expiryYear: expiryYear, noExpiry: noExpiry, credentialId: credentialId, link: link, note: note)); dismiss() } label: {
                            Text("Add Certification").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                                .frame(maxWidth: .infinity).padding(.vertical, 16)
                                .background(Capsule().fill(canSave ? appState.themeColor : Color(white: 0.5, opacity: 0.4)))
                        }.buttonStyle(.plain).disabled(!canSave)
                    }.padding(20).padding(.bottom, 30)
                }
            }
            .navigationTitle("Certification").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() }.foregroundStyle(AppTheme.textSecondary) }}
        }
    }
}

// MARK: - Publication Sheet (note only)

struct AddPublicationSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    let onAdd: (PublicationEntry) -> Void
    @State private var title = ""; @State private var authors = ""; @State private var journal = ""; @State private var year = ""; @State private var month = ""
    @State private var doi = ""; @State private var link = ""; @State private var type = ""; @State private var note = ""
    let types = ["Journal Article", "Conference Paper", "Book Chapter", "Thesis", "Blog Post", "Other"]
    let months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
    let years: [String] = (((Calendar.current.component(.year, from: Date()) - 10)...(Calendar.current.component(.year, from: Date()) + 2)).reversed()).map { String($0) }
    var canSave: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }
    var body: some View {
        NavigationStack {
            ZStack { appState.bgColor.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        FormField(label: "Title", placeholder: "e.g. Attention Is All You Need", text: $title)
                        FormField(label: "Authors", placeholder: "e.g. Smith J., Doe A.", text: $authors, isOptional: true)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("TYPE").font(.system(size: 11, weight: .bold)).foregroundStyle(AppTheme.textSecondary)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(types, id: \.self) { t in
                                        Button { type = t } label: {
                                            Text(t).font(.system(size: 13, weight: .semibold))
                                                .foregroundStyle(type == t ? .white : AppTheme.textPrimary)
                                                .padding(.horizontal, 14).padding(.vertical, 8)
                                                .background(Capsule().fill(type == t ? appState.themeColor : Color(white: 1.0, opacity: 0.7)))
                                        }.buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        FormField(label: "Journal / Publisher", placeholder: "e.g. Nature, NeurIPS 2024", text: $journal, isOptional: true)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("PUBLICATION DATE").font(.system(size: 11, weight: .bold)).foregroundStyle(AppTheme.textSecondary)
                            HStack(spacing: 10) {
                                Picker("Month", selection: $month) { Text("Month").tag(""); ForEach(months, id: \.self) { Text($0).tag($0) } }
                                    .pickerStyle(.menu).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color(white: 1.0, opacity: 0.75)))
                                Picker("Year", selection: $year) { Text("Year").tag(""); ForEach(years, id: \.self) { Text($0).tag($0) } }
                                    .pickerStyle(.menu).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color(white: 1.0, opacity: 0.75)))
                            }
                        }
                        FormField(label: "DOI", placeholder: "e.g. 10.1000/xyz123", text: $doi, isOptional: true)
                        FormField(label: "URL", placeholder: "https://...", text: $link, isOptional: true)
                        FormField(label: "Note", placeholder: "Brief note (optional)", text: $note, isOptional: true)
                        Button { onAdd(PublicationEntry(title: title, authors: authors, journal: journal, year: year, month: month, doi: doi, link: link, type: type, note: note)); dismiss() } label: {
                            Text("Add Publication").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                                .frame(maxWidth: .infinity).padding(.vertical, 16)
                                .background(Capsule().fill(canSave ? appState.themeColor : Color(white: 0.5, opacity: 0.4)))
                        }.buttonStyle(.plain).disabled(!canSave)
                    }.padding(20).padding(.bottom, 30)
                }
            }
            .navigationTitle("Publication").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() }.foregroundStyle(AppTheme.textSecondary) }}
        }
    }
}

// MARK: - Language Sheet

struct AddLanguageSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    let onAdd: (LanguageEntry) -> Void
    @State private var language = ""; @State private var proficiency = "Conversational"; @State private var certificate = ""
    let levels = ["Native", "Fluent", "Advanced", "Conversational", "Basic"]
    var canSave: Bool { !language.trimmingCharacters(in: .whitespaces).isEmpty }
    var body: some View {
        NavigationStack {
            ZStack { appState.bgColor.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        FormField(label: "Language", placeholder: "e.g. Mandarin, Spanish, French", text: $language)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("PROFICIENCY LEVEL").font(.system(size: 11, weight: .bold)).foregroundStyle(AppTheme.textSecondary)
                            VStack(spacing: 8) {
                                ForEach(levels, id: \.self) { l in
                                    Button { proficiency = l } label: {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(l).font(.system(size: 15, weight: .semibold))
                                                    .foregroundStyle(proficiency == l ? .white : AppTheme.textPrimary)
                                                Text(levelDesc(l)).font(.system(size: 12))
                                                    .foregroundStyle(proficiency == l ? .white.opacity(0.8) : AppTheme.textSecondary)
                                            }
                                            Spacer()
                                            if proficiency == l { Image(systemName: "checkmark.circle.fill").foregroundStyle(.white).font(.system(size: 18)) }
                                        }
                                        .padding(14)
                                        .background(RoundedRectangle(cornerRadius: 14).fill(proficiency == l ? appState.themeColor : Color(white: 1.0, opacity: 0.7)))
                                    }.buttonStyle(.plain)
                                }
                            }
                        }
                        FormField(label: "Test Score / Certificate", placeholder: "e.g. IELTS 7.5, TOEFL 110", text: $certificate, isOptional: true)
                        Button { onAdd(LanguageEntry(language: language, proficiency: proficiency, certificate: certificate)); dismiss() } label: {
                            Text("Add Language").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                                .frame(maxWidth: .infinity).padding(.vertical, 16)
                                .background(Capsule().fill(canSave ? appState.themeColor : Color(white: 0.5, opacity: 0.4)))
                        }.buttonStyle(.plain).disabled(!canSave)
                    }.padding(20).padding(.bottom, 30)
                }
            }
            .navigationTitle("Language").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() }.foregroundStyle(AppTheme.textSecondary) }}
        }
    }
    private func levelDesc(_ l: String) -> String {
        switch l {
        case "Native": return "Grew up speaking this language"
        case "Fluent": return "Speak with ease in any situation"
        case "Advanced": return "Handle complex topics comfortably"
        case "Conversational": return "Can hold everyday conversations"
        case "Basic": return "Know fundamental phrases"
        default: return ""
        }
    }
}

// MARK: - Add Institution Sheet (unchanged)

struct AddInstitutionSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    let onAdd: (Institution) -> Void
    @State private var selectedType: InstitutionType = .university
    @State private var institutionName = ""
    private let months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
    private let currentYear = Calendar.current.component(.year, from: Date())
    @State private var startMonthIdx = 8; @State private var startYear = Calendar.current.component(.year, from: Date())
    @State private var endMonthIdx = 5; @State private var endYear = Calendar.current.component(.year, from: Date()) + 4
    @State private var major = ""; @State private var gpa = ""; @State private var selectedGrade = ""
    @State private var transcriptItem: PhotosPickerItem? = nil; @State private var transcriptData: Data? = nil; @State private var transcriptImage: UIImage? = nil
    private var years: [Int] { Array((currentYear - 5)...(currentYear + 8)) }
    private var isDateValid: Bool { (startYear * 12 + startMonthIdx) <= (endYear * 12 + endMonthIdx) }
    private var datePreview: String {
        let sm = months[startMonthIdx]; let em = months[endMonthIdx]
        return startYear == endYear ? "\(sm) - \(em) \(startYear)" : "\(sm) \(startYear) - \(em) \(endYear)"
    }
    private var canSave: Bool { !institutionName.trimmingCharacters(in: .whitespaces).isEmpty && isDateValid }

    var body: some View {
        NavigationStack {
            ZStack {
                appState.bgColor.ignoresSafeArea()
                appState.themeColor.opacity(0.07).ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        typeSection; nameSection; dateSection; gradeSection; majorSection; gpaSection; transcriptSection; saveButton
                    }.padding(20).padding(.bottom, 30)
                }
            }
            .navigationTitle("Add Institution").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() }.foregroundStyle(AppTheme.textSecondary) }}
        }
        .onAppear { selectedGrade = selectedType.gradeOptions.first ?? "" }
    }

    private var typeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Institution Type")
            HStack(spacing: 10) {
                ForEach(InstitutionType.allCases, id: \.self) { type in
                    Button { selectedType = type; selectedGrade = type.gradeOptions.first ?? "" } label: {
                        VStack(spacing: 6) {
                            Image(systemName: type.icon).font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(selectedType == type ? .white : appState.themeColor)
                            Text(type.rawValue).font(.system(size: 12, weight: .bold))
                                .foregroundStyle(selectedType == type ? .white : AppTheme.textPrimary).multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: 14).fill(selectedType == type ? appState.themeColor : Color(white: 1.0, opacity: 0.7)))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(selectedType == type ? Color.clear : appState.themeColor.opacity(0.15), lineWidth: 1))
                    }.buttonStyle(.plain)
                }
            }
        }
    }
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Institution Name")
            let ph: String = { switch selectedType { case .university: return "e.g. MIT, Peking University"; case .highSchool: return "e.g. Lincoln High School"; case .other: return "e.g. Cooper Summer Camp" } }()
            TextField(ph, text: $institutionName).font(.system(size: 15, weight: .medium)).foregroundColor(AppTheme.textPrimary)
                .padding(14).background(RoundedRectangle(cornerRadius: 14).fill(Color(white: 1.0, opacity: 0.75)))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(appState.themeColor.opacity(0.10), lineWidth: 1))
        }
    }
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Time Span")
            VStack(spacing: 0) {
                HStack(spacing: 0) { Text("From").font(.system(size: 13, weight: .semibold)).foregroundStyle(AppTheme.textSecondary).frame(width: 48, alignment: .leading); monthYearPicker(monthIdx: $startMonthIdx, year: $startYear) }
                Divider().padding(.vertical, 2)
                HStack(spacing: 0) { Text("To").font(.system(size: 13, weight: .semibold)).foregroundStyle(AppTheme.textSecondary).frame(width: 48, alignment: .leading); monthYearPicker(monthIdx: $endMonthIdx, year: $endYear) }
            }
            .padding(12).background(RoundedRectangle(cornerRadius: 14).fill(Color(white: 1.0, opacity: 0.75)))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(appState.themeColor.opacity(0.10), lineWidth: 1))
            if isDateValid {
                HStack(spacing: 6) { Image(systemName: "calendar").font(.system(size: 12)).foregroundStyle(appState.themeColor); Text(datePreview).font(.system(size: 12, weight: .semibold)).foregroundStyle(appState.themeColor) }
            } else {
                HStack(spacing: 6) { Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 12)); Text("\"From\" must be before \"To\"").font(.system(size: 12, weight: .semibold)) }.foregroundStyle(Color.red.opacity(0.8))
            }
        }
    }
    private var gradeSection: some View {
        let label: String = { switch selectedType { case .university: return "Year Level"; case .highSchool: return "Grade"; case .other: return "Level" } }()
        return VStack(alignment: .leading, spacing: 10) {
            sectionLabel(label)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(selectedType.gradeOptions, id: \.self) { g in
                        Button { selectedGrade = g } label: {
                            Text(g).font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(selectedGrade == g ? .white : AppTheme.textPrimary)
                                .padding(.horizontal, 14).padding(.vertical, 8)
                                .background(Capsule().fill(selectedGrade == g ? appState.themeColor : Color(white: 1.0, opacity: 0.7)))
                                .overlay(Capsule().stroke(selectedGrade == g ? Color.clear : appState.themeColor.opacity(0.15), lineWidth: 1))
                        }.buttonStyle(.plain)
                    }
                }.padding(.horizontal, 2)
            }
        }
    }
    private var majorSection: some View {
        let label: String = { switch selectedType { case .university: return "Major / Department"; case .highSchool: return "Focus / Track (optional)"; case .other: return "Program / Course (optional)" } }()
        let ph: String = { switch selectedType { case .university: return "e.g. Computer Science"; case .highSchool: return "e.g. STEM Track"; case .other: return "e.g. iOS Development" } }()
        return VStack(alignment: .leading, spacing: 10) {
            sectionLabel(label)
            TextField(ph, text: $major).font(.system(size: 15, weight: .medium)).foregroundColor(AppTheme.textPrimary)
                .padding(14).background(RoundedRectangle(cornerRadius: 14).fill(Color(white: 1.0, opacity: 0.75)))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(appState.themeColor.opacity(0.10), lineWidth: 1))
        }
    }
    private var gpaSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("GPA (optional)")
            TextField("e.g. 3.8 / 4.0", text: $gpa).font(.system(size: 15, weight: .medium)).foregroundColor(AppTheme.textPrimary)
                .keyboardType(.decimalPad).padding(14)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color(white: 1.0, opacity: 0.75)))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(appState.themeColor.opacity(0.10), lineWidth: 1))
        }
    }
    private var transcriptSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Transcript (optional)")
            PhotosPicker(selection: $transcriptItem, matching: .images) {
                HStack(spacing: 12) {
                    if let img = transcriptImage {
                        Image(uiImage: img).resizable().scaledToFill().frame(width: 48, height: 48).clipShape(RoundedRectangle(cornerRadius: 8))
                        VStack(alignment: .leading, spacing: 2) { Text("Transcript uploaded").font(.system(size: 14, weight: .semibold)).foregroundStyle(AppTheme.textPrimary); Text("Tap to change").font(.system(size: 12)).foregroundStyle(AppTheme.textSecondary) }
                        Spacer()
                        Button { transcriptImage = nil; transcriptData = nil; transcriptItem = nil } label: { Image(systemName: "xmark.circle.fill").font(.system(size: 20)).foregroundStyle(Color.red.opacity(0.7)) }.buttonStyle(.plain)
                    } else {
                        Image(systemName: "doc.badge.plus").font(.system(size: 22)).foregroundStyle(appState.themeColor).frame(width: 48, height: 48).background(RoundedRectangle(cornerRadius: 10).fill(appState.themeColor.opacity(0.10)))
                        Text("Upload transcript photo").font(.system(size: 14, weight: .semibold)).foregroundStyle(appState.themeColor); Spacer()
                    }
                }
                .padding(14).background(RoundedRectangle(cornerRadius: 14).fill(Color(white: 1.0, opacity: 0.75)))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(appState.themeColor.opacity(0.10), lineWidth: 1))
            }
            .onChange(of: transcriptItem) { _ in
                guard let item = transcriptItem else { return }
                Task { if let data = try? await item.loadTransferable(type: Data.self), let img = UIImage(data: data) { await MainActor.run { transcriptData = data; transcriptImage = img } } }
            }
        }
    }
    private var saveButton: some View {
        Button { saveInstitution() } label: {
            Text("Add Institution").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                .frame(maxWidth: .infinity).padding(.vertical, 16)
                .background(Capsule().fill(canSave ? appState.themeColor : Color(white: 0.5, opacity: 0.4)))
        }.buttonStyle(.plain).disabled(!canSave).padding(.top, 4)
    }
    @ViewBuilder private func sectionLabel(_ text: String) -> some View {
        Text(text).font(.system(size: 12, weight: .bold)).foregroundStyle(AppTheme.textSecondary).textCase(.uppercase).frame(maxWidth: .infinity, alignment: .leading)
    }
    @ViewBuilder private func monthYearPicker(monthIdx: Binding<Int>, year: Binding<Int>) -> some View {
        HStack(spacing: 0) {
            Picker("", selection: monthIdx) { ForEach(months.indices, id: \.self) { i in Text(months[i]).tag(i) } }.pickerStyle(.wheel).frame(width: 80, height: 100).clipped().colorScheme(.light)
            Picker("", selection: year) { ForEach(years, id: \.self) { y in Text(String(y)).tag(y) } }.pickerStyle(.wheel).frame(width: 90, height: 100).clipped().colorScheme(.light)
        }
    }
    private func saveInstitution() {
        guard canSave else { return }
        onAdd(Institution(type: selectedType, title: institutionName.trimmingCharacters(in: .whitespaces), startMonthIdx: startMonthIdx, startYear: startYear, endMonthIdx: endMonthIdx, endYear: endYear, major: major, gpa: gpa, grade: selectedGrade, transcriptData: transcriptData))
        dismiss()
    }
}

// MARK: - Camera View

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        picker.allowsEditing = true; picker.delegate = context.coordinator; return picker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraView
        init(_ parent: CameraView) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.image = (info[.editedImage] ?? info[.originalImage]) as? UIImage; parent.dismiss()
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { parent.dismiss() }
    }
}

#Preview { EditProfileView().environmentObject(AppState()) }




