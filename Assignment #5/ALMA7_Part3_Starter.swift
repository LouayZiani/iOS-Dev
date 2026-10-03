// =============================================================
//  Station ALMA-7, Part III: The Repair Fleet
//  iOS Mobile Development · Module 5 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part3_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section. LegacyBeacon in
//     particular must be reached with an extension, not edited.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • The Health Rule must exist in exactly ONE place in this file.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Drone records recovered from the fleet registry.
/// One `kind` does not correspond to any drone type you will build.
let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]

/// Hull sensors. These are NOT drones — they never move and never work a shift.
let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal",  charge: 77)
]

/// Hardware from the original station. You may not add anything to this
/// declaration — no methods, no protocols, no properties.
struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(name: "ALMA-BEACON", signalStrength: 8)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 1 · The Power Cell

// Why a class and not a struct here?  -> A battery is one physical object that must be shared by reference, not copied, so a drone's `let cell` can still be drained.
final class PowerCell {
    private var charge: Int

    init(charge: Int) {
        self.charge = min(max(charge, 0), 100)   // clamp into 0...100
    }

    func level() -> Int {
        return charge
    }

    func spend(_ amount: Int) -> Bool {
        guard amount > 0, amount <= charge else { return false }
        charge -= amount
        return true
    }

    func recharge(by amount: Int) {
        guard amount > 0 else { return }
        charge += min(amount, 100 - charge)      // never above 100, no overflow on huge amounts
    }
}

// Encapsulation proof (leave this commented, with the compiler error):
// let cell = PowerCell(charge: 50)
// cell.charge = 100
// error: 'charge' is inaccessible due to 'private' protection level


// MARK: Level 2 · The Fleet

// 2.1  What does `final` on runOnce() buy you?  ->
//      It stops every subclass from overriding runOnce(), so the spend-then-work ritual is guaranteed identical for all drones.
class Drone {
    let id: String
    let cell: PowerCell

    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    var powerCost: Int { 10 }                    // overridable

    var statusLine: String {                     // "W-1: 80% ########.."
        let level = cell.level()
        return "\(id): \(level)% \(level.powerBar)"
    }

    var canRunAgain: Bool {                      // enough charge for one more task?
        return cell.level() >= powerCost
    }

    func performTask() -> Int { 0 }              // a bare drone does nothing

    final func runOnce() -> Int {
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }
}

// 2.2
final class WelderDrone: Drone {
    override var powerCost: Int { 25 }
    override func performTask() -> Int { 40 }

    func weldSeam() -> String {
        return "\(id) welds a seam"
    }
}

class ScannerDrone: Drone {
    override var powerCost: Int { 10 }
    override func performTask() -> Int { 15 }

    override var statusLine: String {
        return super.statusLine + " [scanner]"
    }
}

final class CargoDrone: Drone {
    override var powerCost: Int { 20 }
    override func performTask() -> Int { 25 }
}

// 2.3
func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let cell = PowerCell(charge: charge)
    switch kind {
    case "welder":  return WelderDrone(id: id, cell: cell)
    case "scanner": return ScannerDrone(id: id, cell: cell)
    case "cargo":   return CargoDrone(id: id, cell: cell)
    default:        return nil
    }
}

var fleet: [Drone] = []
for record in fleetData {
    if let drone = makeDrone(kind: record.kind, id: record.id, charge: record.charge) {
        fleet.append(drone)
    } else {
        print("WARNING: skipped record \(record.id), unknown drone kind \"\(record.kind)\"")
    }
}


// MARK: Level 3 · The Shift

func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    guard rounds > 0 else { return 0 }
    var totalWork = 0
    for _ in 1...rounds {
        for drone in fleet {
            totalWork += drone.runOnce()         // one call, different behaviour per object
        }
    }
    return totalWork
}

let totalWork = runShift(fleet, rounds: 3)
print("Shift complete: \(totalWork) work units")

var chargeSum = 0
var readyCount = 0
for drone in fleet {
    print("  \(drone.statusLine)")
    chargeSum += drone.cell.level()
    if drone.canRunAgain { readyCount += 1 }
}
print("Drones with enough charge for one more task: \(readyCount)")

let A = totalWork
let B = chargeSum
let C = readyCount


// MARK: Level 4 · Diagnostics

// 4.1
protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}

// 4.2
protocol Rechargeable {
    mutating func recharge(by amount: Int)
}

// Conformance for the class. Note: no `mutating` here.
// Why does Drone implement recharge(by:) without `mutating`?  ->
// `self` in a class is a reference, and the method changes the object it points to (the cell), not the reference itself, so nothing needs to be marked as mutated.
extension Drone: Diagnosable, Rechargeable {
    var componentID: String { id }
    var statusCode: Int { healthCode(forLevel: cell.level()) }

    func recharge(by amount: Int) {
        cell.recharge(by: amount)
    }
}

struct SensorModule: Diagnosable, Rechargeable {
    let id: String
    var chargeLevel: Int

    var componentID: String { id }
    var statusCode: Int { healthCode(forLevel: chargeLevel) }

    mutating func recharge(by amount: Int) {
        // Reuse PowerCell's clamping rules instead of writing them a second time.
        let cell = PowerCell(charge: chargeLevel)
        cell.recharge(by: amount)
        chargeLevel = cell.level()
    }
}

var sensors: [SensorModule] = []
for record in sensorData {
    sensors.append(SensorModule(id: record.id, chargeLevel: record.charge))
}

// Rechargeable demo on a throwaway copy (structs are values, so `sensors` is untouched).
var spareSensor = sensors[0]
spareSensor.recharge(by: 30)
print("Recharge demo: \(sensors[0].chargeLevel) -> \(spareSensor.chargeLevel)")

// 4.3
// Why could [Drone] never have held the sensors?  ->
// SensorModule is a struct and structs cannot inherit from Drone, but both can conform to Diagnosable.
func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var lines: [String] = []
    for component in components {
        lines.append(component.diagnose())
    }
    return lines.joined(separator: "\n")
}

var components: [Diagnosable] = []
for drone in fleet { components.append(drone) }
for sensor in sensors { components.append(sensor) }
print("--- Diagnostics report ---")
print(diagnosticsReport(components))


// MARK: Level 5 · Shared Behaviour

// 5.1 · default diagnose() + the single home of the Health Rule
extension Diagnosable {
    func diagnose() -> String {
        return "\(componentID): code \(statusCode)"
    }

    /// THE Health Rule. This is the only place in the file where the thresholds exist.
    func healthCode(forLevel level: Int) -> Int {
        if level < 20 { return 2 }               // critical
        if level < 50 { return 1 }               // warning
        return 0                                 // nominal
    }
}

// 5.2 · the beacon you cannot edit
extension LegacyBeacon: Diagnosable {
    var componentID: String { name }
    var statusCode: Int { healthCode(forLevel: signalStrength) }

    func diagnose() -> String {
        return "[LEGACY] \(componentID): code \(statusCode), original-station hardware"
    }
}

components.append(beacon)
print("--- Diagnostics report (with beacon) ---")
print(diagnosticsReport(components))

var statusTotal = 0
for component in components {
    statusTotal += component.statusCode
}
let D = statusTotal

// 5.3
extension Int {
    var powerBar: String {                       // 42 -> "####......"
        let filled = min(max(self / 10, 0), 10)
        return String(repeating: "#", count: filled)
             + String(repeating: ".", count: 10 - filled)
    }
}


// MARK: Level 6 · Incident Reports
// Reality check: THREE of these fail to compile (1, 2, 3) and only ONE compiles and lies (4),
// not two and two as the brief says. The broken originals stay commented out; the fixes are live code.

/*
// Report 1
class PatchDrone: Drone {
    func performTask() -> Int {
        return 30
    }
}

// Report 2
final class HeavyWelder: WelderDrone {
    override func runOnce() -> Int {
        return 999
    }
}

// Report 3
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
print(first.weldSeam())

// Report 4
protocol Labelled {
    var componentID: String { get }
}

extension Labelled {
    func label() -> String { "generic component" }
}

struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let parts: [Labelled] = [Thruster(componentID: "T-1")]
print(parts[0].label())
*/

// Report 1 (does not compile)
//  Expected: a drone that produces 30 work units.
//  Actual:   error: overriding declaration requires an 'override' keyword.
//  Rule:     performTask() already exists in Drone, so redefining it is an override and Swift makes you say so
//            (this protects you from accidentally replacing a method you didn't know existed).
//  Fix:      add `override`.
class PatchDrone: Drone {
    override func performTask() -> Int {
        return 30
    }
}

// Report 2 (does not compile)
//  Expected: a heavy welder that does 999 work per shift step.
//  Actual:   two errors: cannot inherit from final class 'WelderDrone', and runOnce() is final and can't be overridden.
//  Rule:     `final` closes a class to subclassing and a method to overriding. runOnce() is the shared ritual (spend, then work).
//  Fix:      subclass Drone, not WelderDrone, and change only the cost and the work; the ritual stays untouchable.
final class HeavyWelder: Drone {
    override var powerCost: Int { 25 }
    override func performTask() -> Int { 999 }
}

// Report 3 (does not compile)
//  Expected: first.weldSeam() works because the object really is a welder.
//  Actual:   error: value of type 'Drone' has no member 'weldSeam'.
//  Rule:     the compiler checks against the declared type (Drone), not the runtime type.
//  Fix:      conditional cast. as? returns an optional because the object may not actually be a WelderDrone, so the cast can fail.
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
if let welder = first as? WelderDrone {
    print(welder.weldSeam())
}

// Report 4 (compiles and lies: prints "generic component")
//  Expected: "thruster T-1".
//  Actual:   "generic component".
//  Rule:     label() is not a protocol requirement, only an extension method, so calls through the protocol type are
//            resolved statically to the extension version. A requirement goes through the witness table and is dispatched dynamically.
//  Fix:      declare `func label() -> String` inside the protocol; the extension then only supplies the default.
protocol Labelled {
    var componentID: String { get }
    func label() -> String
}

extension Labelled {
    func label() -> String { "generic component" }
}

struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let parts: [Labelled] = [Thruster(componentID: "T-1")]
print(parts[0].label())


// MARK: Finale · Mission Code

let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("MISSION CODE: \(missionCode)")


// MARK: Bonus

// Two ways to forbid using Drone directly (kept in comments so the fleet still runs):
//  Runtime:      inside Drone.init, `precondition(type(of: self) != Drone.self, "Drone is abstract")`,
//                or `fatalError("subclass must override")` in performTask(). The mistake only shows up when the line runs.
//  Compile time: make the base a protocol. A protocol cannot be instantiated at all, so `Drone(...)` simply won't build.
//                (A private/internal init only helps across files or modules, not inside a single playground.)

// Protocol-based redesign: base type is a protocol, WelderUnit is a struct.
protocol WorkerDrone {
    var id: String { get }
    var cell: PowerCell { get }
    var powerCost: Int { get }
    func performTask() -> Int
}

extension WorkerDrone {
    // Not a requirement on purpose: through the protocol type this version always wins (see Report 4),
    // which gives a protocol the same "ritual can't be changed" guarantee that `final` gave the class.
    func runOnce() -> Int {
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }
}

struct WelderUnit: WorkerDrone {
    let id: String
    let cell: PowerCell
    var powerCost: Int { 25 }
    func performTask() -> Int { 40 }
}

let welderUnit = WelderUnit(id: "WU-1", cell: PowerCell(charge: 100))
print("Bonus: WelderUnit produced \(welderUnit.runOnce()) units, cell now \(welderUnit.cell.level())%")

// Comparison: The protocol version can't be misused as a bare Drone and works with structs, enums and types you
// don't own, but every conformer must restate id/cell (no stored properties in protocols or extensions).
// The class version shares storage and init for free but locks you into single inheritance and reference semantics.
// For this station I'd pick the protocol design, and if drones had to share mutable state I'd keep that state in a
// class like PowerCell (as here) or use classes for the drones, because a struct drone would otherwise need
// `mutating` everywhere and copies would silently diverge.


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why does a class satisfy a `mutating` protocol requirement without the
    keyword, while a struct must write it?

    A class instance is accessed through a reference, and the method changes the object that reference points to,
    never the reference itself, so there is no "mutation of self" to declare. A struct is a value: changing any of its
    properties replaces `self`, so the method has to be marked `mutating` (self is passed in-out) and can only be
    called on a `var`. The protocol says `mutating` so structs are allowed to implement it; classes just ignore the keyword.

 2. One thing inheritance does that protocols cannot, and one thing
    protocols do that inheritance cannot:

    Inheritance: share stored properties and an initializer (id, cell, init) plus implementation in one base class,
    and let subclasses call super. Protocols (and their extensions) can't hold stored properties.
    Protocols: unite unrelated types, a class (Drone), a struct (SensorModule) and a type I couldn't edit
    (LegacyBeacon), behind one interface. Inheritance only works between classes, and only from one superclass.

 3. What does `final` prevent, and what did it protect in runOnce()?

    `final` prevents overriding (on a method or property) or subclassing (on a class). On runOnce() it guarantees
    no drone type can change the ritual (spend powerCost, bail out with 0 on failure, otherwise performTask()),
    so nobody can skip the battery check or fake results (Report 2). It also lets the compiler call it directly.

 4. In Report 4, why did the protocol extension's method win?

    label() was not a requirement of Labelled. Methods that only exist in an extension are dispatched statically,
    based on the declared type. The array element type is Labelled, so the compiler picked the extension's
    version at compile time and the struct's own label() was never consulted. Adding label() to the protocol makes
    it a requirement, dispatched dynamically through the witness table, so Thruster's version wins.
*/