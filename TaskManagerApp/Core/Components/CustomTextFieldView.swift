//
//  CustomTextFieldView.swift
//  TaskManagerApp
//
//  Created by Ohiocheoya Emmanuel on 10/01/2026.
//

import SwiftUI
import Combine

struct CustomTextFieldView: View {
    var hintText: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var contentType: UITextContentType = .name
    var maxLength: Int? = nil
    var textCapitalization: TextInputAutocapitalization = .never
    
    var body: some View {
        TextField(hintText, text: $text)
            .textContentType(contentType)
            .keyboardType(keyboardType)
            .textInputAutocapitalization(textCapitalization)
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .onReceive(Just(text)) { _ in 
                if let maxLength = maxLength {
                    limitText(maxLength)
                }
            }
    }
    
    //Function to keep text length in limits
    func limitText(_ upper: Int) {
        if text.count > upper {
            text = String(text.prefix(upper))
        }
    }
}

#Preview {
    CustomTextFieldView(hintText: "", text: .constant(""))
}
