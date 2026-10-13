import SwiftUI
import Combine
import UIKit

struct SavedFactory: Codable {
    var completed: Set<Int> = []
    var layouts: [Int: [Int: Device]] = [:]
    var haptics = true
    var campaignRevision: Int? = Campaign.revision
}
final class FactoryStorage {
    private let defaults: UserDefaults
    init(defaults: UserDefaults = .standard) { self.defaults = defaults }
    func load() -> SavedFactory {
        guard let data = defaults.data(forKey: "factoryProgress"), var saved = try? JSONDecoder().decode(SavedFactory.self, from: data) else { return SavedFactory() }
        if saved.campaignRevision != Campaign.revision {
            saved.layouts = [:]
            saved.campaignRevision = Campaign.revision
            save(saved)
        }
        return saved
    }
    func save(_ value: SavedFactory) { if let data = try? JSONEncoder().encode(value) { defaults.set(data, forKey: "factoryProgress") } }
}
final class FactoryViewModel: ObservableObject {
    @Published var saved: SavedFactory
    @Published var level = Campaign.levels[0]
    @Published var layout: [Int: Device] = [:]
    @Published var selected: Equipment = .diverter
    @Published var selectedStation: Int?
    @Published var engine: FactoryEngine?
    @Published var running = false
    @Published var result: Outcome?
    @Published var faultStation: Int?
    @Published var notice = "Choose equipment, then tap a marked socket."
    private let storage: FactoryStorage
    init(storage: FactoryStorage = FactoryStorage()) { self.storage = storage; saved = storage.load() }
    var editing: Bool { engine == nil }
    var available: [Equipment] { Equipment.allCases.filter { level.inventory[$0, default: 0] > 0 } }
    func remaining(_ equipment: Equipment) -> Int { level.inventory[equipment, default: 0] - layout.values.filter { $0.equipment == equipment }.count }
    func unlocked(_ level: Level) -> Bool { level.id == 1 || saved.completed.contains(level.id - 1) }
    func open(_ value: Level) { level = value; layout = saved.layouts[value.id] ?? [:]; selected = available.first ?? .diverter; engine = nil; result = nil; faultStation = nil; running = false; selectedStation = nil; notice = "Choose equipment, then tap a marked socket." }
    func persist() { saved.layouts[level.id] = layout; storage.save(saved) }
    func feedback() { if saved.haptics { UISelectionFeedbackGenerator().selectionChanged() } }
    func place(_ station: Station) {
        guard editing, station.slot else { return }
        selectedStation = station.id
        if layout[station.id] != nil { return }
        guard remaining(selected) > 0 else { notice = "No units remaining. Remove an installed unit to reuse it."; return }
        if selected != .booster && station.side == nil { notice = "This socket supports a Booster only."; return }
        layout[station.id] = Device(equipment: selected)
        notice = "Equipment installed. Tap it to configure or remove."
        persist(); feedback()
    }
    func configure(_ device: Device) { guard editing, let id = selectedStation else { return }; layout[id] = device; persist(); feedback() }
    func remove() { guard editing, let id = selectedStation else { return }; layout[id] = nil; selectedStation = nil; persist(); feedback() }
    func clear() { guard editing else { return }; layout = [:]; selectedStation = nil; persist() }
    func start() { engine = FactoryEngine(level: level, layout: layout); selectedStation = nil; result = nil; faultStation = nil; running = true; feedback() }
    func tick() {
        guard running, var simulation = engine else { return }
        simulation.step()
        engine = simulation
        if let outcome = simulation.outcome {
            running = false
            result = outcome
            faultStation = outcome.fault
            if outcome.success { saved.completed.insert(level.id); storage.save(saved) }
            feedback()
        }
    }
    func edit() { if let result { notice = result.message }; running = false; engine = nil; result = nil }
    func pause() { running = false }
    func toggleHaptics(_ value: Bool) { saved.haptics = value; storage.save(saved) }
    func reset() { saved = SavedFactory(); storage.save(saved); open(Campaign.levels[0]) }
}
