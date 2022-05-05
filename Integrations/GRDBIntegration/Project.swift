import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - Project

let project = Project.common(
    name: "GRDBIntegration",
    product: .framework,
    organizationName: "doom",
    sources: nil,
    resources: nil,
    testSources: nil,
    dependencies: [
        .package(product: "GRDBContainer"),
    ],
    packages: [
        .local(path: "./GRDBContainer"),
    ]
)
