import SteamPress
import FluentMySQL

extension BlogPost: Model {
    public typealias ID = Int
    public typealias Database = MySQLDatabase
    public static var idKey: IDKey { return \.blogID }
}

extension BlogPost: Migration {
    public static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        Database.create(BlogPost.self, on: connection) { builder in
            builder.field(for: \.blogID, isIdentifier: true)
            builder.field(for: \.title)
            builder.field(for: \.contents)
            builder.field(for: \.author)
            builder.field(for: \.created)
            builder.field(for: \.lastEdited)
            builder.field(for: \.slugUrl)
            builder.field(for: \.published)
            builder.unique(on: \.slugUrl)
            builder.reference(from: \.author, to: \BlogUser.userID)
        }
    }
}

extension BlogPost {
    var tags: Siblings<BlogPost, BlogTag, BlogPostTagPivot> {
        return siblings()
    }
}
