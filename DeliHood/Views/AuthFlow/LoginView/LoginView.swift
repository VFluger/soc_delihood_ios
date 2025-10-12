//
//  LoginView.swift
//  LoginTestApp
//
//  Created by Vojta Fluger on 11.08.2025.
//

import SwiftUI

enum FocusedField {
    case email
    case password
}

struct LoginView: View {
    @EnvironmentObject var authStore: AuthStore
    
    @StateObject var vm = LoginViewModel()
    
    private var notificationFeedback = UINotificationFeedbackGenerator()
    
    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
        NavigationStack {
            Text("Log in")
                .font(.largeTitle)
                .bold()
                .padding()
            
            Text("Log back into your account,\n and order delicious food.")
                .multilineTextAlignment(.center)
            Spacer()
                .frame(height: 40)
            OAuthView(parentVm: vm)
            Spacer()
                .frame(height: 40)
            
            EmailTextView(vm: vm, focusedField: $focusedField)
            
            PasswordTextView(authStore: authStore, vm: vm, focusedField: $focusedField)
            
            Button {
                vm.isForgottenSheetPresented.toggle()
            }label: {
                Text("Forgot your password?")
                    .padding()
                    .foregroundStyle(.primary)
            }
            
            Button {
                Task {
                    await vm.loginUser()
                    await authStore.updateState()
                }
            }label: {
                Text("Sign in")
                    .frame(width: 325)
                    .font(.title2)
                    .padding()
                    .foregroundStyle(Color.label)
                    .bold()
                    .brandGlassEffect(interactive: vm.canProceed)
                    .opacity(vm.canProceed ? 1 : 0.5)
            }
            .disabled(!vm.canProceed)
            
            Spacer()
        }
        .sheet(isPresented: $vm.isForgottenSheetPresented) {
            ForgottenPasswordView(isPresented: $vm.isForgottenSheetPresented)
        }
        .alert(item: $vm.alertItem) {alert in
            notificationFeedback.notificationOccurred(.warning)
            return Alert(title: Text(alert.title), message: Text(alert.message), dismissButton: .default(Text("Ok")))
            
        }
        .noConnectionOverlay($vm.hasNoConnection, retryFnc: vm.loginUser)
        
    }
}

struct EmailTextView: View {
    @ObservedObject var vm: LoginViewModel
    
    @FocusState.Binding var focusedField: FocusedField?
    
    var body: some View {
        TextField("Email", text: $vm.email)
            .brandStyle(isFieldValid: vm.isEmailValid)
            .textContentType(.emailAddress)
            .focused($focusedField, equals: .email)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .onChange(of: vm.email) {oldValue, newValue in
                withAnimation(.easeOut(duration: 0.5)) {
                    if newValue.isEmpty {
                        vm.isEmailValid = true
                        return
                    }
                    
                    vm.isEmailValid = Validator.validateEmail(newValue)
                }
            }
            .onSubmit {
                focusedField = .password
            }
            .submitLabel(.next)
        FieldWarningView(isFieldValid: vm.isEmailValid,
                         warningText: WarningMessages.emailWarningText)
    }
}

struct PasswordTextView: View {
    @ObservedObject var authStore: AuthStore
    @ObservedObject var vm: LoginViewModel
    
    @FocusState.Binding var focusedField: FocusedField?
    
    var body: some View {
        SecureField("Password", text: $vm.password)
            .brandStyle(isFieldValid: vm.isPasswordValid)
            .textContentType(.password)
            .focused($focusedField, equals: .password)
            .onChange(of: vm.password) {oldValue, newValue in
                withAnimation(.easeOut(duration: 0.5)) {
                    if newValue.isEmpty {
                        vm.isPasswordValid = true
                        return
                    }
                    
                    vm.isPasswordValid = Validator.validatePassword(newValue)
                }
            }
            .onSubmit {
                focusedField = nil
                //SUBMIT
                Task {
                    await vm.loginUser()
                    try await Task.sleep(nanoseconds: 50000000)
                    await authStore.updateState()
                }
            }
            .submitLabel(.send)
        FieldWarningView(isFieldValid: vm.isPasswordValid, warningText: WarningMessages.passwordWarningText)
    }
}



#Preview {
    LoginView()
        .environmentObject(AuthStore())
}

