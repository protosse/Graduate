import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - Project

let project = Project.common(
    name: "Graduate",
    product: .app,
    organizationName: "doom",
    infoPlist: [
        "UILaunchStoryboardName": "LaunchScreen",
        "UIUserInterfaceStyle": "Light",
        "NSAppTransportSecurity": .array([
            .dictionary([
                "NSAllowsArbitraryLoads": true,
            ]),
        ]),
    ],
    dependencies: [
        .external(name: "PinLayout"),
        .external(name: "Inject"),
    ],
    module: [
        "Networking",
        "Database",
        "MathParser",
        "Logger",
    ],
    settings: .settings(base: [
        "OTHER_LDFLAGS": "-Xlinker -interposable",
    ])
)
