import Foundation
import GRDB
import Logger

public class Database {
    public static let share = Database()

    private let dbWriter: DatabaseWriter

    init() {
        do {
            let fileManager = FileManager()
            let folderURL = try fileManager
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("database", isDirectory: true)
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)

            let dbURL = folderURL.appendingPathComponent("db.sqlite")
            log.debug(dbURL)

            var config = Configuration()
            config.prepareDatabase { db in
                try db.usePassphrase("8!|V8yGcDrP-m0x4rB,f")
            }
            let dbPool = try DatabasePool(path: dbURL.path, configuration: config)

            dbWriter = dbPool
            try migrator.migrate(dbWriter)
        } catch {
            fatalError("Unresolved error \(error)")
        }
    }

    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        #if DEBUG
            migrator.eraseDatabaseOnSchemaChange = true
        #endif

        migrator.registerMigration("createBase") { db in
            try db.create(table: "papers") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("title", .text).unique(onConflict: .replace).notNull()
                t.column("content", .text).notNull()
            }

            try db.create(table: "paper-categories", body: { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).unique(onConflict: .replace).notNull()
            })

            try db.create(table: "paper-category-pivot", body: { t in
                t.column("paper_id", .integer).notNull().indexed()
                    .references("papers", column: "id", onDelete: .cascade)
                t.column("paperCategory_id", .integer).notNull().indexed()
                    .references("paper-categories", column: "id", onDelete: .cascade)
                t.primaryKey(["paper_id", "paperCategory_id"], onConflict: .replace)
            })
        }

        return migrator
    }
}

extension Database {
    public func syncPapers(_ papers: [Paper]) throws {
        try dbWriter.write { db in
            for var paper in papers {
                if try paper.exists(db) {
                    try paper.update(db)
                    let linkedCategories = try paper.categoriesRequest.fetchAll(db)
                    let finalCategories = paper.categories

                    for var cat in finalCategories {
                        if !linkedCategories.contains(cat) {
                            try cat.save(db)
                            let pivot = PaperCategoryPivot(paperId: paper.id, paperCategoryId: cat.id)
                            try pivot.save(db)
                        }
                    }

                    for cat in linkedCategories {
                        if !finalCategories.contains(cat) {
                            let pivot = PaperCategoryPivot(paperId: paper.id, paperCategoryId: cat.id)
                            try pivot.delete(db)
                        }
                    }
                } else {
                    try paper.insert(db)
                    for var cat in paper.categories {
                        try cat.save(db)
                        let pivot = PaperCategoryPivot(paperId: paper.id, paperCategoryId: cat.id)
                        try pivot.save(db)
                    }
                }
            }
        }
    }

    public func papers() -> [Paper] {
        var papers: [Paper] = []
        try? dbWriter.read { db in
            papers = try Paper.fetchAll(db)
        }
        return papers
    }
}
