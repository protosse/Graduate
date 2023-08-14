import AttributedString
import Down
import Foundation
import iosMath
import UIKit

public class LatexParser: MathParserProtocol {
    var regex = try! NSRegularExpression(pattern: #"(\$)(.*?)\1"#, options: [])

    public init() {}

    public func parseText(_ text: ASAttributedString) -> ASAttributedString {
        var text = text
        let str = text.value.string

        var cutLength = 0
        let label = MTMathUILabel()
        label.contentInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        regex.enumerateMatches(in: str, range: NSRange(location: 0, length: str.count)) { result, _, _ in
            if let result = result, result.range.length > 0, result.numberOfRanges > 2 {
                var range = result.range
                range.location -= cutLength
                let textColor = text.value.foregroundColor(at: range.location)
                let font = text.value.font(at: range.location)

                let latex = latex(from: str, checkingResult: result)
                label.textColor = textColor
                label.fontSize = font.pointSize + 3
                label.latex = renderLatex(latex)
                label.sizeToFit()

                if let image = getImage(from: label) {
                    let imageString = ASAttributedString(.image(image, .original(.center)))
                    text.replace(in: range, with: imageString)
                    cutLength += range.length - 1
                }
            }
        }

        return text
    }

    func latex(from string: String, checkingResult: NSTextCheckingResult) -> String {
        string.subString(withNSRange: checkingResult.range(at: 2))
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

    private func getImage(from label: MTMathUILabel, size: CGSize? = nil) -> UIImage? {
        let size = size ?? CGSize(width: label.bounds.size.width, height: label.bounds.size.height)
        guard !size.equalTo(.zero) else {
            return nil
        }
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
