extension String: ErrorType {}

func unsafelyGetString() throws -> String {
  return "Hello world!"
}

let result = Result(try unsafelyGetString())

func show(x: Any) {
  print(x)
}
show <^> result

let length = result.map {
  $0.characters.count
}

print(length)