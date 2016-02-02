# Result

Simple Swift μ-framework that wraps your throwing functions results.

## How to install

### Cocoapods

[![CocoaPods](https://img.shields.io/cocoapods/p/RAMReel.svg)](https://cocoapods.org/pods/YetAnotherResult)
[![CocoaPods](https://img.shields.io/cocoapods/v/RAMReel.svg)](https://cocoapods.org/pods/YetAnotherResult)

`Podfile`:

~~~ruby
pod 'YetAnotherResult'
~~~

### Carthage

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

`Cartfile`:

~~~~ogdl
github "Skogetroll/Result" >= 1.2.8
~~~~

### Swift package manager

`Package.swift`:

~~~swift
import PackageDescription

let package = Package(
  …
  dependencies: [
    …
    .Package(url: "https://github.com/Skogetroll/Result.git", majorVersion: 1, minor: 2),
    …
  ]
  …
)
~~~

## How to use?

[Like this](https://rawgit.com/Skogetroll/Result/master/docs/Enums/Result.html#/s:FO6Result6ResultcurFMGS0_q__FT6unsafeFzT_q__GS0_q__):

~~~swift
let result = Result<Type> {
    // Your unsafe code resulting in Type or Error goes here
}
~~~

or [like this](https://rawgit.com/Skogetroll/Result/master/docs/Enums/Result.html#/s:FO6Result6ResultcurFMGS0_q__FKzT_q_GS0_q__):

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

#### [Map](https://rawgit.com/Skogetroll/Result/master/docs/Enums/Result.html#/s:FO6Result6Result3mapu__rFGS0_q__FFq_qd__GS0_qd___):

~~~swift
let resultString = Result<String>(try unsafelyGetString())
let stringLength = resultString.map { string in
  string.characters.count
}

// stringLength now contains either value of `String.Index.Distance` or error wrapped in Result<Distance>

// Or you can use operator `<^>` to perform map
process <^> resultString
// Here `process : String -> Void` gonna be called if and only if resultString resulted successfully
~~~

#### [Flat map](https://rawgit.com/Skogetroll/Result/master/docs/Enums/Result.html#/s:FO6Result6Result7flatMapu__rFGS0_q__FFq_GS0_qd___GS0_qd___):

~~~swift
let someResult = Result(try unsafelyGetResult())
let processedResult = someResult.flatMap { value in
	return Result(try someUnsafeProcessing(value))
}

// or you can use operators `>>-` and `-<<`

let processedResult = someResult >>- { value in Result(try someUnsafeProcessing(value)) }
~~~

#### [Apply](https://rawgit.com/Skogetroll/Result/master/docs/Enums/Result.html#/s:FO6Result6Result5applyu__rFGS0_q__FGS0_Fq_qd___GS0_qd___):

~~~swift
let resultedFunction: Result<A -> B> = …
let resultedValue: A = …

let result: Result<B> = resultedValue.apply(resultedFunction)

// or you can use operator `<*>`

let result: Result<B> = resultedFunction <*> resultedValue
~~~

#### [Wrap](https://rawgit.com/Skogetroll/Result/master/docs/Enums/Result.html#/s:ZFO6Result6Result4wrapu__rFMGS0_q__FFzqd__q_Fqd__GS0_q__):

~~~swift
func yourThrowingFunction(in: InType) throws -> (out: OutType) {
	…
}

let resultWrappedFunction: InType -> Result<OutType> = wrap(yourThrowingFunction)

let someInput: InType = …

// And we can get
let resultOutput = resultWrappedFunction(someInput)

// instead of
do {
	let output = try yourThrowingFunction(someInput)
}
~~~
