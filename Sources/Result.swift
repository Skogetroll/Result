/**
    Wraps result of throwing code and allows to map embedded value
*/
public enum Result<V> {
    case Error(ErrorType)
    case Value(V)
    
    /**
        Init with unsafe code
    */
    public init(@noescape unsafe: () throws -> V) {
        do {
            self = .Value(try unsafe())
        } catch (let error) {
            self = .Error(error)
        }
    }
    
    /**
        Wraps value in Result
    */
    public static func pure(value: V) -> Result<V> {
        return .Value(value)
    }
    
    /**
        Get unsafe execution back, in case if you want to use do ... catch after all
    */
    public func unwrap() throws -> V {
        switch self {
        case .Error(let error):
            throw error
        case .Value(let value):
            return value
        }
    }
    
    /**
        Unwrap value as optional
    */
    public var value: V? {
        switch self {
        case .Value(let value):
            return value
        case .Error:
            return nil
    }
    
    /**
        Unwrap error as optional
    */
    public var error: ErrorType? {
        switch self {
        case .Error(let error):
            return error
        case .Value:
            return nil
        }
    }
    
    /**
        If there's no error, perform function with value and return wrapped result
    */
    public func map<U>(transform: V -> U) -> Result<U> {
        switch self {
        case .Value(let value):
            return .Value(transform(value))
        case .Error(let error):
            return .Error(error)
        }
    }

    /**
        If there's no error, perform function that may yield Result with value and return wrapped result
    */
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
    
    /**
        Apply function wrapped in Result to Result-vrapped value
    */
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
}

/**
    Wraps value in Result
*/
public func pure<V>(value: V) -> Result<V> {
    return Result<V>.pure(value)
}

infix operator <^> {
associativity left
precedence 130
}

/**
    If there's no error, perform function with value and return wrapped result
*/
public func <^> <V, U>(transform: V -> U, result: Result<V>) -> Result<U> {
    return result.map(transform)
}

infix operator <*> {
associativity left
precedence 130
}

/**
    Apply function wrapped in Result to Result-vrapped value
*/
public func <*> <V, U>(transform: Result<V -> U>, result: Result<V>) -> Result<U> {
    return result.apply(transform)
}

infix operator >>- {
associativity left
precedence 100
}

/**
    If there's no error, perform function that may yield Result with value and return wrapped result
    Left associative
*/
public func >>- <V, U>(result: Result<V>, transform: V -> Result<U>) -> Result<U> {
    return result.flatMap(transform)
}

infix operator -<< {
associativity right
precedence 100
}

/**
    If there's no error, perform function that may yield Result with value and return wrapped result
    Right associative
*/
public func -<< <V, U>(transform: V -> Result<U>, result: Result<V>) -> Result<U> {
    return result.flatMap(transform)
}
