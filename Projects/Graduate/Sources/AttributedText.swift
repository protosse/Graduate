import SwiftUI
import UIKit

public struct AttributedText: UIViewRepresentable {
    @Binding var attributedText: NSAttributedString

    public init(_ attributedText: Binding<NSAttributedString>) {
        _attributedText = attributedText
    }

    public func makeUIView(context _: Context) -> UITextView {
        let textView = UITextView()
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        return textView
    }

    public func updateUIView(_ uiView: UITextView, context _: Context) {
        uiView.attributedText = attributedText
    }
}
