// =============================================================
//  Station ALMA-7, Part II: The Teleporter Incident
//  iOS Mobile Development · Module 4 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part2_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Default to struct. Use class only where the task says so.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Splits a line into fields.
/// fields("crate:101:120")            -> ["crate", "101", "120"]
/// fields("livestock:lab mice:12:2")  -> ["livestock", "lab mice", "12", "2"]
/// fields("junk")                     -> ["junk"]
func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

/// Cargo manifest as recovered from the damaged recorder.
let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

/// Oxygen readings. One of these deck names is not a real deck.
let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

/// Crew records, straight from the personnel file.
let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 1 · The Deck Register

// 1.1
enum Deck: String, CaseIterable {
    case bridge, lab, cargo, medbay, engine

    var evacuationPriority: Int {
        switch self {
        case .bridge: return 1
        case .medbay: return 2
        case .lab: return 3
        case .engine: return 4
        case .cargo: return 5
        }
    }
}

print("Level 1: Deck Register:")
for deck in Deck.allCases {
    print("\(deck.rawValue): evacuation priority \(deck.evacuationPriority)")
}

// 1.2
enum AlarmLevel: Int {
    case green = 0
    case yellow
    case orange
    case red

    static func level(forTotalMass mass: Int) -> AlarmLevel {
        let steps = mass / 500
        let capped = min(steps, AlarmLevel.red.rawValue)
        return AlarmLevel(rawValue: capped) ?? .red
    }
}

print("AlarmLevel(0 kg)   -> \(AlarmLevel.level(forTotalMass: 0))")
print("AlarmLevel(940 kg) -> \(AlarmLevel.level(forTotalMass: 940)), AlarmLevel(4000 kg) -> \(AlarmLevel.level(forTotalMass: 4000))")


// MARK: Level 2 · The Manifest

// 2.1
enum ManifestEntry {
    case crate(id: Int, massKg: Int)
    case container(code: String, massKg: Int)
    case livestock(species: String, count: Int, massPerUnitKg: Int)
    case unknown(raw: String)
}

// 2.2
func parseEntry(_ line: String) -> ManifestEntry {
    let parts = fields(line)
    let tag = parts[0]

    switch tag {
    case "crate":
        guard parts.count == 3,
              let id = Int(parts[1]),
              let massKg = Int(parts[2]) else {
            return .unknown(raw: line)
        }
        return .crate(id: id, massKg: massKg)

    case "container":
        guard parts.count == 3,
              let massKg = Int(parts[2]) else {
            return .unknown(raw: line)
        }
        return .container(code: parts[1], massKg: massKg)

    case "livestock":
        guard parts.count == 4,
              let count = Int(parts[2]),
              let massPerUnitKg = Int(parts[3]) else {
            return .unknown(raw: line)
        }
        return .livestock(species: parts[1], count: count, massPerUnitKg: massPerUnitKg)

    default:
        return .unknown(raw: line)
    }
}

// 2.3
func mass(of entry: ManifestEntry) -> Int {
    switch entry {
    case .crate(_, let massKg):
        return massKg
    case .container(_, let massKg):
        return massKg
    case .livestock(_, let count, let massPerUnitKg):
        return count * massPerUnitKg
    case .unknown:
        return 0
    }
}

print("Level 2: Manifest:")
var totalMass = 0
var unknownCount = 0
for line in rawManifest {
    let entry = parseEntry(line)
    let entryMass = mass(of: entry)
    totalMass += entryMass
    if case .unknown = entry {
        unknownCount += 1
    }
    print("  line \"\(line)\" -> \(entry), mass = \(entryMass)")
}
let A = totalMass
print("Total manifest mass (A) = \(A), unknown lines = \(unknownCount)")


// MARK: Level 3 · Crew Snapshots

// 3.1
struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int

    mutating func breathe(_ amount: Int) {
        oxygen = max(0, oxygen - amount)
    }

    mutating func move(to deck: Deck) {
        self.deck = deck
    }

    mutating func reviveInMedbay() {
        self = CrewSnapshot(name: name, deck: .medbay, oxygen: 100)
    }

    static func rookie(named name: String) -> CrewSnapshot {
        CrewSnapshot(name: name, deck: .bridge, oxygen: 100)
    }
}

// 3.2
var crewRoster: [CrewSnapshot] = []
for record in crewData {
    if let deck = Deck(rawValue: record.deck) {
        crewRoster.append(CrewSnapshot(name: record.name, deck: deck, oxygen: record.oxygen))
    } else {
        print("Warning: '\(record.name)' lists unknown deck '\(record.deck)', skipping.")
    }
}

print("Level 3: Crew Snapshots:")
for member in crewRoster {
    print("  \(member.name) on \(member.deck.rawValue), oxygen \(member.oxygen)")
}

// 3.3 · Value-semantics demonstration (copy / plain parameter / inout)
func attemptChange(_ snapshot: CrewSnapshot) {
    var local = snapshot
    local.oxygen = 5
}

func forceChange(_ snapshot: inout CrewSnapshot) {
    snapshot.oxygen = 5
}

print("3.3 value-semantics proof:")
var proofSnapshot = CrewSnapshot.rookie(named: "Proof")

var proofCopy = proofSnapshot
proofCopy.oxygen = 1
print("  1) copy changed             -> original: \(proofSnapshot.oxygen), copy: \(proofCopy.oxygen)")

print("  2) before plain-function call: \(proofSnapshot.oxygen)")
attemptChange(proofSnapshot)
print("     after plain-function call:  \(proofSnapshot.oxygen)")

print("  3) before inout call:          \(proofSnapshot.oxygen)")
forceChange(&proofSnapshot)
print("     after inout call:           \(proofSnapshot.oxygen)")


// MARK: Level 4 · The Teleport Pod

// 4.1
final class TeleportPod {
    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?

    // A struct gets a memberwise init for free because the compiler can see
    // every stored property at once. A class has to support inheritance and
    // shared references, so the compiler never assumes how to build one —
    // the initializer must always be written by hand.
    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        self.occupant = nil
    }

    func load(_ crew: CrewSnapshot) -> Bool {
        guard occupant == nil, chargeLevel >= 20 else { return false }
        occupant = crew
        return true
    }

    func fire() -> CrewSnapshot? {
        guard let crew = occupant else { return nil }
        occupant = nil
        chargeLevel -= 20
        return crew
    }

    // Bonus 1: deinit must live inside the class body itself (Swift does not
    // allow adding deinit through an extension), so it is placed here.
    deinit {
        print("  [deinit] TeleportPod \(id) is being deallocated.")
    }
}

// 4.2 · Charge ledger: load+fire three times, then fire an empty pod
func crewMember(named name: String, in roster: [CrewSnapshot]) -> CrewSnapshot? {
    for member in roster {
        if member.name == name {
            return member
        }
    }
    return nil
}

print("Level 4: Teleport Pod")
let pod = TeleportPod(id: "P-1", chargeLevel: 100)

if let timur = crewMember(named: "Timur", in: crewRoster) {
    _ = pod.load(timur)
    _ = pod.fire()
}
print("  after step 1 (Timur):      charge = \(pod.chargeLevel)")

if let dana = crewMember(named: "Dana", in: crewRoster) {
    _ = pod.load(dana)
    _ = pod.fire()
}
print("  after step 2 (Dana):       charge = \(pod.chargeLevel)")

if let nurlan = crewMember(named: "Nurlan", in: crewRoster) {
    _ = pod.load(nurlan)
    _ = pod.fire()
}
print("  after step 3 (Nurlan):     charge = \(pod.chargeLevel)")

let emptyFireResult = pod.fire()
print("  after step 4 (empty fire): result = \(String(describing: emptyFireResult)), charge = \(pod.chargeLevel)")

let C = pod.chargeLevel
print("Charge ledger final (C) = \(C)")

// 4.3 · Reference-semantics demonstration
print("4.3 reference-semantics proof:")
let podRefA = TeleportPod(id: "REF", chargeLevel: 50)
let podRefB = podRefA
podRefB.chargeLevel = 999
print("  class:  podRefA.chargeLevel = \(podRefA.chargeLevel), podRefB.chargeLevel = \(podRefB.chargeLevel)")

var structRefA = CrewSnapshot.rookie(named: "RefTest")
var structRefB = structRefA
structRefB.oxygen = 999
print("  struct: structRefA.oxygen = \(structRefA.oxygen), structRefB.oxygen = \(structRefB.oxygen)")
// Rule demonstrated: assigning a class instance copies the REFERENCE (both
// names point at the same object on the heap), but assigning a struct
// copies the VALUE (each name owns a fully independent instance).


// MARK: Level 5 · Station Systems

// 5.1
final class Station {
    let callSign: String
    var oxygenByDeck: [Deck: Int]

    var hullIntegrity: Int {
        willSet {
            print("  [willSet] hullIntegrity going from \(hullIntegrity) to \(newValue)")
        }
        didSet {
            if hullIntegrity > 100 {
                hullIntegrity = 100
            } else if hullIntegrity < 0 {
                hullIntegrity = 0
            }
        }
    }

    lazy var fullDiagnostics: String = {
        print("  Running full scan...")
        return "Diagnostics for \(callSign): hull \(hullIntegrity)%, total oxygen \(totalOxygen)"
    }()

    var totalOxygen: Int {
        var sum = 0
        for value in oxygenByDeck.values {
            sum += value
        }
        return sum
    }

    var averageOxygen: Int {
        get {
            totalOxygen / oxygenByDeck.count
        }
        set {
            var allDecks: [Deck] = []
            for deck in oxygenByDeck.keys {
                allDecks.append(deck)
            }
            for deck in allDecks {
                oxygenByDeck[deck] = newValue
            }
        }
    }

    init(callSign: String, hullIntegrity: Int, readings: [(deck: String, oxygen: Int)]) {
        self.callSign = callSign
        self.hullIntegrity = hullIntegrity
        var map: [Deck: Int] = [:]
        for reading in readings {
            if let deck = Deck(rawValue: reading.deck) {
                map[deck] = reading.oxygen
            } else {
                print("Warning: reading for unknown deck '\(reading.deck)' skipped.")
            }
        }
        self.oxygenByDeck = map
    }
}

print("Level 5: Station Systems")
let station = Station(callSign: "ALMA-7", hullIntegrity: 100, readings: deckReadings)
let B = station.averageOxygen
print("Station \(station.callSign): totalOxygen = \(station.totalOxygen), averageOxygen (B) = \(B)")

print("First access to fullDiagnostics:")
print(station.fullDiagnostics)
print("Second access to fullDiagnostics (no scan message should print):")
print(station.fullDiagnostics)

// 5.2 · The clamp trap: 130, then -40, then 55
print("5.2 clamp trap:")
station.hullIntegrity = 130
print("  after setting 130: hullIntegrity = \(station.hullIntegrity)")
station.hullIntegrity = -40
print("  after setting -40: hullIntegrity = \(station.hullIntegrity)")
station.hullIntegrity = 55
print("  after setting 55:  hullIntegrity = \(station.hullIntegrity)")
// Why the clamp doesn't loop forever: in Swift 5 mode, assigning directly to a property from inside its own willSet/didSet (hullIntegrity = 100, here)
// is special-cased by the compiler and does NOT re-trigger the observers. The clamped value is stored once and the didSet body simply returns.


// MARK: Level 6 · Incident Reports
// Three of these compile and are wrong. One does not compile.
// For each: expectation, actual behaviour, the language rule, the fix.

/*
Report 1
--------
var roster = crewRoster
for var member in roster {
    member.oxygen -= 10
}
print(roster[0].oxygen)   // author expected the crew to have lost oxygen

Expected: roster[0].oxygen to be 10 lower.
Actual:   roster[0].oxygen is unchanged.
Compiles: yes.
Rule:     CrewSnapshot is a struct. A for-in loop hands each iteration a
          fresh COPY of the element. Writing "var member" only makes that
          local copy mutable — it is never written back into the array.
          Mutating `member` only mutates the copy, not roster's element.
Fix:
    for i in 0..<roster.count {
        roster[i].oxygen -= 10
    }
    print(roster[0].oxygen)

Report 2
--------
let podA = TeleportPod(id: "A", chargeLevel: 100)
let podB = podA
podB.chargeLevel = 0
print(podA.chargeLevel)   // author expected 100

Expected: 100.
Actual:   0.
Compiles: yes.
Rule:     TeleportPod is a class. `let podA` only freezes which OBJECT the
          name podA refers to — it does not freeze that object's own `var`
          properties. podB is a second reference to the very same object,
          so mutating chargeLevel through podB is visible through podA too.
Fix: to actually protect podA's value, chargeLevel would need to be a `let`,
     or podB would need to be an independent copy, e.g.
     TeleportPod(id: podA.id, chargeLevel: podA.chargeLevel).

Report 3
--------
struct Logbook {
    var entries: [String] = []
    func add(_ entry: String) {
        entries.append(entry)
    }
}

Expected: add(_:) appends an entry to the log.
Actual:   DOES NOT COMPILE.
Rule:     Logbook is a struct. `add` is not marked `mutating`, so inside it
          `self` (and therefore `entries`) is treated as immutable.
          `entries.append` is itself a mutating method, so calling it here
          fails to compile: "cannot use mutating member on immutable value:
          'self' is immutable".
Fix:
    mutating func add(_ entry: String) {
        entries.append(entry)
    }

Report 4
--------
let snapshot = CrewSnapshot.rookie(named: "Dana")
snapshot.oxygen = 40        // <- this line does not compile

let pod = TeleportPod(id: "B", chargeLevel: 50)
pod.chargeLevel = 10        // <- this line compiles fine

`snapshot` is a struct held in a `let`. For a struct, `let` freezes the
WHOLE VALUE, every stored property included, because the variable name IS
the value. Result: "cannot assign to property: 'snapshot' is a 'let'
constant".

`pod` is a class held in a `let`. For a class, `let` only freezes the
REFERENCE — which object `pod` points to — not that object's own `var`
properties. The object itself is still mutable through any reference to
it, so `pod.chargeLevel = 10` is completely legal.

That is exactly what `let` protects in each case: for a struct, the data
itself; for a class, only the pointer to the data.
*/


// MARK: Level 7 · Sealing the Black Box

// The leaky original:
//
// class FlightRecorder {
//     var entries: [String] = []
//     var isSealed = false
// }
//
// Your sealed version below. One comment per access keyword.

final class FlightRecorder {
    // private: hides the storage completely, so outside code cannot
    // replace or clear the whole list directly (e.g. recorder.entries = []).
    private var entries: [String] = []

    // private(set): anyone can READ isSealed, but only this type can WRITE
    // it, so it can never be flipped back to false from outside.
    private(set) var isSealed = false

    var entryCount: Int {
        entries.count
    }

    var transcript: String {
        var result = ""
        for entry in entries {
            result += entry + "\n"
        }
        return result
    }

    func add(_ entry: String) {
        guard !isSealed else {
            print("  [recorder] rejected: already sealed.")
            return
        }
        entries.append(entry)
    }

    func seal() {
        isSealed = true
    }

    // fileprivate: visible to other code in this same file (like the free
    // function below) but invisible outside the file/module, so it lets a
    // trusted helper elsewhere in the file inspect the raw log without
    // exposing that ability to arbitrary outside callers.
    fileprivate func rawEntryDump() -> [String] {
        entries
    }
}

// A free function elsewhere in the file that uses the fileprivate helper:
func auditTranscript(of recorder: FlightRecorder) -> String {
    let dump = recorder.rawEntryDump()
    var summary = "AUDIT (\(dump.count) entries): "
    for i in 0..<dump.count {
        if i > 0 { summary += " | " }
        summary += dump[i]
    }
    return summary
}

print("--- Level 7: Black Box ---")
let recorder = FlightRecorder()
recorder.add("Engine startup nominal")
recorder.add("Oxygen levels stable")
print("  entries so far: \(recorder.entryCount)")
recorder.seal()
recorder.add("This entry should be rejected")
print("  transcript:\n\(recorder.transcript)")
print("  \(auditTranscript(of: recorder))")

// Trying to break it from outside the type:
// recorder.entries = []
// error: 'entries' is inaccessible due to 'private' protection level
// recorder.isSealed = false
// error: cannot assign to property: 'isSealed' setter is inaccessible


// MARK: Finale · Integrity Code

let D = AlarmLevel.level(forTotalMass: A).rawValue
let integrityCode = "\(A)-\(B)-\(C)-\(D)"
print("INTEGRITY CODE: \(integrityCode)")


// MARK: Bonus

print("--- Bonus ---")
var podOutside: TeleportPod? = nil
do {
    let podX = TeleportPod(id: "BONUS-1", chargeLevel: 40)
    podOutside = podX
    print("  inside do-block: podX and podOutside both hold the pod.")
}
print("  after do-block: podOutside still holds it, deinit has NOT fired yet.")
podOutside = nil
print("  after clearing podOutside: deinit should have fired just above this line.")

func samePod(_ a: TeleportPod, _ b: TeleportPod) -> Bool {
    a === b
}
let podIdentityA = TeleportPod(id: "ID-1", chargeLevel: 10)
let podIdentityB = podIdentityA
let podIdentityC = TeleportPod(id: "ID-1", chargeLevel: 10)
print("  podIdentityA === podIdentityB (same object):             \(samePod(podIdentityA, podIdentityB))")
print("  podIdentityA === podIdentityC (equal contents, different object): \(samePod(podIdentityA, podIdentityC))")
// === cannot be used on CrewSnapshot because it is a struct: each variable
// holds its own independent copy of the value, so there is no single shared
// object in memory for === to compare — identity only makes sense for
// reference types.


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why did CrewSnapshot get an initializer for free and TeleportPod did not?
    CrewSnapshot is a struct with only stored properties, all visible to the
    compiler at once, so Swift safely generates a memberwise init. TeleportPod
    is a class: classes support inheritance and shared references, so the
    compiler never assumes how one should be built — the init must be
    written by hand.

 2. What does `mutating` do to self, and why do classes never need it?
    In a struct's method, `mutating` lets the method replace `self` (or its
    stored properties) with a new value — without it, self is `let` inside
    the method. Classes never need it because an instance is a reference:
    changing a var property mutates the object on the heap, not the
    reference itself, so there's nothing about "self" that needs unlocking.

 3. In Report 4 both values are `let`. What exactly does `let` freeze for a
    struct, and what does it freeze for a class?
    For a struct, `let` freezes the entire value — every stored property —
    because the variable name and the value are the same thing. For a
    class, `let` only freezes the reference (which object the name points
    to); the object's own `var` properties can still change through it.

 4. Why must a lazy property be var? When does lazy change behaviour, not
    just performance?
    A `lazy` property is set the first time it's read, which is itself a
    mutation from "not yet computed" to "computed" — that requires `var`.
    It changes behaviour (not just timing) whenever its initializer reads
    other properties that might change before first access: a lazy property
    captures values at first-access time, not at declaration time, so if
    those other properties change before it's first touched, the lazy value
    reflects the later state — and if they change after, it never updates,
    unlike a computed property.

 5. private vs fileprivate: where in your FlightRecorder would private be
    too strict?
    rawEntryDump() needs to be called from auditTranscript(of:), a free
    function in the same file but outside the FlightRecorder type. `private`
    only allows access from within the type itself, so it would make
    rawEntryDump uncallable from that free function. `fileprivate` allows
    any code in the same file to call it — exactly the access this helper
    needs.

 Bonus. On which line does deinit fire, and why can't === be used on
 CrewSnapshot?
    deinit fires at `podOutside = nil`, not at the end of the do-block:
    leaving the do-block only drops podX's reference, but podOutside still
    holds one, so the reference count never reaches zero until podOutside is
    cleared. === can't be used on CrewSnapshot because it's a struct — value
    types have no identity, only copies of data, so there's no single object
    in memory for === to compare.
*/
