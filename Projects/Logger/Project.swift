import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - Project

let project = Project.common(
    name: "Logger",
    product: .framework,
    organizationName: "doom",
    resources: nil,
    dependencies: [
        .external(name: "SwiftyBeaver"),
    ]
)
