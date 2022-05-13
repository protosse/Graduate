import Foundation
import Nimble
import Quick

@testable import MathParser

final class LatexParserTests: QuickSpec {
    override func spec() {
        describe("latex parse") {
            let latexParser = LatexParser()
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

            context("with multi") {
                let result = latexParser.regex.matches(in: math, range: .init(location: 0, length: math.count))

                it("parsed result num and string should be equal") {
                    expect(result.count) == expectLatexes.count
                    zip(result, expectLatexes).forEach { item, expectLatex in
                        let latex = latexParser.latex(from: math, checkingResult: item)
                        expect(latex) == expectLatex
                    }
                }
            }
        }
    }
}
