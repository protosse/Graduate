import ProjectDescription

extension Target {
    public static func common(
        name: String,
        organizationName: String = "doom",
        product: Product = .framework,
        deploymentTarget: DeploymentTarget = .iOS(targetVersion: "14.0", devices: [.iphone, .ipad]),
        infoPlist: [String: InfoPlist.Value] = [:],
        path: String = "Targets",
        header: Headers? = nil,
        sources: [String] = ["Sources/**"],
        resources: [String]? = ["Resources/**"],
        testSources: [String]? = ["Tests/**"],
        dependencies: [TargetDependency] = [],
        settings: Settings? = nil
    ) -> [Target] {
        var targets = [Target]()

        let appTarget = Target(
            name: name,
            platform: .iOS,
            product: product,
            bundleId: "com.\(organizationName).\(name)",
            deploymentTarget: deploymentTarget,
            infoPlist: .extendingDefault(with: infoPlist),
            sources: SourceFilesList(globs: sources.map {
                "\(path)/\(name)/\($0)"
            }),
            resources: ResourceFileElements(resources: resources?.compactMap {
                ResourceFileElement(stringLiteral: "\(path)/\(name)/\($0)")
            } ?? []),
            headers: header,
            dependencies: dependencies,
            settings: settings
        )
        targets.append(appTarget)

        if let testSources = testSources {
            let testTarget = Target(
                name: "\(name)Tests",
                platform: .iOS,
                product: .unitTests,
                bundleId: "com.\(organizationName).\(name)Tests",
                deploymentTarget: deploymentTarget,
                infoPlist: .default,
                sources: SourceFilesList(globs: testSources.map {
                    "\(path)/\(name)/\($0)"
                }),
                dependencies: [
                    .target(name: "\(name)"),
                    .external(name: "Quick"),
                    .external(name: "Nimble"),
                ]
            )
            targets.append(testTarget)
        }

        return targets
    }
}
