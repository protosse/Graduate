import Foundation
import GRDB

public struct PaperCategory: Identifiable, Hashable, TableRecord {
    public static var databaseTableName = "paper-categories"

    public var id: Int64?
    public var name: String = ""
}

extension PaperCategory: Codable, FetchableRecord, MutablePersistableRecord {
    fileprivate enum Columns {
        static let name = Column(CodingKeys.name)
    }

    public mutating func didInsert(with rowID: Int64, for _: String?) {
        id = rowID
    }
}

extension PaperCategory {
    public static let pivots = hasMany(PaperCategoryPivot.self)
    public static let papers = hasMany(Paper.self, through: pivots, using: PaperCategoryPivot.paper)
    public var papersRequest: QueryInterfaceRequest<Paper> {
        request(for: PaperCategory.papers)
    }
}
