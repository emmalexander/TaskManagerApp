//
//  VerificationTextField.swift
//  TaskManagerApp
//
//  Created by Ohiocheoya Emmanuel on 25/03/2026.
//

import SwiftUI

enum TypingState {
    case typing
    case valid
    case invalid
}

struct VerificationTextField: View {
    @StateObject var viewModel: OTPViewModel
    
    @Binding var value: String
    //@State private var invalidTrigger: Bool = false
    
    var onChange: (String) async -> TypingState
    
    @FocusState private var isActive: Bool
    
    var body: some View {
        HStack (spacing: 6){
            ForEach(0..<6, id: \.self) { index in
                CharacterView(index)
            }
        }
        .animation(.easeIn(duration: 0.2), value: value)
        .animation(.easeIn(duration: 0.2), value: isActive)
        .compositingGroup()
        /// Invalid Phase animator
        .phaseAnimator([0, 10, -10, 10, -5, 5, 0], trigger: viewModel.invalidOTPTrigger, content: { content, offset in
            content
                .offset(x: offset)
        }, animation: { _ in
                .linear(duration: 0.06)
        })
        
        .background {
            TextField("", text: $value)
                .focused($isActive)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .mask(alignment: .trailing) {
                    Rectangle()
                        .frame(width: 1, height: 1)
                        .opacity(0.001)
                }
                .allowsHitTesting(false)
        }
        .contentShape(.rect)
        .onTapGesture {
            isActive = true
        }
        .onChange(of: value) { oldValue, newValue in
            /// Limit text length
            value = String(newValue.prefix(6))
            
            Task { @MainActor in
                /// Validation Checks
                viewModel.state = await onChange(value)
                if viewModel.state == .invalid {
                    viewModel.invalidOTPTrigger.toggle()
                }
            }
        }
    }
    
    @ViewBuilder
    func CharacterView(_ index: Int) -> some View {
        Group {
            RoundedRectangle(cornerRadius: 10)
                .stroke(borderColor(index), lineWidth: 1.2)
        }
        .frame(width: 50, height: 50)
        .overlay {
            let stringValue = string(index)
            
            if stringValue != "" {
                    Text(stringValue)
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .fontWeight(.semibold)
                        .transition(.blurReplace)
            }
        }
    }
    
    func string(_ index: Int) -> String {
        if value.count > index {
            let startIndex = value.startIndex
            let stringIndex = value.index(startIndex, offsetBy: index)
            
            return String(value[stringIndex])
        }
        
        return ""
    }
    
    func borderColor(_ index: Int) -> Color {
        switch viewModel.state {
        case .typing: value.count == index ? Color.primary : .gray
        case .valid: .green
        case .invalid: .red
        }
    }
}

#Preview {
    VerificationTextField(viewModel: OTPViewModel(email: "example@gmail.com") ,value: .constant("023456"), onChange: { changedValue in
        if changedValue.count < 6 {
            return .typing
        } else if changedValue == "123456"{
            return .valid
        } else {
            return .invalid
        }
    })
}
