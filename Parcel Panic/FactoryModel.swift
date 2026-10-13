import Foundation

struct Point: Codable, Equatable { let x: Double; let y: Double }
enum ParcelKind: String, Codable, CaseIterable { case amber, teal, violet; var title: String { rawValue.capitalized }; var symbol: String { switch self { case .amber: return "cube.fill"; case .teal: return "diamond.fill"; case .violet: return "seal.fill" } } }
enum Equipment: String, Codable, CaseIterable { case diverter, sorter, booster; var title: String { switch self { case .diverter: return "Switch"; case .sorter: return "Sorter"; case .booster: return "Booster" } }; var symbol: String { switch self { case .diverter: return "arrow.triangle.branch"; case .sorter: return "line.3.horizontal.decrease"; case .booster: return "bolt.fill" } } }
struct Device: Codable, Equatable { var equipment: Equipment; var sideFirst = false; var filter: ParcelKind = .teal }
struct Station: Identifiable { let id: Int; let point: Point; let next: Int?; let side: Int?; let recipient: ParcelKind?; let slot: Bool }
struct Shipment { let kind: ParcelKind; let release: Double }
struct Level: Identifiable {
    let id: Int
    let title: String
    let lesson: String
    let stations: [Station]
    let shipments: [Shipment]
    let inventory: [Equipment: Int]
    let deadline: Double
    let solution: [Int: Device]
    var challenge: String = "Routing"
}
struct Freight: Identifiable { let id: Int; let kind: ParcelKind; var station: Int; var target: Int?; var progress: Double = 0; var duration: Double = 1 }
struct Outcome: Identifiable { let id = UUID(); let success: Bool; let message: String; let delivered: Int; let elapsed: Double; let fault: Int? }
struct FactoryEngine {
    let level: Level
    let layout: [Int: Device]
    var elapsed: Double = 0
    var released = 0
    var delivered = 0
    var freight: [Freight] = []
    var visits: [Int: Int] = [:]
    var outcome: Outcome?
    mutating func finish(_ success: Bool, _ message: String, _ fault: Int? = nil) { guard outcome == nil else { return }; outcome = Outcome(success: success, message: message, delivered: delivered, elapsed: elapsed, fault: fault) }
    mutating func depart(_ item: inout Freight) {
        let station = level.stations[item.station]
        if let recipient = station.recipient {
            if recipient == item.kind { delivered += 1 } else { finish(false, "A parcel reached the wrong dock.", station.id) }
            item.target = nil
            return
        }
        var target = station.next
        item.duration = 1
        if let device = layout[station.id] {
            switch device.equipment {
            case .diverter:
                let count = visits[station.id, default: 0]
                let side = (count % 2 == 0) == device.sideFirst
                target = side ? station.side : station.next
                visits[station.id] = count + 1
            case .sorter: target = item.kind == device.filter ? station.side : station.next
            case .booster: item.duration = 0.5
            }
        }
        item.target = target
        item.progress = 0
        if target == nil { finish(false, "The route ends before a delivery dock.", station.id) }
    }
    mutating func step(_ delta: Double = 0.05) {
        guard outcome == nil else { return }
        elapsed += delta
        while released < level.shipments.count && level.shipments[released].release <= elapsed + 0.00001 {
            var item = Freight(id: released, kind: level.shipments[released].kind, station: 0)
            depart(&item)
            freight.append(item)
            released += 1
        }
        var arrivals: [Int: Int] = [:]
        var remaining: [Freight] = []
        for var item in freight {
            guard let target = item.target else { continue }
            item.progress += delta / item.duration
            if item.progress >= 1 - 0.00001 {
                if arrivals[target] != nil { finish(false, "Two parcels reached the same junction together.", target) }
                arrivals[target] = item.id
                item.station = target
                depart(&item)
            }
            if item.target != nil { remaining.append(item) }
        }
        freight = remaining
        guard outcome == nil else { return }
        if delivered == level.shipments.count { finish(true, "Every parcel reached its delivery dock.") }
        else if elapsed > level.deadline { finish(false, "The delivery deadline has passed.", freight.first?.station) }
    }
}
