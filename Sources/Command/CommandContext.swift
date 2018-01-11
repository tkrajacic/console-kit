import Console

/// Contains required data for running a command
/// such as the console and input.
public struct CommandContext {
    /// The console this command was run on.
    public var console: Console

    /// The parsed arguments (according to declared signature).
    public var arguments: [String: String]

    /// The parsed options (according to declared signature).
    public var options: [String: String]

    /// Create a new `CommandContext`.
    public init(
        console: Console,
        arguments: [String: String],
        options: [String: String]
    ) {
        self.console = console
        self.arguments = arguments
        self.options = options
    }

    /// Requires an option, returning the value or throwing.
    /// Use `.options` to access in a non-required manner.
    public func requireOption(_ name: String) throws -> String {
        guard let value = options[name] else {
            throw CommandError(identifier: "optionRequired", reason: "Option `\(name)` is required.")
        }

        return value
    }

    /// Accesses an argument by name. This will only throw if
    /// the argument was not properly declared in your signature.
    public func argument(_ name: String) throws -> String {
        guard let value = arguments[name] else {
            throw CommandError(identifier: "argumentRequired", reason: "Argument `\(name)` is required.")
        }
        return value
    }

    /// Creates a CommandContext, parsing the values from the supplied CommandInput.
    static func make(
        from input: inout CommandInput,
        console: Console,
        for runnable: CommandRunnable
    ) throws -> CommandContext {
        var parsedArguments: [String: String] = [:]
        var parsedOptions: [String: String] = [:]

        let arguments: [CommandArgument]
        switch runnable.type {
        case .command(let a): arguments = a
        case .group: arguments = []
        }

        for arg in arguments {
            guard let value = try input.parse(argument: arg) else {
                throw CommandError(
                    identifier: "argumentRequired",
                    reason: "Argument `\(arg.name)` is required."
                )
            }
            parsedArguments[arg.name] = value
        }

        for opt in runnable.options {
            parsedOptions[opt.name] = try input.parse(option: opt)
        }

        guard input.arguments.count == 0 else {
            throw CommandError(
                identifier: "excessInput",
                reason: "Too many arguments or unsupported options were supplied: \(input.arguments)"
            )
        }

        return CommandContext(
            console: console,
            arguments: parsedArguments,
            options: parsedOptions
        )
    }
}
