import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - Project

let project = Project.common(
    name: "Database",
    product: .framework,
    organizationName: "doom",
    resources: nil,
    dependencies: [
        .external(name: "GRDB"),
    ],
    module: [
        "Logger"
    ]
)
