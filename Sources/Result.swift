// MARK: - Result

/**
  Wraps result of throwing code and allows to map embedded value
*/
public enum Result<V> {
  /// Resulted in error
  case Error(ErrorType)
  /// Successfully aquired a value
  case Value(V)
  
  // MARK: Initialization
  /**
    Init with unsafe code
    
    ```swift
    let result = Result<V> { 
      // Your unsafe code, that results either in value of type V or in error
    }
    ```
  */
  public init(@noescape unsafe: () throws -> V) {
    do {
      self = .Value(try unsafe())
    } catch (let error) {
      self = .Error(error)
    }
  }
  
  /**
    Convinience init with unsafe code
   
    ```swift
    let result = Result<V> (
      // Your unsafe code, that results either in value of type V or in error
    )
   ```
  */
  public init(@autoclosure _ unsafe: () throws -> V) {
    do {
      self = .Value(try unsafe())
    } catch (let error) {
      self = .Error(error)
    }
  }
  
  // MARK: Pure
  /**
    Wraps value in Result
  */
  @warn_unused_result
  public static func pure(value: V) -> Result<V> {
    return .Value(value)
  }
  
  // MARK: Wrap
  /**
    Wrap some throwing function from `U -> V` in `U -> Result<V>` function
  */
  @warn_unused_result
  public static func wrap<U>(function: U throws -> V) -> (U -> Result) {
    return { u in
      Result {
        try function(u)
      }
    }
  }
  
  // MARK: Unwrapping
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
  
  // MARK: Map
  /**
    If there's no error, perform function with value and return wrapped result
  */
  @warn_unused_result
  public func map<U>(@noescape transform: V -> U) -> Result<U> {
    switch self {
    case .Value(let value):
      return .Value(transform(value))
    case .Error(let error):
      return .Error(error)
    }
  }
  
  /**
   Performs transformation over value of Result.
   */
  public func forEach(@noescape transform: V -> Void) {
    switch self {
    case .Value(let value):
      transform(value)
    case .Error:
      break
    }
  }
  
  // MARK: Flat map
  /**
    If there's no error, perform function that may yield Result with value and return wrapped result
  */
  @warn_unused_result
  public func flatMap<U>(@noescape transform: V -> Result<U>) -> Result<U> {
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
  
  // MARK: Apply
  /**
    Apply function wrapped in Result to Result-vrapped value
  */
  @warn_unused_result
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

// MARK: - Functions

// MARK: Pure
/**
  Wraps value in Result
*/
@warn_unused_result
public func pure<V>(value: V) -> Result<V> {
  return Result<V>.pure(value)
}

/**
 Wrap some throwing function from `U -> V` in `U -> Result<V>` function
 */
@warn_unused_result
public func wrap<V, U>(original: V throws -> U) -> (V -> Result<U>) {
  return Result<U>.wrap(original)
}

// MARK: Map
infix operator <^> {
associativity left
precedence 130
}

/**
  If there's no error, perform function with value and return wrapped result
*/
@warn_unused_result
public func <^> <V, U>(@noescape transform: V -> U, result: Result<V>) -> Result<U> {
  return result.map(transform)
}

/**
 Performs transformation over value of Result.
 */
public func <^> <V>(@noescape transform: V -> Void, result: Result<V>) {
  result.forEach(transform)
}

// MARK: Apply
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

// MARK: Flat map
infix operator >>- {
associativity left
precedence 100
}

/**
  If there's no error, perform function that may yield Result with value and return wrapped result
  Left associative
*/
@warn_unused_result
public func >>- <V, U>(result: Result<V>, @noescape transform: V -> Result<U>) -> Result<U> {
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
@warn_unused_result
public func -<< <V, U>(@noescape transform: V -> Result<U>, result: Result<V>) -> Result<U> {
  return result.flatMap(transform)
}
