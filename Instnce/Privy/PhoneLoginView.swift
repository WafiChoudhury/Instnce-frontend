//
//  PhoneLoginView.swift
//  Instnce
//
//  Clean, trust-first phone login flow with proper phone formatting
//

import SwiftUI

struct PhoneLoginView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var countryCode = "+1"
    @State private var phoneNumber = ""
    @State private var otpCode = ""
    @State private var showOTPField = false
    @State private var isLoading = false
    @FocusState private var isFocused: Bool
    
    // Computed property for full formatted phone number
    private var fullPhoneNumber: String {
        let cleaned = phoneNumber.filter { $0.isNumber }
        return countryCode + cleaned
    }
    
    // Formatted display version
    private var displayPhoneNumber: String {
        let cleaned = phoneNumber.filter { $0.isNumber }
        guard !cleaned.isEmpty else { return "" }
        
        // Format as (XXX) XXX-XXXX for US numbers
        if countryCode == "+1" && cleaned.count == 10 {
            let areaCode = cleaned.prefix(3)
            let middle = cleaned.dropFirst(3).prefix(3)
            let last = cleaned.dropFirst(6)
            return "(\(areaCode)) \(middle)-\(last)"
        }
        
        return cleaned
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 32) {
                
                // MARK: Header
                VStack(alignment: .leading, spacing: 6) {
                    Text(showOTPField ? "Verify your code" : "Sign in with your phone")
                        .font(.system(size: 28, weight: .bold))
                    
                    Text(showOTPField
                         ? "We've sent a 6-digit code to \(countryCode) \(displayPhoneNumber)"
                         : "Enter your phone number to continue")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                }
                .padding(.top, 32)
                .padding(.horizontal)
                
                // MARK: Form
                VStack(spacing: 24) {
                    if !showOTPField {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Phone number")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.secondary)
                            
                            HStack(spacing: 12) {
                                // Country Code Picker
                                Menu {
                                    Button("+1 (US/Canada)") { countryCode = "+1" }
                                    Button("+44 (UK)") { countryCode = "+44" }
                                    Button("+91 (India)") { countryCode = "+91" }
                                    Button("+86 (China)") { countryCode = "+86" }
                                    Button("+81 (Japan)") { countryCode = "+81" }
                                    Button("+49 (Germany)") { countryCode = "+49" }
                                    Button("+33 (France)") { countryCode = "+33" }
                                    Button("+61 (Australia)") { countryCode = "+61" }
                                } label: {
                                    HStack {
                                        Text(countryCode)
                                            .font(.system(size: 17))
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12))
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 4)
                                }
                                
                                Divider()
                                    .frame(height: 24)
                                
                                // Phone Number Input
                                TextField("555 123 4567", text: $phoneNumber)
                                    .keyboardType(.phonePad)
                                    .textContentType(.telephoneNumber)
                                    .font(.system(size: 17))
                                    .focused($isFocused)
                                    .onChange(of: phoneNumber) { _, newValue in
                                        // Keep only digits
                                        let filtered = newValue.filter { $0.isNumber }
                                        if filtered != newValue {
                                            phoneNumber = filtered
                                        }
                                        // Limit length based on country
                                        let maxLength = countryCode == "+1" ? 10 : 15
                                        if filtered.count > maxLength {
                                            phoneNumber = String(filtered.prefix(maxLength))
                                        }
                                    }
                            }
                            .padding(.vertical, 8)
                            
                            Divider()
                            
                            // Show formatted preview
                            if !phoneNumber.isEmpty {
                                Text("Will send to: \(fullPhoneNumber)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 4)
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Verification code")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.secondary)
                            
                            TextField("123456", text: $otpCode)
                                .keyboardType(.numberPad)
                                .textContentType(.oneTimeCode)
                                .font(.system(size: 24, weight: .semibold, design: .monospaced))
                                .multilineTextAlignment(.leading)
                                .focused($isFocused)
                                .padding(.vertical, 8)
                                .onChange(of: otpCode) { _, newValue in
                                    // Keep only digits, max 6
                                    let filtered = newValue.filter { $0.isNumber }
                                    if filtered.count > 6 {
                                        otpCode = String(filtered.prefix(6))
                                    } else if filtered != newValue {
                                        otpCode = filtered
                                    }
                                }
                            
                            Divider()
                            
                            Button("Resend code") {
                                sendCode()
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondary)
                            .padding(.top, 4)
                            .disabled(isLoading)
                        }
                        .padding(.horizontal)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .animation(.easeInOut(duration: 0.25), value: showOTPField)
                
                Spacer()
                
                // MARK: Buttons
                VStack(spacing: 16) {
                    Button {
                        if showOTPField {
                            verifyCode()
                        } else {
                            sendCode()
                        }
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(.circular)
                            } else {
                                Text(showOTPField ? "Verify" : "Continue")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(isButtonEnabled ? Color.primary.opacity(0.9) : Color.primary.opacity(0.3))
                        .foregroundStyle(Color(.systemBackground))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    .disabled(!isButtonEnabled)
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Computed Properties
    
    private var isButtonEnabled: Bool {
        if isLoading { return false }
        
        if showOTPField {
            return otpCode.count == 6
        } else {
            let cleaned = phoneNumber.filter { $0.isNumber }
            // US/Canada needs exactly 10 digits
            if countryCode == "+1" {
                return cleaned.count == 10
            }
            // Other countries need at least 6 digits
            return cleaned.count >= 6
        }
    }
    
    // MARK: - Actions
    
    private func sendCode() {
        isLoading = true
        Task {
            // Send the fully formatted number with country code
            let success = await authViewModel.sendPhoneCode(phoneNumber: fullPhoneNumber)
            await MainActor.run {
                isLoading = false
                if success {
                    withAnimation {
                        showOTPField = true
                    }
                    isFocused = true
                }
            }
        }
    }
    
    private func verifyCode() {
        isLoading = true
        Task {
            // Use the same formatted number for verification
            print(fullPhoneNumber)
            print(otpCode)
            let success = await authViewModel.loginWithPhoneCode(phoneNumber: fullPhoneNumber, code: otpCode)
            await MainActor.run {
                isLoading = false
                if success {
                    dismiss()
                } else {
                    
                    otpCode = ""
                }
            }
        }
    }
}
