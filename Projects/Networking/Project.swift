import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - Project

let project = Project.common(
    name: "Networking",
    product: .framework,
    organizationName: "doom",
    resources: nil,
    dependencies: [
        .external(name: "Moya"),
        .external(name: "CombineMoya"),
        .external(name: "SwiftyJSON"),
    ],
    module: [
        "Logger",
    ]
)
