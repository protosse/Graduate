import GRDB

public struct PaperCategoryPivot: Hashable, TableRecord {
    public static var databaseTableName = "paper-category-pivot"

    public var paperId: Int64?
    public var paperCategoryId: Int64?

    public static let paper = belongsTo(Paper.self)
    public static let paperCategory = belongsTo(PaperCategory.self)
}

extension PaperCategoryPivot: Codable, FetchableRecord, PersistableRecord {
    enum CodingKeys: String, CodingKey {
        case paperId = "paper_id"
        case paperCategoryId = "paperCategory_id"
    }

    fileprivate enum Columns {
        static let paperId = Column(CodingKeys.paperId)
        static let paperCategoryId = Column(CodingKeys.paperCategoryId)
    }
}
