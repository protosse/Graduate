import ProjectDescription

let dependencies = Dependencies(
    carthage: [
        .github(path: "johnxnguyen/Down", requirement: .exact("0.11.0")),
    ],
    swiftPackageManager: .init(
        [
            .remote(url: "https://github.com/layoutBox/PinLayout",
                    requirement: .upToNextMajor(from: "1.10.4")),
            .remote(url: "https://github.com/SwifterSwift/SwifterSwift",
                    requirement: .upToNextMajor(from: "5.3.0")),
            .remote(url: "https://github.com/Moya/Moya.git",
                    requirement: .upToNextMajor(from: "15.0.3")),
            .remote(url: "https://github.com/SwiftyJSON/SwiftyJSON",
                    requirement: .upToNextMajor(from: "5.0.0")),
            .remote(url: "https://github.com/SwiftyBeaver/SwiftyBeaver",
                    requirement: .upToNextMajor(from: "2.0.0")),
            .remote(url: "https://github.com/lixiang1994/AttributedString",
                    requirement: .upToNextMajor(from: "3.3.5")),
            .remote(url: "https://github.com/krzysztofzablocki/Inject.git",
                    requirement: .upToNextMajor(from: "1.2.4")),
            .remote(url: "https://github.com/Quick/Quick",
                    requirement: .upToNextMajor(from: "7.2.0")),
            .remote(url: "https://github.com/Quick/Nimble.git",
                    requirement: .upToNextMajor(from: "12.2.0")),
            .remote(url: "https://github.com/groue/GRDB.swift",
                    requirement: .upToNextMajor(from: "6.16.0")),
            .remote(url: "https://github.com/protosse/iosMath",
                    requirement: .branch("master")),
        ]),
    platforms: [.iOS]
)
