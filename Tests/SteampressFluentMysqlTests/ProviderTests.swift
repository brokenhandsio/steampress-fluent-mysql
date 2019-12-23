@testable import SteampressFluentMysql
import XCTest
import Vapor
import FluentMySQL

class ProviderTests: XCTestCase {
    func testProviderSetsUpSteamPressAndRepositoriesCorrectly() throws {
        var services = Services.default()
        try services.register(FluentMySQLProvider())
        
        var databases = DatabasesConfig()
        let hostname: String
        if let envHostname = Environment.get("DB_HOSTNAME") {
            hostname = envHostname
        } else {
            hostname = "localhost"
        }
        let username = "steampress"
        let password = "password"
        let databaseName = "steampress-test"
        let databasePort: Int
        if let envPort = Environment.get("DB_PORT"), let envPortInt = Int(envPort) {
            databasePort = envPortInt
        } else {
            databasePort = 3307
        }
        let databaseConfig = MySQLDatabaseConfig(hostname: hostname, port: databasePort, username: username, password: password, database: databaseName)
        let database = MySQLDatabase(config: databaseConfig)
        databases.add(database: database, as: .mysql)
        services.register(databases)

        /// Configure migrations
        var migrations = MigrationConfig()
        migrations.add(model: BlogTag.self, database: .mysql)
        migrations.add(model: BlogUser.self, database: .mysql)
        migrations.add(model: BlogPost.self, database: .mysql)
        migrations.add(model: BlogPostTagPivot.self, database: .mysql)
        services.register(migrations)
        
        var config = Config.default()
        
        var commandConfig = CommandConfig.default()
        commandConfig.useFluentCommands()
        services.register(commandConfig)
        
        let provider = SteamPressFluentMysqlProvider()
        try services.register(provider)
        config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
        
        let app = try Application(config: config, services: services)
        
        let postRepository = try app.make(BlogPostRepository.self)
        XCTAssertTrue(type(of: postRepository) == FluentMysqlPostRepository.self)
        let tagRepository = try app.make(BlogTagRepository.self)
        XCTAssertTrue(type(of: tagRepository) == FluentMysqlTagRepository.self)
        let userRepository = try app.make(BlogUserRepository.self)
        XCTAssertTrue(type(of: userRepository) == FluentMysqlUserRepository.self)
        
        var revertEnv = Environment.testing
        revertEnv.arguments = ["vapor", "revert", "--all", "-y"]
        _ = try Application(config: config, environment: revertEnv, services: services).asyncRun().wait()
    }
}
