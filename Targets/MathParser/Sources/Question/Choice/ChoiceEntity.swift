import Foundation
import Logger

public struct ChoiceEntity: Equatable, Hashable {
    public var id: String
    public var items: [ChoiceItemEntity]
    public var correct: [ChoiceItemEntity]

    public var isMultiChoice: Bool {
        correct.count > 1
    }

    public init(id: String, items: [ChoiceItemEntity] = [], correct: [ChoiceItemEntity] = []) {
        self.id = id
        self.items = items
        self.correct = correct
    }
}

public enum ChoiceType: Int, Codable {
    case normal = 0
    case highlight
    case correct
    case error
}

public struct ChoiceItemEntity: Codable, Equatable, Hashable {
    public var id: String
    public var value: String
    public var correct: Bool
    public var choiceType: ChoiceType = .normal

    public static func from(param: String, value: String) -> ChoiceItemEntity? {
        var dic: [String: Any] = param.components(separatedBy: " ").map {
            $0.components(separatedBy: "=")
        }.reduce([String: String]()) { partialResult, group in
            var partialResult = partialResult
            if group.count == 2 {
                let key = group[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let value = group[1].trimmingCharacters(in: .whitespacesAndNewlines)
                partialResult[key] = value
            }
            return partialResult
        }

        dic["value"] = value
        dic["correct"] = dic["correct"] != nil

        guard let data = try? JSONSerialization.data(withJSONObject: dic),
              let model = try? JSONDecoder().decode(Self.self, from: data) else {
            log.error("parse ChoiceItemEntity error \(dic)")
            return nil
        }
        return model
    }

    enum CodingKeys: CodingKey {
        case id
        case value
        case correct
        case choiceType
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        value = try container.decode(String.self, forKey: .value)
        correct = try container.decode(Bool.self, forKey: .correct)
        choiceType = try container.decodeIfPresent(ChoiceType.self, forKey: .choiceType) ?? .normal
    }
}

public func == (lhs: ChoiceItemEntity, rhs: ChoiceItemEntity) -> Bool {
    return lhs.id == rhs.id && lhs.value == rhs.value
}
