import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - Project

let otherTargets = [
    Target.common(
        name: "Database",
        resources: nil,
        dependencies: [
            .external(name: "GRDB"),
            .target(name: "Logger"),
        ]
    ),
    Target.common(
        name: "Logger",
        resources: nil,
        dependencies: [
            .external(name: "SwiftyBeaver"),
        ]
    ),
    Target.common(
        name: "MathParser",
        dependencies: [
            .external(name: "Down"),
            .external(name: "AttributedString"),
            .external(name: "iosMath"),
            .target(name: "Logger"),
        ]
    ),
    Target.common(
        name: "Networking",
        resources: nil,
        dependencies: [
            .external(name: "Moya"),
            .external(name: "CombineMoya"),
            .external(name: "SwiftyJSON"),
            .target(name: "Logger"),
        ]
    ),
]

let appTargets = Target.common(
    name: "Graduate",
    product: .app,
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
    ] + otherTargets.compactMap { $0.first }.map {
        .target(name: $0.name)
    },
    settings: .settings(
        base: [
            "OTHER_LDFLAGS": .string("-Xlinker -interposable"),
        ].automaticCodeSigning(devTeam: "RG36R5GVH3")
    )
)

let project = Project(
    name: "Graduate",
    organizationName: "doom",
    targets: appTargets + otherTargets.flatMap { $0 }
)
