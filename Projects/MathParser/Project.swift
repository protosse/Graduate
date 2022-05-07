import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - Project

let project = Project.common(
    name: "MathParser",
    product: .framework,
    organizationName: "doom",
    dependencies: [
        .external(name: "Down"),
        .external(name: "AttributedString"),
        .external(name: "iosMath"),
    ]
)
