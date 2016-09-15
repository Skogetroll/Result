// MARK: - Result

/**
  Wraps result of throwing code and allows to map embedded value
*/
public enum Result<V> {
  /// Resulted in Error
  case error(Error)
  /// Successfully aquired a Value
  case value(V)
  
  // MARK: Initialization
  /**
    Init with unsafe code
    
    ```swift
    let result = Result<V> { 
      // Your unsafe code, that results either in value of type V or in error
    }
    ```
  */
  public init(unsafe: () throws -> V) {
    do {
      self = .value(try unsafe())
    } catch (let error) {
      self = .error(error)
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
  public init(_ unsafe: @autoclosure () throws -> V) {
    do {
      self = .value(try unsafe())
    } catch (let error) {
      self = .error(error)
    }
  }
  
  // MARK: Pure
  /**
    Wraps value in Result
  */
  public static func pure(_ value: V) -> Result<V> {
    return .value(value)
  }
  
  // MARK: Wrap
  /**
    Wrap some throwing function from `U -> V` in `U -> Result<V>` function
  */
  public static func wrap<U>(_ function: @escaping (U) throws -> V) -> ((U) -> Result) {
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
    case .error(let error):
      throw error
    case .value(let value):
      return value
    }
  }
  
  /**
    Unwrap value as optional
  */
  public var value: V? {
    switch self {
    case .value(let value):
      return value
    case .error:
      return nil
  	}
  }
  
  /**
    Unwrap error as optional
  */
  public var error: Error? {
    switch self {
    case .error(let error):
      return error
    case .value:
      return nil
    }
  }
  
  // MARK: Map
  /**
    If there's no error, perform function with value and return wrapped result
  */
  public func map<U>(_ transform: (V) -> U) -> Result<U> {
    switch self {
    case .value(let value):
      return .value(transform(value))
    case .error(let error):
      return .error(error)
    }
  }
  
  /**
   Performs transformation over value of Result.
   */
  public func forEach(_ transform: (V) -> Void) {
    switch self {
    case .value(let value):
      transform(value)
    case .error:
      break
    }
  }
  
  // MARK: Flat map
  /**
    If there's no error, perform function that may yield Result with value and return wrapped result
  */
  public func flatMap<U>(_ transform: (V) -> Result<U>) -> Result<U> {
    switch self {
    case .error(let error):
      return .error(error)
    case .value(let value):
      switch transform(value) {
      case .error(let error):
        return .error(error)
      case .value(let value):
        return .value(value)
      }
    }
  }
  
  // MARK: Apply
  /**
    Apply function wrapped in Result to Result-vrapped value
  */
  public func apply<U>(_ transform: Result<(V) -> U>) -> Result<U> {
    switch self {
    case .error(let error):
      return .error(error)
    case .value(let value):
      switch transform {
      case .error(let error):
        return .error(error)
      case .value(let transform):
        return .value(transform(value))
      }
    }
  }
}

// MARK: - Functions

// MARK: Pure
/**
  Wraps value in Result
*/
public func pure<V>(_ value: V) -> Result<V> {
  return Result<V>.pure(value)
}

/**
 Wrap some throwing function from `U -> V` in `U -> Result<V>` function
 */
public func wrap<V, U>(_ original: @escaping (V) throws -> U) -> ((V) -> Result<U>) {
  return Result<U>.wrap(original)
}

// MARK: Map

infix operator <^> : ResultApplicativePrecedence

/**
  If there's no error, perform function with value and return wrapped result
*/
public func <^> <V, U>(transform: (V) -> U, result: Result<V>) -> Result<U> {
  return result.map(transform)
}

/**
 Performs transformation over value of Result.
 */
public func <^> <V>(transform: (V) -> Void, result: Result<V>) {
  result.forEach(transform)
}

// MARK: Apply
infix operator <*> : ResultApplicativePrecedence

/**
  Apply function wrapped in Result to Result-vrapped value
*/
public func <*> <V, U>(transform: Result<(V) -> U>, result: Result<V>) -> Result<U> {
  return result.apply(transform)
}

// MARK: Flat map
infix operator >>- : ResultMonadicPrecedenceLeft

/**
  If there's no error, perform function that may yield Result with value and return wrapped result
  Left associative
*/
public func >>- <V, U>(result: Result<V>, transform: (V) -> Result<U>) -> Result<U> {
  return result.flatMap(transform)
}

infix operator -<< : ResultMonadicPrecedenceRight

/**
  If there's no error, perform function that may yield Result with value and return wrapped result
  Right associative
*/
public func -<< <V, U>(transform: (V) -> Result<U>, result: Result<V>) -> Result<U> {
  return result.flatMap(transform)
}

// MARK: - Operator precedence groups
// Yes, it based on Runes precedence groups: https://github.com/thoughtbot/Runes

precedencegroup ResultApplicativePrecedence {
  associativity: left
  higherThan: LogicalConjunctionPrecedence
  lowerThan: NilCoalescingPrecedence
}

precedencegroup ResultMonadicPrecedenceLeft {
  associativity: left
  lowerThan: LogicalDisjunctionPrecedence
  higherThan: AssignmentPrecedence
}

precedencegroup ResultMonadicPrecedenceRight {
  associativity: right
  lowerThan: LogicalDisjunctionPrecedence
  higherThan: AssignmentPrecedence
}
