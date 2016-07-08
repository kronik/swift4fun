import Foundation
import UIKit

//Welcome!
print("Welcome to playground")

// Playground is a fully interactive environment:
for x in 0..<100 {
    log(Double(x))
}

// It helps deeper understand your code:
for x in (-2.0).stride(through: 2, by: 0.01) {
    pow((1.0 - pow((fabs(x) - 1.0), 2.0)), 0.5)
    acos(1.0 - fabs(x)) - M_PI
}

//Basic

let a = 1
let b: UInt = 2
let c: Float = 3
let bool: Bool = false

//Mutable vs Immutable
let aa = 1
var bb = 2

//aa = 2 // error!
bb = 3

let array = [1, 2, 3, 4, 5]
var mArray = [1, 2, 3, 4, 5]

mArray.append(100)

print(mArray)

//Unicode naming

let привет = "Hi"
let 💩 = "Hoolly shit"

print (💩)

//Tuples

let tupleA = ("a", 1)

print (tupleA)

let tupleB = (first: "b", second: "c")

print (tupleB)

print (tupleB.first)

//Optionals

var opt: UInt?

print(opt)

opt = 2

print(opt)

print( opt == nil)

if var optValue = opt {
    print ("Ho ho ho: " + String(optValue))
    
//    optValue = 1
    
    print (opt)
    
    opt = 1
    
    print (opt)
    print (optValue)
} else {
    print ("Empty")
}

func AAA() -> String {
    guard let optValue = opt else { return "" }
    
    print(optValue)
    
    return "\(optValue)"
}

//String interpolation

print ("I have a = \(a)")
print ("I have optional = \(opt)")

//Structs
struct Room {
    let devepers: UInt
    let nonDevelopers: Int?
    var cook: Int
}

let r = Room(devepers: 10, nonDevelopers: nil, cook: 5)

print(r)

//r.cook = 10 // Can't do this because of let

var rr = Room(devepers: 10, nonDevelopers: nil, cook: 5)

print(r)

rr.cook = 111

print(rr)

//Classes

class TV {
    let size: UInt = 32
}

//Enums

//enum Food {
//    case Pizza
//    case Pasta
//}
//
//let food = Food.Pizza
//
//print(food)

//enum Food: String {
//    case Pizza = "Pasta"
//    case Pasta = "Pizza"
//}
//
//let food = Food.Pizza
//
//print(food.rawValue)

enum Food {
    case Pizza(Bool)
    case Pasta(Bool, Bool)
    
    var howToCook: String {
        get {
            switch self {
                case .Pizza(let extraTopping):
                    return "Extra topping: \(extraTopping)"
                case .Pasta(let extraCheese, let ketchup):
                    return "Extra cheese: \(extraCheese) and maybe ketchup: \(ketchup)"
            }
        }
    }
}

let myPizza = Food.Pizza(true)

print(myPizza.howToCook)

let myPasta = Food.Pasta(false, true)

print(myPasta.howToCook)

print(AAA())









