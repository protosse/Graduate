import ProjectDescription

let dependencies = Dependencies(
    carthage: [
        .github(path: "johnxnguyen/Down", requirement: .exact("0.11.0")),
    ],
    swiftPackageManager: .init(
        [
            .remote(url: "https://github.com/layoutBox/PinLayout",
                    requirement: .upToNextMajor(from: "1.0.0")),
            .remote(url: "https://github.com/SwifterSwift/SwifterSwift",
                    requirement: .upToNextMajor(from: "5.0.0")),
            .remote(url: "https://github.com/Moya/Moya.git",
                    requirement: .upToNextMajor(from: "15.0.0")),
            .remote(url: "https://github.com/SwiftyJSON/SwiftyJSON",
                    requirement: .upToNextMajor(from: "5.0.0")),
            .remote(url: "https://github.com/SwiftyBeaver/SwiftyBeaver",
                    requirement: .upToNextMajor(from: "1.9.0")),
            .remote(url: "https://github.com/lixiang1994/AttributedString",
                    requirement: .upToNextMajor(from: "3.0.0")),
            .remote(url: "https://github.com/krzysztofzablocki/Inject.git",
                    requirement: .upToNextMajor(from: "1.0.0")),
            .remote(url: "https://github.com/protosse/GRDB.swift",
                    requirement: .branch("master")),
             .remote(url: "https://github.com/protosse/iosMath.git",
                    requirement: .branch("master")),
        ]),
    platforms: [.iOS]
)
