import ArgumentParser
import Core
import Foundation

struct Generate: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Generates a converted file from xccov results")

    @Argument(help: "The full path to the json file to convert")
    private var jsonFile: String

    @Argument(help: "The path of the output file")
    private var outputPath: String

    @Argument(help: "The output formats")
    private var outputFormats: [Xccov.Commands.Generate.Output]

    @Option(help: "The targets to exclude")
    private var excludeTargets: [String]

    @Option(help: "The packages to exclude")
    private var excludePackages: [String]

    @Flag(name: .long, help: "Show extra logging for debugging purposes")
    private var verbose: Bool = false

    func run() throws {
        let result = Xccov.Commands.Generate.execute(jsonFile: jsonFile,
                                                     outputPath: outputPath,
                                                     outputs: outputFormats,
                                                     excludeTargets: excludeTargets,
                                                     excludePackages: excludePackages,
                                                     verbose: verbose)

        switch result {
        case .success:
            throw CleanExit.message("All good")
        case .failure(let error):
            let message = "\(error.localizedDescription)\n"
            FileHandle.standardError.write(message.data(using: .utf8)!)
            throw ExitCode.failure
        }
    }
}
