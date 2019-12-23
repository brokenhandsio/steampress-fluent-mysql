import FluentMySQL
import SteamPress

struct FluentMysqlPostRepository: BlogPostRepository, Service {
    
    func getAllPostsSortedByPublishDate(includeDrafts: Bool, on container: Container) -> EventLoopFuture<[BlogPost]> {
        container.requestPooledConnection(to: .mysql).flatMap { connection in
            let query = BlogPost.query(on: connection).sort(\.created, .descending)
            if !includeDrafts {
                query.filter(\.published == true)
            }
            return query.all()
        }
    }
    
    func getAllPostsSortedByPublishDate(includeDrafts: Bool, on container: Container, count: Int, offset: Int) -> EventLoopFuture<[BlogPost]> {
        container.requestPooledConnection(to: .mysql).flatMap { connection in
            let query = BlogPost.query(on: connection).sort(\.created, .descending)
            if !includeDrafts {
                query.filter(\.published == true)
            }
            let upperLimit = count + offset
            return query.range(offset..<upperLimit).all()
        }
    }
    
    func getAllPostsSortedByPublishDate(for user: BlogUser, includeDrafts: Bool, on container: Container, count: Int, offset: Int) -> EventLoopFuture<[BlogPost]> {
        container.requestPooledConnection(to: .mysql).flatMap { connection in
            let query = try user.posts.query(on: connection).sort(\.created, .descending)
            if !includeDrafts {
                query.filter(\.published == true)
            }
            let upperLimit = count + offset
            return query.range(offset..<upperLimit).all()
        }
    }
    
    func getPostCount(for user: BlogUser, on container: Container) -> EventLoopFuture<Int> {
        container.requestPooledConnection(to: .mysql).flatMap { connection in
            try user.posts.query(on: connection).filter(\.published == true).count()
        }
    }
    
    func getPost(slug: String, on container: Container) -> EventLoopFuture<BlogPost?> {
        container.requestPooledConnection(to: .mysql).flatMap { connection in
            BlogPost.query(on: connection).filter(\.slugUrl == slug).first()
        }
    }
    
    func getPost(id: Int, on container: Container) -> EventLoopFuture<BlogPost?> {
        container.requestPooledConnection(to: .mysql).flatMap { connection in
            BlogPost.query(on: connection).filter(\.blogID == id).first()
        }
    }
    
    func getSortedPublishedPosts(for tag: BlogTag, on container: Container, count: Int, offset: Int) -> EventLoopFuture<[BlogPost]> {
        container.requestPooledConnection(to: .mysql).flatMap { connection in
            let query = try tag.posts.query(on: connection).filter(\.published == true).sort(\.created, .descending)
            let upperLimit = count + offset
            return query.range(offset..<upperLimit).all()
        }
    }
    
    func findPublishedPostsOrdered(for searchTerm: String, on container: Container) -> EventLoopFuture<[BlogPost]> {
        container.requestPooledConnection(to: .mysql).flatMap { connection in
            BlogPost.query(on: connection).sort(\.created, .descending).filter(\.published == true).group(.or) { or in
                or.filter(\.title, .like, "%\(searchTerm)%")
                or.filter(\.contents, .like, "%\(searchTerm)%")
            }.all()
        }
    }
    
    func save(_ post: BlogPost, on container: Container) -> EventLoopFuture<BlogPost> {
        container.requestPooledConnection(to: .mysql).flatMap { connection in
            post.save(on: connection)
        }
    }
    
    func delete(_ post: BlogPost, on container: Container) -> EventLoopFuture<Void> {
        container.requestPooledConnection(to: .mysql).flatMap { connection in
            post.delete(on: connection)
        }
    }
    
}

