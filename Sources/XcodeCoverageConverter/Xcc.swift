import ArgumentParser
import Foundation

@main
struct Xcc: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A Swift command-line tool to convert xccov outputs into continuous integration friendly formats",
        version: "0.2.2",
        subcommands: [Generate.self],
        defaultSubcommand: Generate.self
    )
}
