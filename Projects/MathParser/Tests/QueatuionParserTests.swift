import Foundation
import Nimble
import Quick

@testable import MathParser

final class QuestionParserTests: QuickSpec {
    override func spec() {
        describe("question parser") {
            let parser = QuestionParser()
            var type: QuestionParser.QuestionType!

            describe("choice question") {
                type = .choice

                context("with empty value") {
                    let expectQuestion = "{choice id=5}{/choice}"
                    let math = generateMath(question: expectQuestion)
                    let result = type.regex.matches(in: math, range: .init(location: 0, length: math.count))

                    it("parsed result num and string should be equal") {
                        expect(result.count) == 1
                        let (param, value) = parser.paramAndValue(from: math, checkingResult: result[0])
                        expect(param) == "id=5"
                        expect(value).to(beEmpty())
                    }
                }

                context("with value") {
                    let expectQuestion = "{choice id=5}A{/choice}"
                    let math = generateMath(question: expectQuestion)
                    let result = type.regex.matches(in: math, range: .init(location: 0, length: math.count))

                    it("parsed result num and string should be equal") {
                        expect(result.count) == 1
                        let (param, value) = parser.paramAndValue(from: math, checkingResult: result[0])
                        expect(param) == "id=5"
                        expect(value) == "A"
                    }
                }

                context("with multiValue") {
                    let expectQuestions = ["{choice id=5}{/choice}", "{choice id=6}B{/choice}"]
                    let math = generateMath(questions: expectQuestions)
                    let result = type.regex.matches(in: math, range: .init(location: 0, length: math.count))

                    it("parsed result num and string should be equal") {
                        expect(result.count) == 2
                        [
                            ("id=5", ""),
                            ("id=6", "B"),
                        ]
                        .enumerated()
                        .forEach {
                            let (param, value) = parser.paramAndValue(from: math, checkingResult: result[$0.offset])
                            expect(param) == $0.element.0
                            expect(value) == $0.element.1
                        }
                    }
                }
            }
        }
    }

    func generateMath(question: String) -> String {
        String(format: #"""
        1. ##### 设函数 *f(x)* 满足 $\lim_{x \to 1}\frac{f(x)}{\ln{}{x}} = 1$，则 %@

           A. $f(1)=0$

           B. $\lim_{x \to 1 }f(x) = 0$

           C. ${f}' (1) = 1$

           D. $\lim_{x \to 1 }{f}'(x) = 1$
        """#, question)
    }

    func generateMath(questions: [String]) -> String {
        String(format: #"""
        1. ##### 设函数 *f(x)* 满足 $\lim_{x \to 1}\frac{f(x)}{\ln{}{x}} = 1$，则 %@

           A. $f(1)=0$

           B. $\lim_{x \to 1 }f(x) = 0$

           C. ${f}' (1) = 1$

           D. $\lim_{x \to 1 }{f}'(x) = 1$

        2. ##### 设函数$z=xyf(\frac{y}{x})$，其中 *f(u)* 可导，若$x\frac{\partial z}{\partial x} +y\frac{\partial z}{\partial y} = xy(\ln_{}{y} - \ln{}{x} )$，则 %@

           A. $f(1) = \frac{1}{2}, {f}'(1) = 0  $

           B. $f(1) = 0, {f}'(1) = \frac{1}{2}$

           C. $f(1) = \frac{1}{2}, {f}'(1) = 1$

           D. $f(1) = 0, {f}'(1) = 1$
        """#, arguments: questions)
    }
}
