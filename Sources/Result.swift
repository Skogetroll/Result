public enum Result<V> {
    case Error(ErrorType)
    case Value(V)
    
    public init(@noescape f: () throws -> V) {
        do {
            self = pure(try f())
        }
        catch (let error) {
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
				
    public func flatMap<U>(f: V -> Result<U>) -> Result<U> {
        switch self {
        case .Error(let error):
            return .Error(error)
        case .Value(let value):
            switch f(value) {
            case .Error(let error):
                return .Error(error)
            case .Value(let value):
                return .Value(value)
            }
        }
    }
    
    public func apply<U>(f: Result<V -> U>) -> Result<U> {
        switch self {
        case .Error(let error):
            return .Error(error)
        case .Value(let value):
            switch f {
            case .Error(let error):
                return .Error(error)
            case .Value(let transform):
                return .Value(transform(value))
            }
        }
    }
    
    public static func pure(v: V) -> Result<V> {
        return .Value(v)
    }
}

public func pure<V>(v: V) -> Result<V> {
    return Result<V>.pure(v)
}

infix operator <^> {
	associativity left
	precedence 130
}

public func <^> <V, U>(f: V -> U, v: Result<V>) -> Result<U> {
    return v.map(f)
}

infix operator <*> {
	associativity left
	precedence 130
}

public func <*> <V, U>(f: Result<V -> U>, v: Result<V>) -> Result<U> {
    return v.apply(f)
}

infix operator >>- {
    associativity left
    precedence 100
}

public func >>- <V, U>(v: Result<V>, f: V -> Result<U>) -> Result<U> {
    return v.flatMap(f)
}

infix operator -<< {
    associativity right
    precedence 100
}

public func -<< <V, U>(f: V -> Result<U>, v: Result<V>) -> Result<U> {
    return v.flatMap(f)
}
