# Pecker

`pecker` 是一个自动检测无用代码的工具，它基于 [IndexStoreDB](https://github.com/apple/indexstore-db.git) 和 [SwiftSyntax](https://github.com/apple/swift-syntax.git)。

![屏幕快照 2019-12-03 下午4.25.38.png](https://upload-images.jianshu.io/upload_images/2086987-29c1e983fb5b604b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

如果你有什么疑问可以随时联系我，我的推特 [Roy](https://twitter.com/Roy78463507)，邮箱: `roy.cao1991@gmail.com`。


> Language Switch: [中文](README_CN.md)。

## 为什么使它?
在我们的项目开发过程中，会写很多代码，随着时间推移，很多代码已经不再使用了，但是想发现他们并不容易。`pecker`能很自动的帮你定位到它们。

## 功能
`pecker` 能检测以下几种无用的代码.

1. class
2. struct
3. enum
4. protocol
5. function
6. typealias
7. operator

## 安装

### 手动

```
$ git clone https://github.com/woshiccm/Pecker.git
$ cd Pecker
$ make install
```

### mint

```
mint install woshiccm/Pecker
```

之后`pecker`就被安装到你的`bin`目录下，现在你就可以使用它了。

## 使用

### Xcode

1. 打开你的项目，选择TARGETS，点击Build Phases，新建一个Run Script Phase。
2. 放入以下脚本:

  `/usr/local/bin/pecker`
  
### 命令行

```
pecker [OPTIONS]

```

* `-v/--version`: 打印`pecker`版本.
* `-i/--index-store-path`: 项目Index路径，如果没有指定，默认是~Library/Developer/Xcode/DerivedData/<target>/Index/DataStore。

在指定项目中执行 `pecker`，将会遍历检测所有的swift文件。

### Rules
目前`pecker`仅有5个规则，他们是`skip_public`、`xctest`、`attributes`、`xml`和`comment`，如果你不需要这些中的某些规则，可以把它添加到` disabled_rules`中。你和可以在`Source/PeckerKit/Rules`中查看他们的实现。

#### skip_public
这个规则规定忽略public的class，struct，function等. 通常public的代码是开放给他人用的，很难判定这些代码是否是无用的。所以默认不检测public的代码。但有些时候，比如使用`submodule`的方式组织代码，那么你又想检测public的代码，你只需要把它添加到` disabled_rules`中。

#### xctest
XCTest 很特别，我们规定忽略继承自XCTest的类，以及以"test"开头但没有参数的方法。

```swift
class ExampleUITests: XCTestCase {

    func testExample() { //used
    }

    func test(name: String) { // unused
    }
    
    func get() { // unsed
    }
}

```

#### attributes
如果一个声明的修饰符中包含`BlackListAttribute`中的case, 忽略这个检测。例如`IBAction`，我们在持续收集这些修饰符，如果你发现新的cases，请告诉我们。
```swift
@IBAction func buttonTap(_ sender: Any) { // used
        
}

```

#### xml
如果代码在xib或者storyboard中被用到，也表示被使用。。如果你不需要这个规则，可以把它添加到` disabled_rules`中。

#### comment
可以通过在源代码中添加如下注释来忽略检测:

* 忽略某个指定代码

```
// pecker:ignore 
```

例如:

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

* 忽略所有的作用域下的代码  

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

一下这些规则是默认使用的，你不能配置它们。

**override**

跳过声明为override的方法，包含子类的override方法和protocol extension override方法。

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

class Dod: Animal {
    override func run() { // used
    }
}

```

**extensions**

extension也是引用，但是我们判定这不算做不被使用。

```swift
class UnusedExample { // unused
    
}

extension UnusedExample {
    
}

```


### Configuration

这个是可选的，如果不配置讲使用默认的。在`perker`项目中添加`.pecker.yml`，以下参数可以配置：

规则包含:

* `disabled_rules`: 从默认启用集中禁用规则。

报告方式包含: 

* xcode: 在Xcode中显示warning。
* json: 生成名为`pecker.result.json`的文件，你可以通过`output_file`来自定义路径，如果没有指定，默认为当前检测项目的文件下的路径。
  ![屏幕快照 2019-12-13 下午9.49.09.png](https://upload-images.jianshu.io/upload_images/2086987-29dbe4bb76af16ec.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

```yaml
reporter: "xcode"

disabled_rules:
  - skip_public

included: # paths to include during detecting. `--path` is ignored if present.
  - ./
  
excluded: # paths to ignore during detecting. Takes precedence over `included`.
  - Carthage
  - Pods

blacklist_files: # files to ignore during detecting, only need to add file name, the file extension default is swift.
  - HomeViewController

blacklist_symbols: # symbols to ignore during detecting, contains class, struct, enum, etc.
  - AppDelegate
  - viewDidLoad

output_file: "/Users/ming/Desktop/PeckerResultDirectory"
```

  
## 贡献和支持

`pecker` 完全是一开放的方法开发。

任何的贡献和pull requests都很受欢迎。如果你对开发`pecker`很感兴趣，提交你的想法和pull requests!

## 贡献者

## 协议
[MIT License](https://opensource.org/licenses/MIT)许可。