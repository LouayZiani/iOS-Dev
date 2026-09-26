// =============================================================
//  Station ALMA-7: Rescue Protocol
//  iOS Mobile Development · Module 3 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER CODE section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Use the exact function names from the assignment PDF.
// =============================================================


// MARK: - =================== STARTER CODE ===================
// MARK: - Do not modify anything in this section

typealias Reading = (sensor: String, value: Int)

/// Splits a string at the first occurrence of the separator.
/// splitOnce("O2:87", by: ":") -> ("O2", "87")
/// splitOnce("hello", by: ":") -> nil
func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int      // 1 = evacuated first
    var module: Module?    // nil = in open space
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")

// MARK: - ================= END OF STARTER CODE =================


// MARK: - =================== YOUR SOLUTION ===================
// Uncomment each signature when you start working on it.


// MARK: Level 1 · Decoding Telemetry

// 1.1
func parseReading(_ raw: String) -> Reading? {
    guard let (sensor, valueStr) = splitOnce(raw, by: ":"),
          !sensor.isEmpty,
          let value = Int(valueStr),
          value >= 0 || sensor == "TEMP"
    else {
        return nil
    }
    return (sensor, value)
}

print("parseReading(\"O2:87\") =", parseReading("O2:87") as Any)     // Optional((sensor: "O2", value: 87))
print("parseReading(\"TEMP:-12\") =", parseReading("TEMP:-12") as Any) // Optional((sensor: "TEMP", value: -12))
print("parseReading(\"RAD:-1\") =", parseReading("RAD:-1") as Any)   // nil
print("parseReading(\":55\") =", parseReading(":55") as Any)         // nil

// 1.2
func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var valid: [Reading] = []
    var invalidCount = 0
    for line in lines {
        if let reading = parseReading(line) {
            valid.append(reading)
        } else {
            invalidCount += 1
        }
    }
    return (valid, invalidCount)
}

let logResult = parseLog(rawLog)
print("parseLog(rawLog) valid count:", logResult.valid.count, "invalid count:", logResult.invalidCount)
print("parseLog on a tiny sample:", parseLog(["O2:5", "nonsense", "TEMP:-3"]))

let A = logResult.invalidCount


// MARK: Level 2 · Analysis

// 2.1 - our own filter
func select(_ readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] {
    var result: [Reading] = []
    for reading in readings {
        if isIncluded(reading) {
            result.append(reading)
        }
    }
    return result
}

func values(of readings: [Reading]) -> [Int] {
    var result: [Int] = []
    for reading in readings {
        result.append(reading.value)
    }
    return result
}

let validReadings = logResult.valid

let o2Readings = select(validReadings) { $0.sensor == "O2" }
print("O2 readings:", o2Readings)
let o2Values = values(of: o2Readings)
print("O2 values:", o2Values)

let pressReadings = select(validReadings) { $0.sensor == "PRESS" }
print("PRESS readings:", pressReadings, "-> values:", values(of: pressReadings))

// 2.2 - stats
func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard !values.isEmpty else { return nil }
    var lowest = values[0]
    var highest = values[0]
    var sum = 0
    for v in values {
        if v < lowest { lowest = v }
        if v > highest { highest = v }
        sum += v
    }
    return (lowest, highest, Double(sum) / Double(values.count))
}

func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}

print("stats(3, 8, 1) =", stats(3, 8, 1) as Any)   // (min: 1, max: 8, average: 4.0)
print("stats() =", stats() as Any)                 // nil
print("stats(of: o2Values) =", stats(of: o2Values) as Any)

let B: Int
if let o2Stats = stats(of: o2Values) {
    B = Int(o2Stats.average)
} else {
    B = 0
}
print("Average O2 value, as Int (B):", B)

// 2.3 · The Closure Ladder (5 sorts, then compare results in code)
// 1. full closure syntax with types and explicit return
let sortedFull = validReadings.sorted(by: { (a: Reading, b: Reading) -> Bool in
    return a.value > b.value
})

// 2. types inferred from context
let sortedInferred = validReadings.sorted(by: { (a, b) in
    return a.value > b.value
})

// 3. implicit return
let sortedImplicit = validReadings.sorted(by: { (a, b) in a.value > b.value })

// 4. shorthand argument names
let sortedShorthand = validReadings.sorted(by: { $0.value > $1.value })

// 5. trailing closure
let sortedTrailing = validReadings.sorted { $0.value > $1.value }

// Reading is a tuple, so arrays of it can't use `==` directly — compare field by field.
func readingsMatch(_ a: [Reading], _ b: [Reading]) -> Bool {
    guard a.count == b.count else { return false }
    for i in 0..<a.count {
        if a[i].sensor != b[i].sensor || a[i].value != b[i].value {
            return false
        }
    }
    return true
}

let allSortsMatch = readingsMatch(sortedFull, sortedInferred)
    && readingsMatch(sortedInferred, sortedImplicit)
    && readingsMatch(sortedImplicit, sortedShorthand)
    && readingsMatch(sortedShorthand, sortedTrailing)

print("All five sorts agree:", allSortsMatch)
print("Sorted (desc by value):", sortedTrailing)


// MARK: Level 3 · Temperature Stabilization
// Safe range: 18...24 inclusive.

// 3.1 · Protocols as values
func heatUp(_ t: Int) -> Int { t + 5 }
func coolDown(_ t: Int) -> Int { t - 3 }
func hold(_ t: Int) -> Int { t }

func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < 18 {
        return heatUp
    } else if temp > 24 {
        return coolDown
    } else {
        return hold
    }
}

print("heatUp(10) =", heatUp(10))
print("coolDown(30) =", coolDown(30))
print("hold(21) =", hold(21))

let coldCase = chooseProtocol(for: 10)
print("chooseProtocol(for: 10) picked heatUp ->", coldCase(10))
let hotCase = chooseProtocol(for: 30)
print("chooseProtocol(for: 30) picked coolDown ->", hotCase(30))

// 3.2 - runUntilStable
func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) {
    var temp = start
    var steps = 0
    while (temp < 18 || temp > 24) && steps < maxSteps {
        let apply = chooseProtocol(for: temp)
        temp = apply(temp)
        steps += 1
    }
    return (temp, steps, temp >= 18 && temp <= 24)
}

print("runUntilStable(from: 31) =", runUntilStable(from: 31))                 // (finalTemp: 22, steps: 3, isStable: true)
print("runUntilStable(from: -100, maxSteps: 5) =", runUntilStable(from: -100, maxSteps: 5)) // (finalTemp: -75, steps: 5, isStable: false)

// C = steps to stabilize the lowest valid TEMP reading in the log (found with select + stats)
let tempReadings = select(validReadings) { $0.sensor == "TEMP" }
let tempValues = values(of: tempReadings)

var C = 0
if let tempStats = stats(of: tempValues) {
    C = runUntilStable(from: tempStats.min).steps
}
print("Lowest TEMP stats:", stats(of: tempValues) as Any, "-> steps to stabilize (C):", C)


// MARK: Level 4 · The Crew

// Starter `crew` array order: [Louay, Jake, Luke, Alex] — array indexing
// on a plain (non-optional) array needs no unwrap, so this stays `!`-free.
let louay = crew[0]
let jake = crew[1]
let luke = crew[2]
let alex = crew[3]

// 4.1
func oxygenLevel(of member: CrewMember) -> Int? {
    member.module?.oxygenTank?.level
}

print("oxygenLevel(of: timur) =", oxygenLevel(of: timur) as Any)   // Optional(40)
print("oxygenLevel(of: dana) =", oxygenLevel(of: dana) as Any)     // nil — Dock has no tank
print("oxygenLevel(of: nurlan) =", oxygenLevel(of: nurlan) as Any) // nil — no module

// 4.2
func status(of member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        let location = member.module?.name ?? "open space"
        return "\(member.name): no data (\(location))"
    }
    let flag = level < 20 ? "CRITICAL" : "OK"
    return "\(member.name): \(level)% \(flag)"
}

for member in crew {
    print(status(of: member))
}


// 4.3 · Oxygen transfer
@discardableResult
func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int {
    guard amount > 0 else { return 0 }
    let transferAmount = min(amount, source, 100 - target)
    guard transferAmount > 0 else { return 0 }
    source -= transferAmount
    target += transferAmount
    return transferAmount
}

// Transfer 30 units from Lab to Hab (both tanks are optional — unwrap safely, no `!`)
if var labLevel = lab.oxygenTank?.level, var habLevel = hab.oxygenTank?.level {
    let moved = transferOxygen(from: &labLevel, to: &habLevel, amount: 30)
    lab.oxygenTank?.level = labLevel
    hab.oxygenTank?.level = habLevel
    print("Transferred \(moved) units — Lab now \(labLevel), Hab now \(habLevel)")
}

// Edge cases, proven with two more calls on throwaway tanks:
var edgeSource = 10
var edgeTarget = 95
print("Negative amount does nothing:", transferOxygen(from: &edgeSource, to: &edgeTarget, amount: -5))
print("Clamped to target capacity:", transferOxygen(from: &edgeSource, to: &edgeTarget, amount: 10), "-> target is now", edgeTarget)

let D = hab.oxygenTank?.level ?? 0
print("Hab oxygen after transfer (D):", D)

// 4.4 · Evacuation order
func evacuationOrder(_ names: String..., roster: [String: CrewMember]) -> [String] {
    var found: [CrewMember] = []
    for name in names {
        guard let member = roster[name] else {
            print("Unknown crew member: \(name)")
            continue
        }
        found.append(member)
    }
    let byPriority = found.sorted { $0.priority < $1.priority }
    var orderedNames: [String] = []
    for member in byPriority {
        orderedNames.append(member.name)
    }
    return orderedNames
}

print(evacuationOrder("Louay", "Ghost", "Luke", "Alex", roster: roster))
// Unknown crew member: Ghost

print(evacuationOrder("Alex", "Luke", roster: roster))
// ["Aigerim", "Nurlan"]


// MARK: Level 5 · The Saboteur's Logbook
//
// Original code (kept here only for ref):
//
// func reportOxygen(for member: CrewMember) -> String {
//     let tank = member.module!.oxygenTank!
//     return "\(member.name): \(tank.level)%"
// }
//
// func firstCritical(in crew: [CrewMember]) -> String {
//     var result: String?
//     for member in crew {
//         if oxygenLevel(of: member)! < 20 {
//             result = member.name
//         }
//     }
//     return result!
// }
//
// Problems, one comment per bug:
//
// reportOxygen(for:)
// 1. `member.module!` force-unwraps an optional Module — crashes for any
//    crew member with no module, e.g. Nurlan (open space).
// 2. `.oxygenTank!` force-unwraps an optional Tank even once the module
//    exists — crashes for a member whose module has no tank, e.g. Dana (Dock).
//
// firstCritical(in:)
// 3. `oxygenLevel(of: member)!` force-unwraps a value that's nil for anyone
//    with no oxygen data — crashes on Dana or Nurlan with the starter crew.
// 4. `return result!` crashes whenever nobody in the array is critical,
//    since `result` is still nil at that point.
// 5. Logic bug, not a `!`: the loop never stops once it finds a match, so
//    `result` keeps getting overwritten by every critical member it sees.
//    The function is named "firstCritical" but actually returns the LAST
//    one. It's invisible with the starter data because only Aigerim is
//    below 20% — with a single critical crew member, "first" and "last"
//    happen to be the same person.

func reportOxygen(for member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        return "\(member.name): no data"
    }
    return "\(member.name): \(level)%"
}

func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        if let level = oxygenLevel(of: member), level < 20 {
            return member.name
        }
    }
    return nil
}

print(reportOxygen(for: aigerim)) // Aigerim: 12%
print(reportOxygen(for: dana))    // Dana: no data

print("firstCritical(in: crew) =", firstCritical(in: crew) as Any) // Optional("Aigerim") — only one critical member here

// Test that proves the "returns last, not first" bug is actually fixed:
// two crew members below 20%, so order matters.
let testHabModule = Module(name: "TestHab", oxygenTank: Tank(level: 5))
let testLabModule = Module(name: "TestLab", oxygenTank: Tank(level: 8))
let orderTestCrew = [
    CrewMember(name: "First", role: "Test", priority: 1, module: testHabModule),
    CrewMember(name: "Second", role: "Test", priority: 2, module: testLabModule)
]
// The buggy original would print "Second" here (last match wins).
// The fixed version returns on the first match, so it prints "First".
print("firstCritical(in: orderTestCrew) =", firstCritical(in: orderTestCrew) as Any) // Optional("First")


// MARK: Finale · Launch Code

let launchCode = "\(A)-\(B)-\(C)-\(D)"
print("LAUNCH CODE: \(launchCode)")


// MARK: Bonus

func makeAlarm(threshold: Int) -> (Int) -> Bool {
    var fireCount = 0
    return { level in
        let isCritical = level < threshold
        if isCritical {
            fireCount += 1
            print("Alarm #\(fireCount)")
        }
        return isCritical
    }
}

let alarm = makeAlarm(threshold: 20)
print(alarm(12)) // Alarm #1 -> true
print(alarm(40)) // false
print(alarm(5))  // Alarm #2 -> true


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. guard let vs if let beyond syntax:

    `guard let` requires the enclosing scope to exit (return / continue /
    break / throw) when the condition fails, and the unwrapped value stays
    in scope for the REST of the function afterward. `if let` only makes
    the value available inside its own `{ }` block — once that block ends,
    it's gone.

    Example where `if let` makes things noticeably worse: `status(of:)`.
    With `guard let` the happy path stays flat:

        guard let level = oxygenLevel(of: member) else { return "...no data" }
        return "\(member.name): \(level)% ..."

    With `if let`, every line that needs `level` has to live nested one
    level deeper inside the `if`, and the "no data" case has to be an
    `else` hanging off the same block — for a function with several
    sequential optionals this turns into a pyramid of nested `if let`s.

 2. Why can't you pass [Int] to stats(_ values: Int...)?

    `Int...` isn't "an array parameter" — it's the compiler collecting
    individually-passed Int arguments into an array *for you*. Swift
    doesn't spread an existing array into variadic slots at the call site
    (no `stats(someArray)` magic, unlike e.g. Python's `*args`). If you
    want to hand it an array directly, you need a parameter actually typed
    `[Int]` — which is exactly why `stats(of:)` exists as a separate
    overload, and why the variadic one just forwards to it.

 3. Why doesn't transferOxygen(from: &x, to: &x, amount: 5) compile?

    Because both `source` and `target` are `inout`, and Swift enforces
    exclusive access to a variable for the duration of a call — you can't
    hand out two simultaneous mutable references to the same memory. If it
    compiled, the function would be reading/writing `x` through two
    aliases in the same call, and it'd be undefined which write "wins."
    The compiler rejects it as a conflicting access to memory, which is
    exactly the bug (silently corrupting a tank by transferring to itself)
    it's preventing.

 4. Why doesn't oxygenLevel(of: dana) ?? "no data" compile?

    `oxygenLevel(of:)` returns `Int?`, and `"no data"` is a `String`. `??`
    requires its right-hand default to match the wrapped type on the left
    (or be another `Int?`) — it can't unify `Int` and `String`. You'd need
    to unwrap first and produce a `String` either way, e.g.:

        if let level = oxygenLevel(of: dana) {
            print("\(level)%")
        } else {
            print("no data")
        }

 5. Full type of chooseProtocol and how to read it:

    `(Int) -> (Int) -> Int`, i.e. `(Int) -> ((Int) -> Int)`. Read it
    inside-out: it's a function that takes an `Int` and returns another
    function — one that itself takes an `Int` and returns an `Int`.
    `chooseProtocol` is a higher-order function because what it hands back
    is itself a function, not a plain value.

 Bonus. Where does the alarm counter live after makeAlarm returns?

    On the heap, inside the closure's captured environment. Because the
    returned closure captures `fireCount` by reference (it mutates it),
    Swift keeps that variable alive for as long as the closure itself is
    alive — even though `makeAlarm`'s own stack frame is long gone. Only
    that one closure instance (`alarm`) has a reference to it, so it's
    effectively private state that lives exactly as long as `alarm` does.
*/