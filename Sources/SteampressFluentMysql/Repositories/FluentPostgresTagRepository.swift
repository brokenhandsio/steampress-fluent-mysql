import FluentMySQL
import SteamPress
import Fluent

struct FluentMysqlTagRepository: BlogTagRepository, Service {
    
    func getAllTags(on container: Container) -> EventLoopFuture<[BlogTag]> {
        container.requestPooledConnection(to: .mysql).flatMap { connection in
            BlogTag.query(on: connection).all()
        }
    }
    
    func getAllTagsWithPostCount(on container: Container) -> EventLoopFuture<[(BlogTag, Int)]> {
        container.requestPooledConnection(to: .mysql).flatMap { connection in
            let allTagsQuery = BlogTag.query(on: connection).all()
            let allPivotsQuery = BlogPostTagPivot.query(on: connection).all()
            return map(allTagsQuery, allPivotsQuery) { tags, pivots in
                return try tags.map { tag in
                    let postCount = try pivots.filter { try $0.tagID == tag.requireID() }.count
                    return (tag, postCount)
                }
            }
        }
    }
    
    func getTags(for post: BlogPost, on container: Container) -> EventLoopFuture<[BlogTag]> {
        container.requestPooledConnection(to: .mysql).flatMap { connection in
            try post.tags.query(on: connection).all()
        }
    }
    
    func getTag(_ name: String, on container: Container) -> EventLoopFuture<BlogTag?> {
        container.requestPooledConnection(to: .mysql).flatMap { connection in
            BlogTag.query(on: connection).filter(\.name == name).first()
        }
    }
    
    func save(_ tag: BlogTag, on container: Container) -> EventLoopFuture<BlogTag> {
        container.requestPooledConnection(to: .mysql).flatMap { connection in
            tag.save(on: connection)
        }
    }
    
    func deleteTags(for post: BlogPost, on container: Container) -> EventLoopFuture<Void> {
        container.requestPooledConnection(to: .mysql).flatMap { connection in
            try post.tags.query(on: connection).all().flatMap { tags in
                let tagIDs = tags.compactMap { $0.tagID }
                return try BlogPostTagPivot.query(on: connection).filter(\.postID == post.requireID()).filter(\.tagID ~~ tagIDs).delete().flatMap { _ in
                    var tagCleanups = [EventLoopFuture<Void>]()
                    for tag in tags {
                        let tagCleanup = try tag.posts.query(on: connection).all().flatMap(to: Void.self) { posts in
                            let cleanupFuture: EventLoopFuture<Void>
                            if posts.count == 0 {
                                cleanupFuture = tag.delete(on: connection)
                            } else {
                                cleanupFuture = container.future()
                            }
                            return cleanupFuture
                        }
                        tagCleanups.append(tagCleanup)
                    }
                    return tagCleanups.flatten(on: container)
                }
            }
        }
    }
    
    func remove(_ tag: BlogTag, from post: BlogPost, on container: Container) -> EventLoopFuture<Void> {
        container.requestPooledConnection(to: .mysql).flatMap { connection in
            post.tags.detach(tag, on: connection)
        }
    }
    
    func add(_ tag: BlogTag, to post: BlogPost, on container: Container) -> EventLoopFuture<Void> {
        container.requestPooledConnection(to: .mysql).flatMap { connection in
            post.tags.attach(tag, on: connection).transform(to: ())
        }
    }
    
}