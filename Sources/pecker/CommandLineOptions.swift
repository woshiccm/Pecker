import Foundation
import TSCUtility

/// Collects the command line options that were passed to `elf`.
struct CommandLineOptions {
    
    /// The project path
    var path: String = ""
    
    /// The mode in which to run the tool.
    ///
    /// If not specified, the tool will be run in format mode.
    var mode: ToolMode = .detect
    
    /// The path to the index that should be loaded
    ///
    /// If not specified, the default is find from DerivedData with project name
    var storePath: String?
    
    /// Whether to show warning
    var shouldShowWarning: Bool = true
}

/// Process the command line argument strings and returns an object containing their values.
///
/// - Parameters:
///   - commandName: The name of the command that this tool was invoked as.
///   - arguments: The remaining command line arguments after the command name.
/// - Returns: A `CommandLineOptions` value that contains the parsed options.
func processArguments(commandName: String, _ arguments: [String]) -> CommandLineOptions {
    // Create the parser.
    let parser = ArgumentParser(
        commandName: commandName,
        usage: "[options]",
        overview: "A tool for eliminating unused Swift code."
    )

    // Create the binder.
    let binder = ArgumentBinder<CommandLineOptions>()
    
    binder.bind(
      option: parser.add(
        option: "--mode", shortName: "-m", kind: ToolMode.self,
        usage: "The mode to run pecker in."
      )
    ) {
      $0.mode = $1
    }
    
    binder.bind(
      option: parser.add(
        option: "--version", shortName: "-v", kind: Bool.self,
        usage: "Prints the version and exists"
      )
    ) { opts, _ in
      opts.mode = .version
    }
    
    binder.bind(
        positional: parser.add(
            positional: "path", kind: String.self, optional: true,
            usage: "Path of the project to detect"),
        to: { $0.path = $1 })
    
    // Bind the common options.
    binder.bind(
        option: parser.add(
            option: "--store-path", shortName: "-s", kind: String.self,
            usage: "Specify project index path [default: ~/Library/Developer/Xcode/DerivedData]"),
        to: { $0.storePath = $1 })
    
    binder.bind(
        option: parser.add(
            option: "--show-warning", kind: Bool.self,
            usage: "Show warning in source file"),
        to: { $0.shouldShowWarning = $1 })
    
    var opts = CommandLineOptions()
    
    do {
        let args = try parser.parse(arguments)
        try binder.fill(parseResult: args, into: &opts)
    } catch {
        exit(1)
    }
    
    return opts
}
