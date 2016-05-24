import UIKit
import Foundation

//Functions
func add(a: Int, b: Int) -> String {
    return "\(a + b)"
}

func substruct(a: Int, b: Int = 0) -> String {
    return "\(a - b)"
}

func returnMeTupple(a: Int, b: Int) -> (Int, Int) {
    return (a * b, a + b)
}

func inOutParams(inout a: Int) {
    a += 1
}

print(add(1, b: 2))

print(substruct(10, b: 5))

let aaa = returnMeTupple(10, b: 3)

print (aaa.0)
print (aaa.1)

var b = 10

inOutParams(&b)

print (b)

//Closures
func calc(a: Int, b: Int, anotherFunc: (Int, Int) -> Int) -> Int {
    return anotherFunc(a, b)
}

print(calc(1, b: 10, anotherFunc: {(first: Int, second: Int) -> Int in
    return first + second
}))

typealias MyFunc = (Int, Int) -> Int

func calc2(a: Int, b: Int, anotherFunc: MyFunc) -> Int {
    return anotherFunc(a, b)
}

let myFunc = {(first: Int, second: Int) -> Int in
    return first + second
}

print(calc2(1, b: 10, anotherFunc: myFunc))

func calc3(a: Int, b: Int, anotherFunc: (Int, Int) -> String) -> String {
    return anotherFunc(a, b)
}

print(calc3(10, b: 10, anotherFunc: add))

//Async operations (Mac OSX and iOS only)
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
    let value = calc(1, b: 2, anotherFunc: { (first, second) -> Int in
        return first * second
    })
    
    dispatch_async(dispatch_get_main_queue(), { 
        print(value)
    })
}

// class
class Executor {
    func executeInBackground() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            
            let value = calc(1, b: 2, anotherFunc: { [weak self] (first, second) -> Int in
                guard let this = self else { return 0 }
                
                print(this)
                
                return first * second
            })
            
            dispatch_async(dispatch_get_main_queue(), {
                print(value)
            })
        }
    }
}








