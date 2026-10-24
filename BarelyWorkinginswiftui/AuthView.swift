//
//import SwiftUI
//
//// MARK: - Auth Root
//
//struct AuthView: View {
//    @EnvironmentObject var appState: AppState
//    @State private var showRegister = false
//
//    var body: some View {
//        ZStack {
//            appState.bgColor.ignoresSafeArea()
//
//            if showRegister {
//                RegisterView(showRegister: $showRegister)
//                    .transition(.asymmetric(
//                        insertion: .move(edge: .trailing),
//                        removal: .move(edge: .trailing)
//                    ))
//            } else {
//                LoginView(showRegister: $showRegister)
//                    .transition(.asymmetric(
//                        insertion: .move(edge: .leading),
//                        removal: .move(edge: .leading)
//                    ))
//            }
//        }
//        .animation(.easeInOut(duration: 0.3), value: showRegister)
//    }
//}
//
//// MARK: - Login
//
//struct LoginView: View {
//    @EnvironmentObject var appState: AppState
//    @Binding var showRegister: Bool
//
//    @State private var email = ""
//    @State private var password = ""
//    @State private var showError = false
//    @State private var errorMsg = ""
//    @FocusState private var focusedField: Field?
//
//    enum Field { case email, password }
//
//    var body: some View {
//        ScrollView(showsIndicators: false) {
//            VStack(spacing: 0) {
//
//                // Header
//                VStack(spacing: 8) {
//                    ZStack {
//                        Circle()
//                            .fill(appState.themeColor.opacity(0.12))
//                            .frame(width: 80, height: 80)
//                        Image(systemName: "brain.head.profile")
//                            .font(.system(size: 36, weight: .semibold))
//                            .foregroundStyle(appState.themeColor)
//                    }
//                    .padding(.top, 60)
//
//                    Text("Barely Working")
//                        .font(.system(size: 30, weight: .heavy))
//                        .foregroundStyle(AppTheme.textPrimary)
//
//                    Text("Your focus, your progress.")
//                        .font(.system(size: 15, weight: .medium))
//                        .foregroundStyle(AppTheme.textSecondary)
//                }
//                .padding(.bottom, 40)
//
//                // Form Card
//                VStack(spacing: 16) {
//                    VStack(spacing: 12) {
//                        AuthField(
//                            icon: "envelope.fill",
//                            placeholder: "Email",
//                            text: $email,
//                            isSecure: false,
//                            themeColor: appState.themeColor
//                        )
//                        .focused($focusedField, equals: .email)
//                        .submitLabel(.next)
//                        .onSubmit { focusedField = .password }
//
//                        AuthField(
//                            icon: "lock.fill",
//                            placeholder: "Password",
//                            text: $password,
//                            isSecure: true,
//                            themeColor: appState.themeColor
//                        )
//                        .focused($focusedField, equals: .password)
//                        .submitLabel(.done)
//                        .onSubmit { attemptLogin() }
//                    }
//
//                    if showError {
//                        Text(errorMsg)
//                            .font(.system(size: 13, weight: .semibold))
//                            .foregroundStyle(.red.opacity(0.8))
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .padding(.horizontal, 4)
//                    }
//
//                    Button(action: attemptLogin) {
//                        Text("Sign In")
//                            .font(.system(size: 16, weight: .bold))
//                            .foregroundStyle(.white)
//                            .frame(maxWidth: .infinity)
//                            .padding(.vertical, 16)
//                            .background(Capsule().fill(appState.themeColor))
//                            .shadow(color: appState.themeColor.opacity(0.3), radius: 10, x: 0, y: 6)
//                    }
//                    .buttonStyle(.plain)
//                    .padding(.top, 4)
//                }
//                .padding(20)
//                .background(
//                    RoundedRectangle(cornerRadius: 24)
//                        .fill(appState.themeColor.opacity(0.06))
//                )
//                .overlay(
//                    RoundedRectangle(cornerRadius: 24)
//                        .stroke(appState.themeColor.opacity(0.15), lineWidth: 1)
//                )
//                .padding(.horizontal, 20)
//
//                // Sign up link
//                HStack(spacing: 4) {
//                    Text("Don't have an account?")
//                        .font(.system(size: 14, weight: .medium))
//                        .foregroundStyle(AppTheme.textSecondary)
//                    Button("Sign Up") {
//                        showError = false
//                        showRegister = true
//                    }
//                    .font(.system(size: 14, weight: .bold))
//                    .foregroundStyle(appState.themeColor)
//                }
//                .padding(.top, 24)
//                .padding(.bottom, 40)
//            }
//        }
//        .background(appState.bgColor.ignoresSafeArea())
//        .onTapGesture { focusedField = nil }
//    }
//
//    private func attemptLogin() {
//        focusedField = nil
//        guard !email.isEmpty else {
//            errorMsg = "Please enter your email."
//            showError = true
//            return
//        }
//        guard !password.isEmpty else {
//            errorMsg = "Please enter your password."
//            showError = true
//            return
//        }
//        let success = appState.login(name: "", email: email, password: password)
//        if !success {
//            let emailLow = email.lowercased().trimmingCharacters(in: .whitespaces)
//            let passKey = "u:\(emailLow):password_hash"
//            if UserDefaults.standard.string(forKey: passKey) == nil {
//                errorMsg = "No account found with this email. Please sign up."
//            } else {
//                errorMsg = "Incorrect password. Please try again."
//            }
//            showError = true
//        }
//    }
//}
//
//// MARK: - Register
//
//struct RegisterView: View {
//    @EnvironmentObject var appState: AppState
//    @Binding var showRegister: Bool
//
//    @State private var name = ""
//    @State private var email = ""
//    @State private var password = ""
//    @State private var confirmPassword = ""
//    @State private var showError = false
//    @State private var errorMsg = ""
//    @FocusState private var focusedField: Field?
//
//    enum Field { case name, email, password, confirm }
//
//    var body: some View {
//        ScrollView(showsIndicators: false) {
//            VStack(spacing: 0) {
//
//                // Back button
//                HStack {
//                    Button {
//                        showRegister = false
//                    } label: {
//                        Image(systemName: "chevron.left")
//                            .font(.system(size: 18, weight: .semibold))
//                            .foregroundStyle(appState.themeColor)
//                    }
//                    Spacer()
//                }
//                .padding(.horizontal, 24)
//                .padding(.top, 56)
//
//                // Header
//                VStack(spacing: 6) {
//                    Text("Create Account")
//                        .font(.system(size: 28, weight: .heavy))
//                        .foregroundStyle(AppTheme.textPrimary)
//                    Text("Start your focus journey today.")
//                        .font(.system(size: 15, weight: .medium))
//                        .foregroundStyle(AppTheme.textSecondary)
//                }
//                .padding(.top, 16)
//                .padding(.bottom, 32)
//
//                // Form Card
//                VStack(spacing: 14) {
//                    AuthField(icon: "person.fill", placeholder: "Full Name", text: $name, isSecure: false, themeColor: appState.themeColor)
//                        .focused($focusedField, equals: .name)
//                        .submitLabel(.next)
//                        .onSubmit { focusedField = .email }
//
//                    AuthField(icon: "envelope.fill", placeholder: "Email", text: $email, isSecure: false, themeColor: appState.themeColor)
//                        .focused($focusedField, equals: .email)
//                        .submitLabel(.next)
//                        .onSubmit { focusedField = .password }
//
//                    AuthField(icon: "lock.fill", placeholder: "Password (min 6 chars)", text: $password, isSecure: true, themeColor: appState.themeColor)
//                        .focused($focusedField, equals: .password)
//                        .submitLabel(.next)
//                        .onSubmit { focusedField = .confirm }
//
//                    AuthField(icon: "lock.shield.fill", placeholder: "Confirm Password", text: $confirmPassword, isSecure: true, themeColor: appState.themeColor)
//                        .focused($focusedField, equals: .confirm)
//                        .submitLabel(.done)
//                        .onSubmit { attemptRegister() }
//
//                    if showError {
//                        Text(errorMsg)
//                            .font(.system(size: 13, weight: .semibold))
//                            .foregroundStyle(.red.opacity(0.8))
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .padding(.horizontal, 4)
//                    }
//
//                    Button(action: attemptRegister) {
//                        Text("Create Account")
//                            .font(.system(size: 16, weight: .bold))
//                            .foregroundStyle(.white)
//                            .frame(maxWidth: .infinity)
//                            .padding(.vertical, 16)
//                            .background(Capsule().fill(appState.themeColor))
//                            .shadow(color: appState.themeColor.opacity(0.3), radius: 10, x: 0, y: 6)
//                    }
//                    .buttonStyle(.plain)
//                    .padding(.top, 4)
//                }
//                .padding(20)
//                .background(
//                    RoundedRectangle(cornerRadius: 24)
//                        .fill(appState.themeColor.opacity(0.06))
//                )
//                .overlay(
//                    RoundedRectangle(cornerRadius: 24)
//                        .stroke(appState.themeColor.opacity(0.15), lineWidth: 1)
//                )
//                .padding(.horizontal, 20)
//
//                // Sign in link
//                HStack(spacing: 4) {
//                    Text("Already have an account?")
//                        .font(.system(size: 14, weight: .medium))
//                        .foregroundStyle(AppTheme.textSecondary)
//                    Button("Sign In") {
//                        showRegister = false
//                    }
//                    .font(.system(size: 14, weight: .bold))
//                    .foregroundStyle(appState.themeColor)
//                }
//                .padding(.top, 24)
//                .padding(.bottom, 40)
//            }
//        }
//        .background(appState.bgColor.ignoresSafeArea())
//        .onTapGesture { focusedField = nil }
//    }
//
//    private func attemptRegister() {
//        focusedField = nil
//        guard !name.isEmpty else {
//            errorMsg = "Please enter your name."
//            showError = true
//            return
//        }
//        guard !email.isEmpty else {
//            errorMsg = "Please enter your email."
//            showError = true
//            return
//        }
//        guard password.count >= 6 else {
//            errorMsg = "Password must be at least 6 characters."
//            showError = true
//            return
//        }
//        guard password == confirmPassword else {
//            errorMsg = "Passwords do not match."
//            showError = true
//            return
//        }
//        let emailLow = email.lowercased().trimmingCharacters(in: .whitespaces)
//        if UserDefaults.standard.string(forKey: "u:\(emailLow):password_hash") != nil {
//            errorMsg = "This email is already registered. Please sign in."
//            showError = true
//            return
//        }
//        let success = appState.register(name: name, email: email, password: password)
//        if !success {
//            errorMsg = "Registration failed. Please try again."
//            showError = true
//        }
//    }
//}
//
//// MARK: - Auth Field
//
//struct AuthField: View {
//    let icon: String
//    let placeholder: String
//    @Binding var text: String
//    let isSecure: Bool
//    var themeColor: Color = AppTheme.primary
//    @State private var showPassword = false
//
//    var body: some View {
//        HStack(spacing: 12) {
//            Image(systemName: icon)
//                .font(.system(size: 16, weight: .semibold))
//                .foregroundStyle(themeColor.opacity(0.7))
//                .frame(width: 20)
//
//            if isSecure && !showPassword {
//                SecureField(placeholder, text: $text)
//                    .font(.system(size: 15, weight: .medium))
//                    .foregroundColor(AppTheme.textPrimary)
//            } else {
//                TextField(placeholder, text: $text)
//                    .font(.system(size: 15, weight: .medium))
//                    .foregroundColor(AppTheme.textPrimary)
//                    .autocapitalization(.none)
//                    .keyboardType(placeholder.lowercased().contains("email") ? .emailAddress : .default)
//            }
//
//            if isSecure {
//                Button {
//                    showPassword.toggle()
//                } label: {
//                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
//                        .font(.system(size: 14, weight: .semibold))
//                        .foregroundStyle(themeColor.opacity(0.5))
//                }
//            }
//        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 14)
//        .background(
//            RoundedRectangle(cornerRadius: 14)
//                .fill(themeColor.opacity(0.08))
//        )
//        .overlay(
//            RoundedRectangle(cornerRadius: 14)
//                .stroke(themeColor.opacity(0.2), lineWidth: 1)
//        )
//    }
//}



//////////////////////////////

import SwiftUI

// MARK: - Auth Root

struct AuthView: View {
    @EnvironmentObject var appState: AppState
    @State private var showRegister = false

    var body: some View {
        ZStack {
            appState.bgColor.ignoresSafeArea()

            if showRegister {
                RegisterView(showRegister: $showRegister)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .trailing)
                    ))
            } else {
                LoginView(showRegister: $showRegister)
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading),
                        removal: .move(edge: .leading)
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showRegister)
    }
}

// MARK: - Login

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @Binding var showRegister: Bool

    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMsg = ""
    @State private var showForgotPassword = false
    @FocusState private var focusedField: Field?

    enum Field { case email, password }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // Header
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(appState.themeColor.opacity(0.12))
                            .frame(width: 80, height: 80)
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundStyle(appState.themeColor)
                    }
                    .padding(.top, 60)

                    Text("Barely Working")
                        .font(.system(size: 30, weight: .heavy))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text("Your focus, your progress.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .padding(.bottom, 40)

                // Form Card
                VStack(spacing: 16) {
                    VStack(spacing: 12) {
                        AuthField(
                            icon: "envelope.fill",
                            placeholder: "Email",
                            text: $email,
                            isSecure: false,
                            themeColor: appState.themeColor
                        )
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .password }

                        AuthField(
                            icon: "lock.fill",
                            placeholder: "Password",
                            text: $password,
                            isSecure: true,
                            themeColor: appState.themeColor
                        )
                        .focused($focusedField, equals: .password)
                        .submitLabel(.done)
                        .onSubmit { attemptLogin() }
                    }

                    if showError {
                        Text(errorMsg)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.red.opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                    }

                    Button(action: attemptLogin) {
                        Text("Sign In")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Capsule().fill(appState.themeColor))
                            .shadow(color: appState.themeColor.opacity(0.3), radius: 10, x: 0, y: 6)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)

                    // Forgot Password
                    Button("Forgot Password?") {
                        showError = false
                        showForgotPassword = true
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(appState.themeColor.opacity(0.8))
                    .padding(.top, 2)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(appState.themeColor.opacity(0.06))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(appState.themeColor.opacity(0.15), lineWidth: 1)
                )
                .padding(.horizontal, 20)

                // Sign up link
                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                    Button("Sign Up") {
                        showError = false
                        showRegister = true
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(appState.themeColor)
                }
                .padding(.top, 24)
                .padding(.bottom, 40)
            }
        }
        .background(appState.bgColor.ignoresSafeArea())
        .onTapGesture { focusedField = nil }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
                .environmentObject(appState)
        }
    }

    private func attemptLogin() {
        focusedField = nil
        guard !email.isEmpty else {
            errorMsg = "Please enter your email."
            showError = true
            return
        }
        guard !password.isEmpty else {
            errorMsg = "Please enter your password."
            showError = true
            return
        }
        let success = appState.login(name: "", email: email, password: password)
        if !success {
            let emailLow = email.lowercased().trimmingCharacters(in: .whitespaces)
            let passKey = "u:\(emailLow):password_hash"
            if UserDefaults.standard.string(forKey: passKey) == nil {
                errorMsg = "No account found with this email. Please sign up."
            } else {
                errorMsg = "Incorrect password. Please try again."
            }
            showError = true
        }
    }
}

// MARK: - Register

struct RegisterView: View {
    @EnvironmentObject var appState: AppState
    @Binding var showRegister: Bool

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showError = false
    @State private var errorMsg = ""
    @FocusState private var focusedField: Field?

    enum Field { case name, email, password, confirm }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // Back button
                HStack {
                    Button {
                        showRegister = false
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(appState.themeColor)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 56)

                // Header
                VStack(spacing: 6) {
                    Text("Create Account")
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text("Start your focus journey today.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .padding(.top, 16)
                .padding(.bottom, 32)

                // Form Card
                VStack(spacing: 14) {
                    AuthField(icon: "person.fill", placeholder: "Full Name", text: $name, isSecure: false, themeColor: appState.themeColor)
                        .focused($focusedField, equals: .name)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .email }

                    AuthField(icon: "envelope.fill", placeholder: "Email", text: $email, isSecure: false, themeColor: appState.themeColor)
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .password }

                    AuthField(icon: "lock.fill", placeholder: "Password (min 6 chars)", text: $password, isSecure: true, themeColor: appState.themeColor)
                        .focused($focusedField, equals: .password)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .confirm }

                    AuthField(icon: "lock.shield.fill", placeholder: "Confirm Password", text: $confirmPassword, isSecure: true, themeColor: appState.themeColor)
                        .focused($focusedField, equals: .confirm)
                        .submitLabel(.done)
                        .onSubmit { attemptRegister() }

                    if showError {
                        Text(errorMsg)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.red.opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                    }

                    Button(action: attemptRegister) {
                        Text("Create Account")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Capsule().fill(appState.themeColor))
                            .shadow(color: appState.themeColor.opacity(0.3), radius: 10, x: 0, y: 6)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(appState.themeColor.opacity(0.06))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(appState.themeColor.opacity(0.15), lineWidth: 1)
                )
                .padding(.horizontal, 20)

                // Sign in link
                HStack(spacing: 4) {
                    Text("Already have an account?")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                    Button("Sign In") {
                        showRegister = false
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(appState.themeColor)
                }
                .padding(.top, 24)
                .padding(.bottom, 40)
            }
        }
        .background(appState.bgColor.ignoresSafeArea())
        .onTapGesture { focusedField = nil }
    }

    private func attemptRegister() {
        focusedField = nil
        guard !name.isEmpty else {
            errorMsg = "Please enter your name."
            showError = true
            return
        }
        guard !email.isEmpty else {
            errorMsg = "Please enter your email."
            showError = true
            return
        }
        guard password.count >= 6 else {
            errorMsg = "Password must be at least 6 characters."
            showError = true
            return
        }
        guard password == confirmPassword else {
            errorMsg = "Passwords do not match."
            showError = true
            return
        }
        let emailLow = email.lowercased().trimmingCharacters(in: .whitespaces)
        if UserDefaults.standard.string(forKey: "u:\(emailLow):password_hash") != nil {
            errorMsg = "This email is already registered. Please sign in."
            showError = true
            return
        }
        let success = appState.register(name: name, email: email, password: password)
        if !success {
            errorMsg = "Registration failed. Please try again."
            showError = true
        }
    }
}

// MARK: - Auth Field

struct AuthField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool
    var themeColor: Color = AppTheme.primary
    @State private var showPassword = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(themeColor.opacity(0.7))
                .frame(width: 20)

            if isSecure && !showPassword {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)
                    .autocapitalization(.none)
                    .keyboardType(placeholder.lowercased().contains("email") ? .emailAddress : .default)
            }

            if isSecure {
                Button {
                    showPassword.toggle()
                } label: {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(themeColor.opacity(0.5))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(themeColor.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(themeColor.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Forgot Password

struct ForgotPasswordView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showError = false
    @State private var errorMsg = ""
    @State private var showSuccess = false
    @FocusState private var focusedField: Field?

    enum Field { case email, newPassword, confirm }

    var body: some View {
        ZStack {
            appState.bgColor.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // Header
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(appState.themeColor)
                                .padding(10)
                                .background(Circle().fill(appState.themeColor.opacity(0.10)))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(appState.themeColor.opacity(0.12))
                                .frame(width: 72, height: 72)
                            Image(systemName: "key.fill")
                                .font(.system(size: 30, weight: .semibold))
                                .foregroundStyle(appState.themeColor)
                        }
                        .padding(.top, 16)

                        Text("Reset Password")
                            .font(.system(size: 26, weight: .heavy))
                            .foregroundStyle(AppTheme.textPrimary)

                        Text("Enter your email and choose a new password.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 32)

                    // Form Card
                    VStack(spacing: 14) {
                        AuthField(
                            icon: "envelope.fill",
                            placeholder: "Registered Email",
                            text: $email,
                            isSecure: false,
                            themeColor: appState.themeColor
                        )
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .newPassword }

                        AuthField(
                            icon: "lock.fill",
                            placeholder: "New Password (min 6 chars)",
                            text: $newPassword,
                            isSecure: true,
                            themeColor: appState.themeColor
                        )
                        .focused($focusedField, equals: .newPassword)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .confirm }

                        AuthField(
                            icon: "lock.shield.fill",
                            placeholder: "Confirm New Password",
                            text: $confirmPassword,
                            isSecure: true,
                            themeColor: appState.themeColor
                        )
                        .focused($focusedField, equals: .confirm)
                        .submitLabel(.done)
                        .onSubmit { attemptReset() }

                        if showError {
                            Text(errorMsg)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.red.opacity(0.8))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 4)
                        }

                        if showSuccess {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                Text("Password updated! You can now sign in.")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.green)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                        }

                        Button(action: attemptReset) {
                            Text("Reset Password")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Capsule().fill(appState.themeColor))
                                .shadow(color: appState.themeColor.opacity(0.3), radius: 10, x: 0, y: 6)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 4)
                        .disabled(showSuccess)
                        .opacity(showSuccess ? 0.5 : 1.0)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(appState.themeColor.opacity(0.06))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(appState.themeColor.opacity(0.15), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)

                    if showSuccess {
                        Button("Back to Sign In") {
                            dismiss()
                        }
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(appState.themeColor)
                        .padding(.top, 24)
                    }

                    Spacer().frame(height: 40)
                }
            }
            .onTapGesture { focusedField = nil }
        }
    }

    private func attemptReset() {
        focusedField = nil
        showError = false
        showSuccess = false

        guard !email.isEmpty else {
            errorMsg = "Please enter your email."
            showError = true
            return
        }
        guard newPassword.count >= 6 else {
            errorMsg = "New password must be at least 6 characters."
            showError = true
            return
        }
        guard newPassword == confirmPassword else {
            errorMsg = "Passwords do not match."
            showError = true
            return
        }

        let emailLow = email.lowercased().trimmingCharacters(in: .whitespaces)
        let passKey = "u:\(emailLow):password_hash"
        if UserDefaults.standard.string(forKey: passKey) == nil {
            errorMsg = "No account found with this email."
            showError = true
            return
        }

        let success = appState.resetPassword(email: email, newPassword: newPassword)
        if success {
            showSuccess = true
        } else {
            errorMsg = "Reset failed. Please try again."
            showError = true
        }
    }
}
