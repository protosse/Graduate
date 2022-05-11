import AttributedString
import SwiftUI
import UIKit

public struct AttributedText: UIViewRepresentable {
    @Binding var attributedText: ASAttributedString

    public init(_ attributedText: Binding<ASAttributedString>) {
        _attributedText = attributedText
    }

    public func makeUIView(context _: Context) -> UITextView {
        let textView = UITextView()
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        return textView
    }

    public func updateUIView(_ uiView: UITextView, context _: Context) {
        uiView.attributed.text = attributedText
    }
}
