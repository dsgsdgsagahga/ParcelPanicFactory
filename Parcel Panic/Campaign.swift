import Foundation

enum Campaign {
    static let revision = 2
    private static func node(_ id: Int, _ x: Double, _ y: Double, _ next: Int? = nil, side: Int? = nil, dock: ParcelKind? = nil, slot: Bool = false) -> Station {
        Station(id: id, point: Point(x: x, y: y), next: next, side: side, recipient: dock, slot: slot)
    }
    private static func queue(_ kinds: [ParcelKind], spacing: Double) -> [Shipment] {
        kinds.enumerated().map { Shipment(kind: $0.element, release: Double($0.offset) * spacing) }
    }
    static let levels: [Level] = [
        Level(id: 1, title: "First Shift", lesson: "An alternating queue needs alternating routes. Set the first direction before starting.", stations: [
            node(0, 0.1, 0.5, 1),
            node(1, 0.32, 0.5, 2, side: 3, slot: true),
            node(2, 0.58, 0.24, 4),
            node(3, 0.58, 0.76, 5, slot: true),
            node(4, 0.87, 0.24, dock: .amber),
            node(5, 0.87, 0.76, dock: .teal)
        ], shipments: queue([.amber, .teal, .amber, .teal], spacing: 1.2), inventory: [.diverter: 1], deadline: 8, solution: [1: Device(equipment: .diverter)], challenge: "Alternating routes"),
        Level(id: 2, title: "Batch Inspection", lesson: "Repeated markings arrive in batches. Inspect the queue: the side route leads to the Amber dock.", stations: [
            node(0, 0.1, 0.78, 1),
            node(1, 0.3, 0.78, 2, side: 3, slot: true),
            node(2, 0.58, 0.78, 4),
            node(3, 0.3, 0.22, 5),
            node(4, 0.87, 0.78, dock: .teal),
            node(5, 0.87, 0.22, dock: .amber)
        ], shipments: [Shipment(kind: .amber, release: 0), Shipment(kind: .amber, release: 0.6), Shipment(kind: .teal, release: 1.8), Shipment(kind: .teal, release: 2.4), Shipment(kind: .amber, release: 4), Shipment(kind: .teal, release: 4.6)], inventory: [.sorter: 1], deadline: 8.5, solution: [1: Device(equipment: .sorter, filter: .amber)], challenge: "Batch sorting"),
        Level(id: 3, title: "Three Destinations", lesson: "Violet parcels need their own dock. Chain two inspections to separate all three markings.", stations: [
            node(0, 0.1, 0.5, 1),
            node(1, 0.32, 0.5, 2, side: 3, slot: true),
            node(2, 0.58, 0.5, 4, side: 5, slot: true),
            node(3, 0.32, 0.14, dock: .violet),
            node(4, 0.87, 0.25, dock: .amber),
            node(5, 0.87, 0.8, dock: .teal)
        ], shipments: queue([.violet, .amber, .teal, .violet, .teal, .amber], spacing: 0.9), inventory: [.sorter: 2], deadline: 8.5, solution: [1: Device(equipment: .sorter, filter: .violet), 2: Device(equipment: .sorter)], challenge: "Three-way inspection"),
        Level(id: 4, title: "Express Lane", lesson: "Two long routes share a tight deadline. Spend your single speed boost on the branch that finishes last.", stations: [
            node(0, 0.08, 0.5, 1),
            node(1, 0.28, 0.5, 2, side: 3, slot: true),
            node(2, 0.48, 0.2, 4, slot: true),
            node(3, 0.48, 0.8, 5, slot: true),
            node(4, 0.7, 0.2, 6),
            node(5, 0.7, 0.8, 7),
            node(6, 0.9, 0.3, dock: .amber),
            node(7, 0.9, 0.7, dock: .teal)
        ], shipments: [Shipment(kind: .amber, release: 0), Shipment(kind: .teal, release: 0.6), Shipment(kind: .teal, release: 1.7), Shipment(kind: .amber, release: 2.4), Shipment(kind: .teal, release: 3.5)], inventory: [.sorter: 1, .booster: 1], deadline: 7.1, solution: [1: Device(equipment: .sorter), 3: Device(equipment: .booster)], challenge: "Deadline management"),
        Level(id: 5, title: "Close Timing", lesson: "The routes meet at inspection. Their different lengths can cause simultaneous arrivals. Adjust the timing before the merge.", stations: [
            node(0, 0.08, 0.5, 1),
            node(1, 0.27, 0.5, 2, side: 3, slot: true),
            node(2, 0.43, 0.22, 7, slot: true),
            node(3, 0.43, 0.78, 5, slot: true),
            node(4, 0.9, 0.22, dock: .amber),
            node(5, 0.7, 0.5, 6, side: 4, slot: true),
            node(6, 0.9, 0.78, dock: .teal),
            node(7, 0.6, 0.22, 5)
        ], shipments: queue([.amber, .teal, .amber, .teal, .amber, .teal], spacing: 1), inventory: [.diverter: 1, .sorter: 1, .booster: 1], deadline: 9.2, solution: [1: Device(equipment: .diverter), 2: Device(equipment: .booster), 5: Device(equipment: .sorter, filter: .amber)], challenge: "Merge synchronization"),
        Level(id: 6, title: "Final Dispatch", lesson: "Balance two feeder routes, synchronize their merge, then inspect three markings. Every unit has a job.", stations: [
            node(0, 0.08, 0.5, 1),
            node(1, 0.25, 0.5, 2, side: 3, slot: true),
            node(2, 0.42, 0.18, 6, slot: true),
            node(3, 0.42, 0.8, 7, slot: true),
            node(4, 0.91, 0.2, dock: .amber),
            node(5, 0.8, 0.5, 4, side: 9, slot: true),
            node(6, 0.62, 0.18, 7),
            node(7, 0.62, 0.5, 5, side: 8, slot: true),
            node(8, 0.62, 0.85, dock: .violet),
            node(9, 0.91, 0.8, dock: .teal)
        ], shipments: queue([.amber, .teal, .violet, .amber, .teal, .violet, .amber, .teal], spacing: 1), inventory: [.diverter: 1, .sorter: 2, .booster: 1], deadline: 12.2, solution: [1: Device(equipment: .diverter), 2: Device(equipment: .booster), 7: Device(equipment: .sorter, filter: .violet), 5: Device(equipment: .sorter)], challenge: "Full factory coordination")
    ]
}
