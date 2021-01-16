import Vapor

// configures your application
public func configure(_ app: Application) throws {
    app.http.server.configuration.port = 5678
    try routes(app)
}
