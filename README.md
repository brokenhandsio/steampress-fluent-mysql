<p align="center">
    <img src="https://user-images.githubusercontent.com/9938337/29742058-ed41dcc0-8a6f-11e7-9cfc-680501cdfb97.png" alt="SteamPress">
    <br>
    <br>
    <a href="https://swift.org">
        <img src="http://img.shields.io/badge/Swift-5.1-brightgreen.svg" alt="Language">
    </a>
    <a href="https://github.com/brokenhandsio/steampress-fluent-mysql/actions">
        <img src="https://github.com/brokenhandsio/steampress-fluent-mysql/workflows/CI/badge.svg?branch=master" alt="Build Status">
    </a>
    <a href="https://codecov.io/gh/brokenhandsio/steampress-fluent-mysql">
        <img src="https://codecov.io/gh/brokenhandsio/steampress-fluent-mysql/branch/master/graph/badge.svg" alt="Code Coverage">
    </a>
    <a href="https://raw.githubusercontent.com/brokenhandsio/steampress-fluent-mysql/master/LICENSE">
        <img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License">
    </a>
</p>

Steampress Fluent MySQL provides Fluent MySQL adapters for SteamPress to allow you to use SteamPress with a MySQL database.

# Usage:

Add the package to your **Package.swift** dependencies:

```swift
dependencies: [
    ...,
    .package(name: "SteampressFluentMysql", url: "https://github.com/brokenhandsio/steampress-fluent-mysql.git", from: "1.0.0"),
]
```

In **configure.swift** add the SteamPress Fluent MySQL provider:

```swift
import SteampressFluentMysql

// ...

let provider = SteamPressFluentMysqlProvider()
try services.register(provider)
```

You also need to add the migrations for the different database models to your `MigrationConfig`:

```swift
var migrations = MigrationConfig()
// ...
migrations.add(model: BlogTag.self, database: .mysql)
migrations.add(model: BlogUser.self, database: .mysql)
migrations.add(model: BlogPost.self, database: .mysql)
migrations.add(model: BlogPostTagPivot.self, database: .mysql)
// This will create an admin user so you can log in! The password will be printed out when created.
migrations.add(migration: BlogAdminUser.self, database: .mysql)
services.register(migrations)
```

This ensures the tables are created for use next time your app boots up.

For details on how to use SteamPress and the required templates see the main [SteamPress README](https://github.com/brokenhandsio/SteamPress/blob/master/README.md).

## Configuration

You can configure the provider with the following optional configuration options:

* `blogPath` - the path to add the blog to. For instance, if you pass in `"blog"`, your blog will be accessible at http://mysite.com/blog/, or leave this out your blog will be added to the root of your site (i.e. http://mysite.com/)
* `feedInformation`: Information to vend to the RSS and Atom feeds. Defaults to empty information.
* `postsPerPage`: The number of posts to show per page on the main index page of the blog and the user and tag pages. Defaults to 10.
* `enableAuthorsPages`: Flag used to determine whether to publicly expose the authors endpoints or not. Defaults to true.
* `enableTagsPages`: Flag used to determine whether to publicy expose the tags endpoints or not. Defaults to true.
