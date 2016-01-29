# Result

Simple Swift η-framework that wraps your throwing functions results.

## How to use?

[Like this]():

~~~swift
let result = Result<Type> {
    // Your unsafe code resulting in Type or Error goes here
}
~~~

or [like this]():

~~~swift
let result = Result<Type>(/* Your unsafe code resulting in Type or Error goes here */)
~~~

## How to get value?

~~~swift
let value: Type? = result.value
~~~

## How to get error?

~~~swift
let error: ErrorType? = result.error
~~~

## How to ~~crash application~~ return back to throwing paradigm?

~~~swift
let value: Type = try result.unwrap()
~~~

## What else can I do with `Result<V>`?

### You can use

#### [Map]():

~~~swift
let resultString = Result<String>(try unsafelyGetString())
let stringLength = resultString.map { string in
  string.characters.count
}

// stringLength now contains either value of `String.Index.Distance` or error wrapped in Result<Distance>

// Or you can use operator `<^>` to perform map
process <^> resultString // Here `process : String -> Void` gonna be called if and only if resultString resulted successfully
~~~

#### [Flat map]():

~~~swift
~~~

#### [Apply]():
~~~swift
~~~
