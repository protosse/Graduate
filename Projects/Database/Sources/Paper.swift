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

public extension Paper {
    static let pivots = hasMany(PaperCategoryPivot.self)
    static let categories = hasMany(PaperCategory.self, through: pivots, using: PaperCategoryPivot.paperCategory)
    var categoriesRequest: QueryInterfaceRequest<PaperCategory> {
        request(for: Paper.categories)
    }
}

public extension DerivableRequest where RowDecoder == Paper {
    func orderByName() -> Self {
        order(Paper.Columns.title.collating(.localizedCaseInsensitiveCompare))
    }
}
