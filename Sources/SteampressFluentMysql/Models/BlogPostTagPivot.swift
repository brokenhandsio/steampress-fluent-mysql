import SteamPress
import FluentMySQL

public final class BlogPostTagPivot: MySQLUUIDPivot, ModifiablePivot {
    public var id: UUID?
    public var postID: BlogPost.ID
    public var tagID: BlogTag.ID
    
    public typealias Left = BlogPost
    public typealias Right = BlogTag
    public static let leftIDKey: LeftIDKey = \.postID
    public static let rightIDKey: RightIDKey = \.tagID
    
    public init(_ post: BlogPost, _ tag: BlogTag) throws {
        self.postID = try post.requireID()
        self.tagID = try tag.requireID()
    }
}

extension BlogPostTagPivot: Migration {
    public static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        Database.create(BlogPostTagPivot.self, on: connection) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.postID)
            builder.field(for: \.tagID)
            builder.reference(from: \.postID, to: \BlogPost.blogID, onDelete: .cascade)
            builder.reference(from: \.tagID, to: \BlogTag.tagID, onDelete: .cascade)
        }
    }
}
