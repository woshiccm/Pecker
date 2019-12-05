# Pecker

`pecker` is a tool to automatically detect unused code. It based on [IndexStoreDB](https://github.com/apple/indexstore-db.git) and [SwiftSyntax](https://github.com/apple/swift-syntax.git).

![屏幕快照 2019-12-03 下午4.25.38.png](https://upload-images.jianshu.io/upload_images/2086987-29c1e983fb5b604b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

If you have questions, feel free to connect me, my Twitter [Roy](https://twitter.com/home), Email: `roy.cao1991@gmail.com`. 

```
NOTE: Current only support Swift unused code detect, will support Objective-C in the future,
and will optimization details.
```

## Why use this?

During the project development process, you may write a lot of code. Over time, a lot of code is no longer used, but it is difficult to find. Pecker can help you locate these unused code conveniently and accurately.

## Features
`pecker` can detect the following kinds of unused Swift code.

1. class
2. struct
3. enum
4. protocol
5. function
6. typealias
7. operator

## Installation

Clone the repo and run `make install`

With that installed and on our `bin` folder, now we can use it.

## Usage

1. Click on your project in the file list, choose your target under TARGETS, click the Build Phases tab and add a New Run Script Phase by clicking the little plus icon in the top left.
2. Paste the following script:

  `/usr/local/bin/pecker`
  
  
## Command Line Usage

```
pecker [OPTIONS]

```

* `-v/--version`: Prints the `swift-format` version and exits.
* `-h/--hide-warning`: If specified, don't show warning.
* `-i/--index-store-path`: The Index path of your project, if unspecified, the default is ~Library/Developer/Xcode/DerivedData/<target>/Index/DataStore.

Run `pecker` in the project target to detect. Project will be searched Swift files recursively.

## Rules
The basic principle is that if remove the code, the compiler will report errors.

### Class, Struct, Protocols, Enums, Typealias

1. Referenced elsewhere means used, except for extensions. 

```swift

protocol ExampleProtocol {
    
}

class Example: ExampleProtocol {
    
}

class Example {
    
}

let example = Example()

```
The following  `UnusedExample` is unused.

```
class UnusedExample { // unused
    
}

extension UnusedExample {
    
}
```

### functions
The situation of function is very complicated, `override` is very special

#### override 
There are two kinds of `override`. If a function is override function, means used. If a function is overrided, means used.

```
// The first
protocol ExampleProtocol {

	func test()
    
}

class Example: ExampleProtocol {

    func test() {
    }
}

// The second
class Animal {
    
    func run() {
        
    }

}

class Dod: Animal {
    
    override func run() {
        
    }
}


```


## Note
1. Don't detect public class, function, etc.
2. Don't detect override function.
3. Don't detect Pods and Carthage directory.
  
## Contributions and support

`pecker` is developed completely in the open

Any contributing and pull requests are warmly welcome., If you are interested in developing `pecker`, submit ideas and submit pull requests!

## Contributors

## Licence
`pecker` is released under the [MIT License](https://opensource.org/licenses/MIT).


