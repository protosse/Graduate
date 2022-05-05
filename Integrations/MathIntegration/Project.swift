import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - Project

let project = Project.common(
    name: "MathIntegration",
    product: .framework,
    organizationName: "doom",
    sources: nil,
    resources: nil,
    testSources: nil,
    dependencies: [
        .package(product: "MathContainer"),
    ],
    packages: [
        .local(path: "./MathContainer"),
    ]
)
