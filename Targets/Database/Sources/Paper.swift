import Foundation
import GRDB

public struct Paper: Identifiable, Hashable, TableRecord {
    public static var databaseTableName = "papers"

    public var id: Int64?
    public var title: String = ""
    public var content: String = ""

    public var categories: [PaperCategory] = []
}

extension Paper: Codable, FetchableRecord, MutablePersistableRecord {
    enum CodingKeys: String, CodingKey {
        case title
        case content
    }

    fileprivate enum Columns {
        static let title = Column(CodingKeys.title)
        static let content = Column(CodingKeys.content)
    }

    public mutating func didInsert(with rowID: Int64, for _: String?) {
        id = rowID
    }
}

extension Paper {
    public static let pivots = hasMany(PaperCategoryPivot.self)
    public static let categories = hasMany(PaperCategory.self, through: pivots, using: PaperCategoryPivot.paperCategory)
    public var categoriesRequest: QueryInterfaceRequest<PaperCategory> {
        request(for: Paper.categories)
    }
}

extension DerivableRequest where RowDecoder == Paper {
    public func orderByName() -> Self {
        order(Paper.Columns.title.collating(.localizedCaseInsensitiveCompare))
    }
}
