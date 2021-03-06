import Vapor
import FluentMySQL
import SteampressFluentMysql

struct TestSetup {
    static func getApp(enableAdminUser: Bool = false) throws -> Application {
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
        if enableAdminUser {
            migrations.add(migration: BlogAdminUser.self, database: .mysql)
        }
        services.register(migrations)
        
        let config = Config.default()
        
        var commandConfig = CommandConfig.default()
        commandConfig.useFluentCommands()
        services.register(commandConfig)
        
        var revertEnv = Environment.testing
        revertEnv.arguments = ["vapor", "revert", "--all", "-y"]
        _ = try Application(environment: revertEnv, services: services).asyncRun().wait()
        
        let app = try Application(config: config, services: services)
        return app
    }
}
