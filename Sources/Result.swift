public enum Result<V> {
    case Error(ErrorType)
    case Value(V)

    public init(@noescape unsafe: () throws -> V) {
        do {
            self = .Value(try unsafe())
        } catch (let error) {
            self = .Error(error)
        }
    }

    public func value() throws -> V {
        switch self {
        case .Error(let error):
            throw error
        case .Value(let value):
            return value
        }
    }

    public func map<U>(transform: V -> U) -> Result<U> {
        switch self {
        case .Value(let value):
            return .Value(transform(value))
        case .Error(let error):
            return .Error(error)
        }
    }

    public func flatMap<U>(transform: V -> Result<U>) -> Result<U> {
        switch self {
        case .Error(let error):
            return .Error(error)
        case .Value(let value):
            switch transform(value) {
            case .Error(let error):
                return .Error(error)
            case .Value(let value):
                return .Value(value)
            }
        }
    }

    public func apply<U>(transform: Result<V -> U>) -> Result<U> {
        switch self {
        case .Error(let error):
            return .Error(error)
        case .Value(let value):
            switch transform {
            case .Error(let error):
                return .Error(error)
            case .Value(let transform):
                return .Value(transform(value))
            }
        }
    }

    public static func pure(value: V) -> Result<V> {
        return .Value(value)
    }
}

public func pure<V>(value: V) -> Result<V> {
    return Result<V>.pure(value)
}

infix operator <^> {
associativity left
precedence 130
}

public func <^> <V, U>(transform: V -> U, result: Result<V>) -> Result<U> {
    return result.map(transform)
}

infix operator <*> {
associativity left
precedence 130
}

public func <*> <V, U>(transform: Result<V -> U>, result: Result<V>) -> Result<U> {
    return result.apply(transform)
}

infix operator >>- {
associativity left
precedence 100
}

public func >>- <V, U>(result: Result<V>, transform: V -> Result<U>) -> Result<U> {
    return result.flatMap(transform)
}

infix operator -<< {
associativity right
precedence 100
}

public func -<< <V, U>(transform: V -> Result<U>, result: Result<V>) -> Result<U> {
    return result.flatMap(transform)
}
