import FluentMySQL
import SteamPress

extension BlogTag: Model {
    public typealias ID = Int
    public typealias Database = MySQLDatabase
    public static var idKey: IDKey { return \.tagID }
}

extension BlogTag: Migration {
    public static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        Database.create(BlogTag.self, on: connection) { builder in
            builder.field(for: \.tagID, isIdentifier: true)
            builder.field(for: \.name)
            builder.unique(on: \.name)
        }
    }
}

extension BlogTag {
    var posts: Siblings<BlogTag, BlogPost, BlogPostTagPivot> {
        return siblings()
    }
}
