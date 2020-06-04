>Notice: The "dyld: Library not loaded: @rpath/lib_InternalSwiftSyntaxParser.dylib" or missing warnings are caused by a SwiftSyntax issue, [SwiftSyntax with Swift 5.1](https://forums.swift.org/t/swiftsyntax-with-swift-5-1/29051).

# Pecker

**Pecker** detects unused code. It's based on [IndexStoreDB](https://github.com/apple/indexstore-db.git) and [SwiftSyntax](https://github.com/apple/swift-syntax.git).

![](assets/example.png)

> Chinese Readme: [中文版readme](README_CN.md).

## Motivation

As your Swift project codebase grows, it is hard to locate unused code. You need to tell if some constructs are still in used. `pecker` does this job for you, easy and accurate.

## Features
`pecker` detects the following Swift constructs:

1. `class`
2. `struct`
3. `enum`
4. `protocol`
5. `func`
6. `typealias`
7. `operator`

## Installation

There're more than one way to install `pecker`.

### Using [Homebrew](http://brew.sh/)

```sh
$ brew install woshiccm/homebrew-tap/pecker
```

### Using [CocoaPods](https://cocoapods.org):

```sh
pod 'Pecker'
```

This will download the `pecker` binaries and dependencies in `Pods/` during your next run of `pod install` and will allow you to invoke it via `${PODS_ROOT}/Pecker/bin/pecker` in your script build phases.

This is the recommended way to install a specific version of `pecker` since it supports installing a specific stable version rather than head version.

### Using [Mint](https://github.com/yonaskolb/mint):

```
mint install woshiccm/Pecker

```

### Compiling from source

```
$ git clone https://github.com/woshiccm/Pecker.git
$ cd Pecker
$ make install
```

With that installed and in the `bin` folder, now it's ready to serve.

## Usage

### Xcode

Integrate `pecker` into an Xcode scheme to get warnings and errors displayed in the IDE. Just add a new "Run Script Phase" with:

```bash
if which pecker >/dev/null; then
  pecker
else
  echo "warning: Pecker not installed, download from https://github.com/woshiccm/Pecker"
fi
```

![](assets/runscript.png)

Alternatively, if you've installed Pecker via CocoaPods the script should look like this:

```bash
${PODS_ROOT}/Pecker/bin/pecker
```

### Terminal

>Note:  

>1. In terminal, since project index path can't be retrieved automatically there, so you need to set index path through `-i/--index-store-path`
>2. Need to set reporter as `json` and set `output_file`, the path can be both relative and absolute. If output_file is not specified, it defaults to be `pecker.result.json` in your project.

For example:

In `.pecker.yml`, the configuration is:

```
reporter: "json"
output_file: pecker.result.json
```

In terminal, you input:

```
$ pecker --path /Users/ming/Desktop/Testttt -i /Users/ming/Library/Developer/Xcode/DerivedData/Testttt-aohluxvofrwtfagozexmpeifvryf/Index/DataStore
```
  
### Command Line

```
pecker [OPTIONS]
```

* `-v/--version`: Prints the `pecker` version and exits.
* `--config`: The custom path for configuration yaml file.
* `-i/--index-store-path`: The Index path of your project, if unspecified, the default is ~Library/Developer/Xcode/DerivedData/{your project}/Index/DataStore.

Run `pecker` in the project target to detect. Project will search Swift files recursively.

## Rules

Current only 5 rules are included in Pecker, They are `skip_public`, `xctest`, `attributes`, `xml`, `comment`. You can add them to ` disabled_rules` if you don't need it. You can also check Source/PeckerKit/Rules directory to see their implementation.

### skip_public
This rule means skip detect public class, struct, function, etc. Usually the public code is provided for other users, so it is difficult to determine whether it is used. So we don't detect it by default. But in some cases, such as using `submodule` to organize code, you need to detect public code, you can add it to ` disabled_rules`.

### xctest
XCTest is special, we stipulate that ignore classes inherited from XCTestCase and functions of this class that hasPrefix "test" and do not contain parameters. 

```swift
class ExampleUITests: XCTestCase {

    func testExample() { //used
    }

    func test(name: String) { // unused
    }
    
    func get() { // unused
    }
}

```

### attributes

If a Declaration contains the attribute in `BlackListAttribute`, skip. Such as `IBAction`, we are continuously collecting, if you find new cases, please let us know.

```swift  
@IBAction func buttonTap(_ sender: Any) { // used       
}
```

### XML

If code is being used in .xib or storyboard, we say it's in use.

#### comment  

Code can be ignored with a comment inside a source file with the following format:

* Ignore specified code

```
// pecker:ignore 
```

For example:

```swift
// pecker:ignore
class TestCommentObject { // skip
    
    // pecker:ignore
    func test1() { // skip
    }
    
    func test2() { // unused
    }
}
```

* Ignore all symbols under scope   

```
// pecker:ignore all
```

For example:

```swift
// pecker:ignore all
class TestCommentObject { // skip
    
    func test1() { // skip
    }
    
    struct SubClass { // skip
        
        func test2() { // skip
        }
    }
}

```

#### Other rules

These rules are used by default, you cannot configure them.

**override**

Skip declarations that override another. This works for both subclass overrides & protocol extension overrides.

```swift

protocol ExampleProtocol {
	func test() // used
}

class Example: ExampleProtocol {
    func test() { // used
    }
}

class Animal {
    func run() {  // used
    }
}

class Dog: Animal {
    override func run() { // used
    }
}

```

**extensions**

Referenced elsewhere means used, except for extensions.

```swift
class UnusedExample { // unused
    
}

extension UnusedExample {
    
}

```


### Configuration

This is optional, will use default, if unspecified. Configure `pecker` by adding a `.pecker.yml` file from the directory you'll
run `pecker` from. The following parameters can be configured:

Rule inclusion:

* `disabled_rules`: Disable rules from the default enabled set.

Reporter inclusion: 

* xcode: Warnings displayed in the IDE.
* json: you can set path by `output_file`, and the path can be both  relative and absolute path, if unspecified, the default is `pecker.result.json` in current project directory.

   
   ![](assets/json_result.png)

```yaml
reporter: "xcode"

disabled_rules:
  - skip_public

included: # paths to include during detecting. `--path` is ignored if present.
  - ./
  
excluded: # paths to ignore during detecting. Takes precedence over `included`.
  - Carthage
  - Pods

excludedGroupName: # names of group to ignore during detecting.
  - SwiftPeckerTestUITests

blacklist_files: # files to ignore during detecting, only need to add file name, the file extension default is swift.
  - HomeViewController

blacklist_symbols: # symbols to ignore during detecting, contains class, struct, enum, etc.
  - AppDelegate
  - viewDidLoad

blacklist_superclass: # all the class inherit from class specified in the list will ignore
  - UITableViewCell

# If output_file is not specified, the defaults to be pecker.result.json in your project

output_file: pecker.result.jsonthe path can be both relative and absolute.
```

  
## Contributions and support

`pecker` is developed completely in the open.

Any contributing and pull requests are warmly welcome. If you are interested in developing `pecker`, submit ideas and submit pull requests!


## Licence
`pecker` is released under the [MIT License](https://opensource.org/licenses/MIT).
