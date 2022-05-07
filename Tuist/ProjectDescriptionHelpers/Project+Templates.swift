import ProjectDescription

public extension Project {
    static func common(
        name: String,
        product: Product,
        organizationName: String,
        deploymentTarget: DeploymentTarget = .iOS(targetVersion: "15.0", devices: [.iphone, .ipad]),
        infoPlist: [String: InfoPlist.Value] = [:],
        header: Headers? = nil,
        sources: SourceFilesList? = ["Sources/**"],
        resources: ResourceFileElements? = ["Resources/**"],
        testSources: SourceFilesList? = ["Tests/**"],
        dependencies: [TargetDependency] = [],
        module: [String] = [],
        packages: [Package] = [],
        integrations: [String] = [],
        settings: Settings? = nil,
        additionalFiles: [FileElement] = []
    ) -> Project {
        var targets = [Target]()

        let appTarget = Target(
            name: name,
            platform: .iOS,
            product: product,
            bundleId: "com.\(organizationName).\(name)",
            deploymentTarget: deploymentTarget,
            infoPlist: .extendingDefault(with: infoPlist),
            sources: sources,
            resources: resources,
            headers: header,
            dependencies: dependencies
                + module.map {
                    .project(target: $0, path: .relativeToRoot("Projects/\($0)"))
                }
                + integrations.map {
                    .project(target: $0, path: .relativeToRoot("Integrations/\($0)"))
                },
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
                sources: testSources,
                dependencies: [
                    .target(name: "\(name)"),
                ]
            )
            targets.append(testTarget)
        }

        return Project(
            name: name,
            organizationName: organizationName,
            packages: packages,
            targets: targets,
            additionalFiles: additionalFiles
        )
    }
}
