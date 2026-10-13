import SwiftUI
import Combine

private enum Palette {
    static let navy = Color(red: 0.035, green: 0.07, blue: 0.14)
    static let text = Color(red: 0.96, green: 0.98, blue: 1)
    static let secondaryText = Color(red: 0.76, green: 0.82, blue: 0.90)
    static let panel = Color(red: 0.075, green: 0.13, blue: 0.22)
    static let orange = Color(red: 1, green: 0.61, blue: 0.24)
    static let teal = Color(red: 0.2, green: 0.86, blue: 0.79)
}
private extension ParcelKind { var color: Color { switch self { case .amber: return Palette.orange; case .teal: return Palette.teal; case .violet: return Color(red: 0.78, green: 0.65, blue: 1) } } }
private struct FactoryBackdrop: ViewModifier {
    func body(content: Content) -> some View { content.frame(maxWidth: .infinity, maxHeight: .infinity).background(Palette.navy).foregroundStyle(Palette.text).preferredColorScheme(.dark).tint(Palette.teal).toolbarColorScheme(.dark, for: .navigationBar, .bottomBar).toolbarBackground(Palette.navy, for: .navigationBar, .bottomBar).toolbarBackground(.visible, for: .navigationBar, .bottomBar) }
}
private extension View {
    func factoryStyle() -> some View { modifier(FactoryBackdrop()) }
    func card() -> some View { padding(18).background(Palette.panel, in: RoundedRectangle(cornerRadius: 22)) }
}
private struct ActionButton: View {
    let title: String
    let symbol: String
    var action: () -> Void
    var body: some View { Button(action: action) { Label(title, systemImage: symbol).font(.headline).frame(maxWidth: .infinity).padding(.vertical, 15) }.buttonStyle(.borderedProminent).tint(Palette.teal).foregroundStyle(Palette.navy) }
}
struct FactoryRootView: View {
    @StateObject private var model = FactoryViewModel()
    @Environment(\.scenePhase) private var phase
    var body: some View {
        NavigationStack { HomeView(model: model) }
            .preferredColorScheme(.dark)
            .onChange(of: phase) { value in if value != .active { model.pause() } }
    }
}
struct HomeView: View {
    @ObservedObject var model: FactoryViewModel
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack { Label("FACTORY / 01", systemImage: "shippingbox.fill").font(.caption.bold()).tracking(2); Spacer() }
                VStack(alignment: .leading, spacing: 8) { Text("Parcel\nPanic").font(.system(.largeTitle, design: .rounded, weight: .black)); Text("Small parcels. Clever routes.").foregroundStyle(Palette.secondaryText) }
                FactoryIllustration().frame(height: 180).card()
                HStack { VStack(alignment: .leading) { Text("YOUR SHIFT").font(.caption).foregroundStyle(Palette.secondaryText); Text("\(model.saved.completed.count) / 6 completed").font(.title2.bold()) }; Spacer(); Image(systemName: "checkmark.seal.fill").font(.largeTitle).foregroundStyle(Palette.orange) }.card()
                NavigationLink { LevelsView(model: model) } label: { Label("Enter the Factory", systemImage: "arrow.right").font(.headline).frame(maxWidth: .infinity).padding(18).background(Palette.teal, in: RoundedRectangle(cornerRadius: 16)).foregroundStyle(Palette.navy) }
                HStack(spacing: 16) { NavigationLink { GuideView() } label: { Label("Equipment", systemImage: "wrench.and.screwdriver").frame(maxWidth: .infinity).card() }; NavigationLink { SettingsView(model: model) } label: { Label("Settings", systemImage: "slider.horizontal.3").frame(maxWidth: .infinity).card() } }.font(.subheadline.bold())
                Text("Plan the route. Start the line. Deliver every parcel.").font(.footnote).foregroundStyle(Palette.secondaryText)
            }.padding(24).frame(maxWidth: 760)
        }.factoryStyle().navigationTitle("").toolbar { ToolbarItem(placement: .principal) { Text("DISPATCH CONTROL").font(.caption.bold()).tracking(2) } }
    }
}
private struct FactoryIllustration: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Path { path in path.move(to: CGPoint(x: 0, y: geometry.size.height * 0.6)); path.addLine(to: CGPoint(x: geometry.size.width * 0.45, y: geometry.size.height * 0.6)); path.addLine(to: CGPoint(x: geometry.size.width * 0.75, y: geometry.size.height * 0.25)); path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height * 0.25)) }.stroke(Color.white.opacity(0.16), style: StrokeStyle(lineWidth: 25, lineCap: .round, lineJoin: .round))
                ForEach(0..<3) { index in Image(systemName: index == 1 ? "diamond.fill" : "shippingbox.fill").font(.system(size: 35)).foregroundStyle(index == 1 ? Palette.teal : Palette.orange).position(x: geometry.size.width * (0.16 + Double(index) * 0.3), y: geometry.size.height * (index == 2 ? 0.25 : 0.6)) }
                Text("BUILD A BETTER FLOW").font(.caption.bold()).tracking(2).frame(maxHeight: .infinity, alignment: .bottom)
            }
        }.accessibilityLabel("Parcels moving through a branching conveyor")
    }
}
struct LevelsView: View {
    @ObservedObject var model: FactoryViewModel
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Six shifts. One perfect flow.").font(.title2.bold())
                Text("Each shift introduces a new routing challenge.").foregroundStyle(Palette.secondaryText)
                ForEach(Campaign.levels) { level in
                    NavigationLink { WorkshopView(model: model, level: level) } label: {
                        HStack(spacing: 16) { Text(String(format: "%02d", level.id)).font(.title.bold()).foregroundStyle(Palette.orange); VStack(alignment: .leading, spacing: 5) { Text(level.title).font(.headline).foregroundStyle(Palette.text).fixedSize(horizontal: false, vertical: true); Text("\(level.shipments.count) parcels · \(Int(level.deadline))s deadline").font(.subheadline).fixedSize(horizontal: false, vertical: true).foregroundStyle(Palette.secondaryText); Text(level.challenge).font(.caption.bold()).foregroundStyle(Palette.teal).fixedSize(horizontal: false, vertical: true) }; Spacer(); Image(systemName: model.saved.completed.contains(level.id) ? "checkmark.circle.fill" : model.unlocked(level) ? "arrow.up.right" : "lock.fill").foregroundStyle(Palette.teal) }.card()
                    }.buttonStyle(.plain).disabled(!model.unlocked(level)).accessibilityHint(model.unlocked(level) ? "Open this shift" : "Complete the previous shift to unlock")
                }
            }.padding(24).frame(maxWidth: 760)
        }.factoryStyle().navigationTitle("Choose a Shift")
    }
}
struct WorkshopView: View {
    @ObservedObject var model: FactoryViewModel
    let entryLevel: Level
    private var level: Level { model.level }
    init(model: FactoryViewModel, level: Level) { self.model = model; self.entryLevel = level }
    @Environment(\.horizontalSizeClass) private var widthClass
    @State private var showingGuide = false
    private let ticker = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack { Text("SHIFT \(level.id)").font(.caption.bold()).foregroundStyle(Palette.orange); Spacer(); Text(model.editing ? "PLANNING" : model.running ? "IN MOTION" : "PAUSED").font(.caption.bold()).foregroundStyle(Palette.teal) }
                Text(level.lesson).font(.subheadline).foregroundStyle(Palette.secondaryText)
                if widthClass == .regular {
                    HStack(alignment: .top, spacing: 20) { board; equipmentPanel.frame(idealWidth: 280, maxWidth: 330) }
                } else { board; equipmentPanel }
                HStack { Label("\(model.engine?.delivered ?? 0) / \(level.shipments.count)", systemImage: "shippingbox"); Spacer(); Label(String(format: "%.1f / %.0f s", model.engine?.elapsed ?? 0, level.deadline), systemImage: "clock") }.font(.subheadline.monospacedDigit()).card()
            }.padding(20)
        }.factoryStyle().navigationTitle(level.title).navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { Button { showingGuide = true } label: { Image(systemName: "questionmark.circle").frame(minWidth: 44, minHeight: 44) }.accessibilityLabel("Equipment guide") }
                ToolbarItemGroup(placement: .bottomBar) {
                    if model.editing { Button { model.start() } label: { Label("Run", systemImage: "play.fill") }; Spacer(); Button("Clear") { model.clear() } }
                    else { Button { model.running.toggle() } label: { Label(model.running ? "Pause" : "Resume", systemImage: model.running ? "pause.fill" : "play.fill") }.disabled(model.result != nil); Spacer(); Button("Stop") { model.edit() } }
                }
            }
            .onAppear { if model.level.id != entryLevel.id || model.engine == nil { model.open(entryLevel) } }
            .onDisappear { model.pause() }
            .onReceive(ticker) { _ in model.tick() }
            .sheet(isPresented: $showingGuide) { NavigationStack { GuideView().toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showingGuide = false } } } } }
            .sheet(item: $model.result) { outcome in ResultsView(model: model, outcome: outcome).interactiveDismissDisabled() }
    }
    private var board: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CONVEYOR PLAN").font(.caption.bold()).tracking(1)
            ConveyorView(model: model).frame(minHeight: level.stations.count > 8 ? 360 : 280, idealHeight: level.stations.count > 8 ? 400 : 320).background(Palette.panel, in: RoundedRectangle(cornerRadius: 22))
            HStack(spacing: 12) {
                Label("Main", systemImage: "arrow.right").foregroundStyle(Palette.teal)
                Label("Side", systemImage: "arrow.turn.up.right").foregroundStyle(Palette.orange)
            }.font(.caption.bold())
            Text("DISPATCH QUEUE").font(.caption.bold())
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(Array(level.shipments.enumerated()), id: \.offset) { pair in
                        VStack(spacing: 6) {
                            Image(systemName: pair.element.kind.symbol).font(.title3).foregroundStyle(pair.element.kind.color)
                            Text(String(format: "%.1fs", pair.element.release)).font(.caption.monospacedDigit()).foregroundStyle(Palette.secondaryText)
                        }.padding(10).background(Palette.panel, in: RoundedRectangle(cornerRadius: 12)).accessibilityElement(children: .ignore).accessibilityLabel("\(pair.element.kind.title), dispatched at \(String(format: "%.1f", pair.element.release)) seconds")
                    }
                }
            }
        }
    }
    private var equipmentPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("EQUIPMENT").font(.caption.bold()).tracking(1)
            ForEach(model.available, id: \.self) { equipment in
                Button { model.selected = equipment; model.selectedStation = nil; model.feedback() } label: {
                    HStack { Image(systemName: equipment.symbol).frame(width: 30); Text(equipment.title).foregroundStyle(Palette.text); Spacer(); Text("\(model.remaining(equipment)) left").font(.subheadline.bold()).foregroundStyle(Palette.secondaryText) }.padding(14).background(model.selected == equipment ? Palette.teal.opacity(0.2) : Palette.panel, in: RoundedRectangle(cornerRadius: 14)).overlay(RoundedRectangle(cornerRadius: 14).stroke(model.selected == equipment ? Palette.teal : .clear))
                }.buttonStyle(.plain).disabled(!model.editing).accessibilityLabel("\(equipment.title), \(model.remaining(equipment)) available")
            }
            if let id = model.selectedStation, let device = model.layout[id], model.editing {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Socket \(id) · \(device.equipment.title)").font(.headline)
                    if device.equipment == .diverter { Toggle("Side route first", isOn: Binding(get: { device.sideFirst }, set: { value in var updated = device; updated.sideFirst = value; model.configure(updated) })) }
                    if device.equipment == .sorter { Picker("Send to side route", selection: Binding(get: { device.filter }, set: { value in var updated = device; updated.filter = value; model.configure(updated) })) { ForEach(ParcelKind.allCases, id: \.self) { kind in Text(kind.title).tag(kind) } }.pickerStyle(.segmented); Text("Selected marking takes the side branch.").font(.footnote).fixedSize(horizontal: false, vertical: true).foregroundStyle(Palette.secondaryText) }
                    Button("Remove Equipment", role: .destructive) { model.remove() }.frame(minHeight: 44)
                }.card()
            }
            Text(model.notice).font(.footnote).fixedSize(horizontal: false, vertical: true).foregroundStyle(Palette.secondaryText)
        }
    }
}
private struct ConveyorView: View {
    @ObservedObject var model: FactoryViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        GeometryReader { geometry in
            let point: (Point) -> CGPoint = { value in CGPoint(x: value.x * geometry.size.width, y: 32 + value.y * (geometry.size.height - 64)) }
            ZStack {
                ForEach(model.level.stations) { station in
                    ForEach([station.next, station.side].compactMap { $0 }, id: \.self) { target in
                        let start = point(station.point)
                        let end = point(model.level.stations[target].point)
                        Path { path in path.move(to: start); path.addLine(to: end) }.stroke(Color.white.opacity(0.12), style: StrokeStyle(lineWidth: 18, lineCap: .round))
                        Path { path in path.move(to: start); path.addLine(to: end) }.stroke(target == station.side ? Palette.orange.opacity(0.7) : Palette.teal.opacity(0.6), style: StrokeStyle(lineWidth: 2, dash: target == station.side ? [4, 7] : []))
                        Image(systemName: "chevron.right").font(.caption2.bold()).foregroundStyle(.white.opacity(0.5)).rotationEffect(.radians(atan2(end.y - start.y, end.x - start.x))).position(x: (start.x + end.x) / 2, y: (start.y + end.y) / 2)
                    }
                }
                ForEach(model.level.stations) { station in
                    Group {
                        if let recipient = station.recipient {
                            VStack(spacing: 3) { Image(systemName: recipient.symbol).font(.title3); Text(recipient.title).font(.caption2.bold()) }.foregroundStyle(recipient.color).padding(8).background(Palette.navy, in: RoundedRectangle(cornerRadius: 12)).accessibilityLabel("\(recipient.title) delivery dock")
                        } else if station.slot {
                            Button { model.place(station) } label: { Image(systemName: model.layout[station.id]?.equipment.symbol ?? "plus").font(.headline).frame(width: 44, height: 44).background(model.selectedStation == station.id ? Palette.teal : Palette.navy, in: RoundedRectangle(cornerRadius: 12)).foregroundStyle(model.selectedStation == station.id ? Palette.navy : .white).overlay(RoundedRectangle(cornerRadius: 12).stroke(model.faultStation == station.id ? .red : Palette.teal, style: StrokeStyle(lineWidth: 2, dash: model.layout[station.id] == nil ? [3, 3] : []))) }.disabled(!model.editing).accessibilityLabel("Socket \(station.id), \(model.layout[station.id]?.equipment.title ?? "empty")")
                        } else { Image(systemName: station.id == 0 ? "shippingbox.fill" : "arrow.right").foregroundStyle(Palette.orange).frame(width: 32, height: 32).background(Palette.navy, in: RoundedRectangle(cornerRadius: 8)) }
                    }.overlay(RoundedRectangle(cornerRadius: 12).stroke(model.faultStation == station.id ? Color.red : Color.clear, lineWidth: 3)).position(point(station.point))
                }
                ForEach(model.engine?.freight ?? []) { item in
                    if let target = item.target {
                        let start = point(model.level.stations[item.station].point)
                        let end = point(model.level.stations[target].point)
                        let progress = reduceMotion ? 0.0 : min(item.progress, 1)
                        Image(systemName: item.kind.symbol).font(.title3).foregroundStyle(item.kind.color).padding(5).background(Palette.navy, in: RoundedRectangle(cornerRadius: 6)).position(x: start.x + (end.x - start.x) * progress, y: start.y + (end.y - start.y) * progress).accessibilityLabel("\(item.kind.title) parcel in transit")
                    }
                }
            }
        }
    }
}
struct ResultsView: View {
    @ObservedObject var model: FactoryViewModel
    let outcome: Outcome
    var body: some View {
        NavigationStack {
            ScrollView { VStack(spacing: 24) {
                Image(systemName: outcome.success ? "checkmark.seal.fill" : "exclamationmark.triangle.fill").font(.system(size: 72)).foregroundStyle(outcome.success ? Palette.teal : Palette.orange)
                Text(outcome.success ? "Perfect Delivery" : "Route Needs Work").font(.largeTitle.bold()).multilineTextAlignment(.center)
                Text(outcome.message).foregroundStyle(Palette.secondaryText).multilineTextAlignment(.center)
                HStack { VStack { Text("\(outcome.delivered)").font(.largeTitle.bold()); Text("Delivered") }; Spacer(); VStack { Text(String(format: "%.1fs", outcome.elapsed)).font(.largeTitle.bold()); Text("Elapsed") } }.card()
                ActionButton(title: outcome.success ? "Replay Shift" : "Edit Layout", symbol: "wrench.fill") { model.edit() }
                if outcome.success && model.level.id < 6 { ActionButton(title: "Next Shift", symbol: "arrow.right") { model.open(Campaign.levels[model.level.id]) } }
                if outcome.success && model.level.id == 6 { Text("All six shifts complete. Your factory is ready.").foregroundStyle(Palette.teal) }
            }.padding(28) }.factoryStyle().navigationTitle("Shift Report").navigationBarTitleDisplayMode(.inline)
        }
    }
}
struct GuideView: View {
    var body: some View {
        ScrollView { VStack(alignment: .leading, spacing: 20) {
            Text("Build. Test. Refine.").font(.largeTitle.bold())
            Text("Choose an available unit, then tap an empty socket. Tap an installed unit to adjust it or return it to your inventory.").foregroundStyle(Palette.secondaryText)
            ForEach(Equipment.allCases, id: \.self) { equipment in VStack(alignment: .leading, spacing: 12) { Label(equipment.title, systemImage: equipment.symbol).font(.title2.bold()).foregroundStyle(Palette.teal); Text(description(equipment)).foregroundStyle(Palette.secondaryText) }.frame(maxWidth: .infinity, alignment: .leading).card() }
            VStack(alignment: .leading, spacing: 12) { Text("Delivery Rules").font(.title2.bold()); Text("Match each parcel to its dock by color and symbol: Amber cubes, Teal diamonds, and Violet seals. Queue times show when each parcel enters the line. Simultaneous arrivals at a junction cause a collision. Finish before the deadline. You can pause a run, but changes require stopping the line.").foregroundStyle(Palette.secondaryText) }.card()
        }.padding(24).frame(maxWidth: 760) }.factoryStyle().navigationTitle("Equipment Guide")
    }
    private func description(_ equipment: Equipment) -> String { switch equipment { case .diverter: return "Alternates between the straight and side routes for each arriving parcel. Choose which route receives the first parcel."; case .sorter: return "Parcels with the selected marking take the side branch. All other parcels continue on the main route. Solid teal tracks show the main branch; dashed orange tracks show the side branch."; case .booster: return "Halves the travel time of the next conveyor segment. Use it to meet tight deadlines and separate arrivals at shared junctions." } }
}
struct SettingsView: View {
    @ObservedObject var model: FactoryViewModel
    @State private var confirmingReset = false
    var body: some View {
        Form {
            Section("Controls") { Toggle("Haptic Feedback", isOn: Binding(get: { model.saved.haptics }, set: { model.toggleHaptics($0) })) }
            Section("Progress") { LabeledContent("Completed Shifts", value: "\(model.saved.completed.count) / 6"); Button("Reset Progress", role: .destructive) { confirmingReset = true } }
            Section("About") { Text("Parcel Panic").font(.headline); Text("An offline routing puzzle. Plan carefully, test your equipment, and deliver every parcel.").foregroundStyle(Palette.secondaryText); Text("Version 1.0").font(.caption) }
        }.scrollContentBackground(.hidden).factoryStyle().navigationTitle("Settings").alert("Reset Progress?", isPresented: $confirmingReset) { Button("Cancel", role: .cancel) {}; Button("Reset", role: .destructive) { model.reset() } } message: { Text("Completed shifts and saved layouts will be cleared.") }
    }
}
