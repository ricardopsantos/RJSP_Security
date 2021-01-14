import App
import Vapor

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)

try configure(app)
try app.run()
defer {
    try? app.eventLoopGroup.syncShutdownGracefully()
    app.shutdown()
}
