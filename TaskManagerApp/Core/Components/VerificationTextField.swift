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
    @State private var state: TypingState = .typing
    var body: some View {
        HStack (spacing: 6){
            ForEach(0..<6, id: \.self) { index in
                <#code#>
            }
        }
    }
    
    @ViewBuilder
    func CharacterView(_ index: Int) -> some View {
        Group {
            RoundedRectangle(cornerRadius: 10)
                .stroke(borderColor(index), lineWidth: 1.2)
        }
    }
    
    func borderColor(_ index: Int) -> Color {
        switch state {
        case .typing: .gray
        case .valid: .green
        case .invalid: .red
        }
    }
}

#Preview {
    VerificationTextField()
}
