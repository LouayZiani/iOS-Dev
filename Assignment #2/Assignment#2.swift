// import Cocoa (im using online compiler so i had to comment it out for now)

// Easy Tasks
// 1. arr creation and access

let arrFruits: [String] =  ["apples", "oranges", "kiwi", "mango", "banana"]
print(arrFruits[2])

// 2. Set creation and manip:
var favNumsSet: Set<Int> = [3, 5, 11] // let immutable, var is mutable
favNumsSet.insert(9)

print(favNumsSet)

// 3. dict creation and access:
var plDict: [String:Int] = [
  "Swift": 2014,
  "Julia" : 2012,
  "Python" : 1991
]

// print(plDict["Swift"]) // returns optional(2014) cuz key might not exist
print(plDict["Swift"]!) // i used the ! to force unwrap


// 4. arr element update
var arrColors: [String] = ["red", "blue", "green", "grey"]
arrColors[1] = "pink"
print(arrColors)



// medium tasks
// 1. set intersection:
var set1: Set<Int> = [1, 2, 3, 4]
var set2: Set<Int> = [3, 4, 5, 6]

// let intrsct = set1 & set2
let intrsct: Set<Int> = set1.intersection(set2)
print(intrsct)

// 2. dict update:
var StudsName: [String: Int] = [
  "Louay": 90,
  "Jake" : 85,
  "Laurie": 68
]

StudsName["Laurie"] = 89
print(StudsName)

// 3. arr merge:
let arr1: [String] = ["apple", "banana"]
let arr2: [String] = ["cherry", "date"]

let final_arr: [String] = arr1 + arr2
print(final_arr)


// Hard tasks
// 1. Dict key addition:
var countryCluhb: [String: Int] = [
  "Morocco": 39, // in millionss
  "USA": 343,
  "Kazakhstan": 21
]

countryCluhb["Canada"] = 41
print(countryCluhb)

// 2. Set union and substract
let setAnimals1: Set<String> = ["cat", "dog"]
let setAnimals2: Set<String> = ["dog", "mouse"]

// let result : Set<String> = setAnimals1 | setAnimals2
let result : Set<String> = setAnimals1.union(setAnimals2)

// let final_res : Set<String> = result - setAnimals2
let final_res : Set<String> = result.subtracting(setAnimals2)

print(final_res)


// 3. Nested Collec:
let nestedStuds: [String : [Int]] = [
  "Lucas" : [100, 78, 93],
  "Jamie" : [96, 65, 87],
  "Maddie": [84, 100, 79]
]

print(nestedStuds["Lucas"]?[1] ?? 0) // its cuz nestedStuds["Lucas"] returns an optional [Int]? --> because key might not exist