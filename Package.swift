import PackageDescription

let package = Package(
    name: "FluentMySQL",
    dependencies: [
   		.Package(url: "https://github.com/qutheory/cmysql.git", majorVersion: 0),
      .Package(url: "https://github.com/qutheory/fluent.git", majorVersion: 0)
    ]
)
