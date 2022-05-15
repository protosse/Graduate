import SwiftyBeaver

public let log: SwiftyBeaver.Type = {
    let log = SwiftyBeaver.self
    let console = ConsoleDestination()
    log.addDestination(console)
    return log
}()
