import AttributedString
import Down
import Foundation
import MathRender

public class MathParser {
    public enum Style: String {
        case `default`
        case default_dark

        public var css: String? {
            if let path = Bundle.module.path(forResource: "\(self)", ofType: "css"),
               let content = try? String(contentsOfFile: path) {
                return content
            }
            return nil
        }
    }

    public var style: Style

    private var regexMath = try! NSRegularExpression(pattern: "(?<!\\$)(\\${1,3})([^\\$\n]+?)\\1(?!\\$)", options: [])

    public init(style: Style = .default) {
        self.style = style
    }

    public func parse(string: String) -> NSAttributedString? {
        let down = Down(markdownString: string)
        guard let re = try? down.toAttributedString(.default, stylesheet: style.css) else {
            return nil
        }

        let attr = NSMutableAttributedString(attributedString: re)
        let str = attr.string

        var cutLength: Int = 0
        let label = MTMathUILabel()
        label.contentInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        regexMath.enumerateMatches(in: str, range: NSRange(location: 0, length: str.count)) { result, _, _ in
            if let result = result, result.range.length > 0, result.numberOfRanges > 2 {
                var range = result.range
                range.location -= cutLength
                let textColor = attr.attribute(.foregroundColor, at: range.location, effectiveRange: nil) as? UIColor ?? .black
                let font = attr.attribute(.font, at: range.location, effectiveRange: nil) as? UIFont ?? .systemFont(ofSize: 15)

                let latex = str.subString(withNSRange: result.range(at: 2))
                label.textColor = textColor
                label.fontSize = font.pointSize + 3
                label.latex = renderLatex(latex)
                label.sizeToFit()

                if let image = getImage(from: label) {
                    let icon = NSTextAttachment(image: image)
                    icon.bounds = CGRect(
                        x: 0,
                        y: (font.capHeight - image.size.height).rounded() / 2,
                        width: image.size.width,
                        height: image.size.height
                    )
                    let iconString = NSAttributedString(attachment: icon)
                    attr.replaceCharacters(in: range, with: iconString)
                    cutLength += range.length - 1
                }
            }
        }
        return attr
    }

    /// 有些需要特殊处理
    ///
    ///     1. n阶矩阵，\begin{bmatrix} A & O \\ E & B\end{bmatrix}y=0
    ///         最里面的\\不会被转义，这里要手动替换为\\\\
    private func renderLatex(_ latex: String) -> String {
        var latex = latex
        if latex.hasPrefix(#"\begin{bmatrix}"#) {
            latex = latex.replacingOccurrences(of: #"(?<=\s)\\(?=\s+)"#, with: #"\\\\"#, options: .regularExpression)
        }
        return latex
    }

    private func getImage(from label: MTMathUILabel) -> UIImage? {
        let size = CGSize(width: label.bounds.size.width, height: label.bounds.size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        let verticalFlip = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: label.frame.size.height)
        context.concatenate(verticalFlip)
        label.layer.render(in: context)
        guard let image = UIGraphicsGetImageFromCurrentImageContext(), let cgImage = image.cgImage else {
            return nil
        }
        UIGraphicsEndImageContext()
        return UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: image.imageOrientation)
    }
}

extension String {
    public func subString(withNSRange range: NSRange) -> String {
        return subString(start: range.location, end: range.location + range.length)
    }

    public func subString(start: Int, end: Int) -> String {
        #if swift(>=5.0)
            let startIndex = String.Index(utf16Offset: start, in: self)
            let endIndex = String.Index(utf16Offset: end, in: self)
        #else
            let startIndex = String.Index(encodedOffset: start)
            let endIndex = String.Index(encodedOffset: end)
        #endif
        return String(self[startIndex ..< endIndex])
    }
}
