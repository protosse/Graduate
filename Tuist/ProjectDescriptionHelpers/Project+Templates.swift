import ProjectDescription

extension Project {
    public static func common(
        name: String,
        product: Product,
        organizationName: String,
        deploymentTarget: DeploymentTarget = .iOS(targetVersion: "14.0", devices: [.iphone, .ipad]),
        infoPlist: [String: InfoPlist.Value] = [:],
        sources: SourceFilesList? = ["Sources/**"],
        resources: ResourceFileElements? = ["Resources/**"],
        testSources: SourceFilesList? = ["Tests/**"],
        dependencies: [TargetDependency] = [],
        module: [String] = [],
        packages: [Package] = [],
        integrations: [String] = []
    ) -> Project {
        let appTarget = Target(
            name: name,
            platform: .iOS,
            product: product,
            bundleId: "com.\(organizationName).\(name)",
            deploymentTarget: deploymentTarget,
            infoPlist: .extendingDefault(with: infoPlist),
            sources: sources,
            resources: resources,
            dependencies: dependencies
                + module.map({
                    .project(target: $0, path: .relativeToRoot("Projects/\($0)"))
                })
                + integrations.map({
                    .project(target: $0, path: .relativeToRoot("Integrations/\($0)"))
                })
        )

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

        return Project(
            name: name,
            organizationName: organizationName,
            packages: packages,
            targets: [appTarget, testTarget]
        )
    }
}
