import Foundation
import XCTest

@testable import MathParser

final class MathParserTests: XCTestCase {
    private var mathParser = LatexParser()

    func testMathRegex() {
        // Given
        let expectLatexes = [
            #"\lim_{x \to 1}\frac{f(x)}{\ln{}{x}} = 1"#,
            #"f(1)=0"#,
            #"\lim_{x \to 1 }f(x) = 0"#,
            #"{f}' (1) = 1"#,
            #"\lim_{x \to 1 }{f}'(x) = 1"#,
        ]

        let math = String(format: """
        1. ##### 设函数 *f(x)* 满足 $%@$，则 ()

           A. $%@$

           B. $%@$

           C. $%@$

           D. $%@$
        """, arguments: expectLatexes)

        // When
        let result = mathParser.regex.matches(in: math, range: .init(location: 0, length: math.count))

        // Then
        XCTAssertEqual(result.count, expectLatexes.count)

        zip(result, expectLatexes).forEach { item, expectLatex in
            let range = item.range(at: 2)
            let latex = math.subString(withNSRange: range)
            XCTAssertEqual(latex, expectLatex)
        }
    }
}
