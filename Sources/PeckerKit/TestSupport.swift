import Foundation

public func emit(message: String) {
    let filePath = "/Users/ming/Desktop/Testttt/Testttt/ViewController.swift"
    let line = 16
    let column = 6
    print("\(filePath):\(line):\(column): warning: \(message)")
}
