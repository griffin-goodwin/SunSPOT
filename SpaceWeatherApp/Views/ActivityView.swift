import SwiftUI

/// Combined Activity view showing conditions summary and event list
struct ActivityView: View {
    @Bindable var viewModel: SpaceWeatherViewModel
    @State private var showingFilters = false
    @State private var expandedSummary = true
    @State private var showFluxChart = true
    
    // Filter events by selected types
    private var filteredEvents: [SpaceWeatherEvent] {
        return viewModel.events.filter { event in
            viewModel.overlayEventTypes.contains(event.type)
        }.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Collapsible summary section
                    summarySection
                    
                    // X-Ray Flux Chart
                    if showFluxChart {
                        XRayFluxChart(viewModel: viewModel, height: 100)
                    }
                    
                    // Quick stats row
                    quickStatsRow
                    
                    // Events list
                    eventsSection
                }
                .padding()
            }
            .scrollContentBackground(.hidden)
            .background(Theme.backgroundGradient)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("ACTIVITY")
                        .font(Theme.mono(22, weight: .black))
                        .tracking(3)
                        .foregroundStyle(Theme.activityTitleGradient)
                        .shadow(color: Theme.accentSecondary.opacity(0.4), radius: 8, x: 0, y: 0)
                }
                ToolbarItem(placement: .automatic) {
                    Button {
                        withAnimation { showFluxChart.toggle() }
                    } label: {
                        Image(systemName: showFluxChart ? "chart.xyaxis.line" : "chart.line.downtrend.xyaxis")
                    }
                }
                
                ToolbarItem(placement: .automatic) {
                    Button {
                        showingFilters = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                            Text("\(viewModel.overlayEventTypes.count)")
                                .font(Theme.mono(12))
                        }
                    }
                }
                
                ToolbarItem(placement: .automatic) {
                    Button {
                        Task { await viewModel.refresh() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .sheet(isPresented: $showingFilters) {
                EventsFilterSheet(viewModel: viewModel)
            }
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                // Load probability forecast when view appears (if not already loaded)
                if !viewModel.flareProbabilityForecast.hasData {
                    await viewModel.loadFlareProbabilities()
                }
            }
            .onChange(of: viewModel.overlayTimeRangeHours) { _, _ in
                // Reload flux and events when time range changes
                Task {
                    await viewModel.loadXRayFlux()
                    await viewModel.loadEvents()
                    await viewModel.loadFlareProbabilities()
                }
            }
        }
    }
    
    // MARK: - Summary Section
    
    private var summarySection: some View {
        VStack(spacing: 12) {
            // Header with condition
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Space Weather Activity")
                        .font(Theme.mono(12))
                        .foregroundStyle(.white.opacity(0.6))
                    Text(overallConditionText)
                        .font(Theme.mono(20, weight: .bold))
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                // Condition indicator
                ZStack {
                    Circle()
                        .fill(overallConditionColor.opacity(0.2))
                        .frame(width: 50, height: 50)
                    Circle()
                        .fill(overallConditionColor)
                        .frame(width: 32, height: 32)
                    Image(systemName: overallConditionIcon)
                        .font(.subheadline)
                        .foregroundStyle(.white)
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.15))
            
            // Key metrics - Flare Probabilities (next 24h)
            HStack(spacing: 0) {
                MetricItem(
                    value: viewModel.flareProbabilityForecast.hasData ? "\(viewModel.flareProbabilityForecast.mClassProbability)%" : "—",
                    label: "M-Class (1d)",
                    color: mClassProbabilityColor
                )
                
                Divider()
                    .frame(height: 36)
                    .background(Color.white.opacity(0.15))
                
                MetricItem(
                    value: viewModel.flareProbabilityForecast.hasData ? "\(viewModel.flareProbabilityForecast.xClassProbability)%" : "—",
                    label: "X-Class (1d)",
                    color: xClassProbabilityColor
                )
                
                Divider()
                    .frame(height: 36)
                    .background(Color.white.opacity(0.15))
                
                MetricItem(
                    value: peakFlareClass,
                    label: "Peak Flare (\(formatTimeRange(viewModel.overlayTimeRangeHours)))",
                    color: peakFlareColor
                )
            }
        }
        .padding()
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Quick Stats Row
    
    private var quickStatsRow: some View {
        HStack(spacing: 12) {
            // Time window selector
            Menu {
                ForEach([6.0, 24.0, 72.0, 168.0], id: \.self) { hours in
                    Button {
                        viewModel.overlayTimeRangeHours = hours
                    } label: {
                        HStack {
                            Text(formatTimeRange(hours))
                            if viewModel.overlayTimeRangeHours == hours {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(Theme.mono(12))
                    Text(formatTimeRange(viewModel.overlayTimeRangeHours))
                        .font(Theme.mono(14, weight: .medium))
                    Image(systemName: "chevron.down")
                        .font(Theme.mono(10))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Theme.cardBackground)
                .clipShape(Capsule())
            }
            
            Spacer()
            
            // Event count
            Text("\(filteredEvents.count) events")
                .font(Theme.mono(14))
                .foregroundStyle(.white.opacity(0.7))
            
            // Flare class breakdown (only flares have severity labels)
            HStack(spacing: 4) {
                ForEach([
                    (sev: SpaceWeatherEvent.EventSeverity.extreme, label: "X"),
                    (sev: .high, label: "M"),
                    (sev: .moderate, label: "C"),
                    (sev: .weak, label: "<C")
                ], id: \.label) { item in
                    let count = filteredEvents.filter { $0.severity == item.sev }.count
                    if count > 0 {
                        HStack(spacing: 2) {
                            Circle()
                                .fill(colorForSeverity(item.sev))
                                .frame(width: 8, height: 8)
                            Text("\(count)\(item.label)")
                                .font(Theme.mono(10))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Events Section
    
    private var eventsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Events")
                .font(Theme.mono(16, weight: .bold))
                .foregroundStyle(.white)
            
            if viewModel.isLoading && filteredEvents.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                        .tint(.orange)
                    Spacer()
                }
                .padding(.vertical, 40)
            } else if filteredEvents.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "sun.max")
                        .font(.largeTitle)
                        .foregroundStyle(.white.opacity(0.3))
                    Text("No events in time window")
                        .font(Theme.mono(14))
                        .foregroundStyle(.white.opacity(0.5))
                    Button("Expand Time Range") {
                        viewModel.overlayTimeRangeHours = min(viewModel.overlayTimeRangeHours * 2, 168)
                    }
                    .font(Theme.mono(12))
                    .foregroundStyle(Theme.accentColor)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(filteredEvents) { event in
                        NavigationLink(destination: EventDetailView(event: event, viewModel: viewModel)) {
                            ActivityEventRow(event: event)
                        }
                        .buttonStyle(.plain)
                        
                        if event.id != filteredEvents.last?.id {
                            Divider()
                                .background(Color.white.opacity(0.1))
                        }
                    }
                }
                .padding()
                .background(Theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// Strongest flare severity in the filtered time window
    private var strongestFlareSeverity: SpaceWeatherEvent.EventSeverity {
        let flares = filteredEvents.filter { $0.type == .solarFlare }
        return flares.max(by: { compareFlareStrength($0, $1) })?.severity ?? .none
    }
    
    private var overallConditionText: String {
        switch strongestFlareSeverity {
        case .extreme: return "Extreme"
        case .high: return "High"
        case .moderate: return "Moderate"
        case .weak: return "Weak"
        case .none: return "Quiet"
        }
    }
    
    private var overallConditionColor: Color {
        switch strongestFlareSeverity {
        case .extreme: return .red
        case .high: return .orange
        case .moderate: return .yellow
        case .weak: return .green
        case .none: return .green
        }
    }
    
    private var overallConditionIcon: String {
        switch strongestFlareSeverity {
        case .extreme: return "bolt.fill"
        case .high: return "exclamationmark.triangle.fill"
        case .moderate: return "sun.max.fill"
        case .weak: return "sun.min.fill"
        case .none: return "checkmark"
        }
    }
    
    private var activeRegionCount: Int {
        viewModel.events.filter { $0.type == .activeRegion || $0.type == .sunspot }.count
    }
    
    private var highSeverityCount: Int {
        viewModel.events.filter { $0.severity == .high || $0.severity == .extreme }.count
    }
    
    private var mClassProbabilityColor: Color {
        let prob = viewModel.flareProbabilityForecast.mClassProbability
        if prob >= 60 { return .orange }
        if prob >= 30 { return .yellow }
        return .green
    }
    
    private var xClassProbabilityColor: Color {
        let prob = viewModel.flareProbabilityForecast.xClassProbability
        if prob >= 30 { return .red }
        if prob >= 15 { return .orange }
        if prob >= 5 { return .yellow }
        return .green
    }
    
    private var peakFlareClass: String {
        // Use filtered events (respects time range filter)
        let flares = filteredEvents.filter { $0.type == .solarFlare }
        if let strongest = flares.max(by: { compareFlareStrength($0, $1) }) {
            // Title format is "Flare: M1.5" or "Solar Flare: X2.0"
            if let colonIndex = strongest.title.firstIndex(of: ":") {
                let afterColon = strongest.title[strongest.title.index(after: colonIndex)...]
                return afterColon.trimmingCharacters(in: .whitespaces)
            }
            // Fallback: try to extract class letter + number
            let pattern = #"([ABCMX]\d+\.?\d*)"#
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: strongest.title, range: NSRange(strongest.title.startIndex..., in: strongest.title)),
               let range = Range(match.range(at: 1), in: strongest.title) {
                return String(strongest.title[range])
            }
            return strongest.severity.rawValue
        }
        return "—"
    }
    
    private var peakFlareColor: Color {
        // Use filtered events (respects time range filter)
        let flares = filteredEvents.filter { $0.type == .solarFlare }
        if let strongest = flares.max(by: { compareFlareStrength($0, $1) }) {
            switch strongest.severity {
            case .extreme: return .red
            case .high: return .orange
            case .moderate: return .yellow
            case .weak: return .green
            case .none: return .gray
            }
        }
        return .gray
    }
    
    private func compareFlareSeverity(_ a: SpaceWeatherEvent, _ b: SpaceWeatherEvent) -> Bool {
        let severityOrder: [SpaceWeatherEvent.EventSeverity] = [.none, .weak, .moderate, .high, .extreme]
        let aIndex = severityOrder.firstIndex(of: a.severity) ?? 0
        let bIndex = severityOrder.firstIndex(of: b.severity) ?? 0
        return aIndex < bIndex
    }
    
    /// Compare flare strength including the numeric magnitude (e.g., M5.2 > M1.5)
    private func compareFlareStrength(_ a: SpaceWeatherEvent, _ b: SpaceWeatherEvent) -> Bool {
        let aStrength = parseFlareStrength(a.title)
        let bStrength = parseFlareStrength(b.title)
        return aStrength < bStrength
    }
    
    /// Parse flare class into a comparable numeric value
    /// X1.0 = 1.0, M1.0 = 0.1, C1.0 = 0.01, B1.0 = 0.001, A1.0 = 0.0001
    private func parseFlareStrength(_ title: String) -> Double {
        let pattern = #"([ABCMX])(\d+\.?\d*)"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: title, range: NSRange(title.startIndex..., in: title)),
              let classRange = Range(match.range(at: 1), in: title),
              let numRange = Range(match.range(at: 2), in: title) else {
            return 0
        }
        
        let classLetter = String(title[classRange]).uppercased()
        let magnitude = Double(title[numRange]) ?? 1.0
        
        // Convert to a single scale where X1 = 1.0
        let classMultiplier: Double
        switch classLetter {
        case "X": classMultiplier = 1.0
        case "M": classMultiplier = 0.1
        case "C": classMultiplier = 0.01
        case "B": classMultiplier = 0.001
        case "A": classMultiplier = 0.0001
        default: classMultiplier = 0
        }
        
        return classMultiplier * magnitude
    }
    
    private func formatTimeRange(_ hours: Double) -> String {
        if hours < 24 { return "\(Int(hours))h" }
        else if hours == 24 { return "1d" }
        else { return "\(Int(hours / 24))d" }
    }
    
    private func colorForSeverity(_ severity: SpaceWeatherEvent.EventSeverity) -> Color {
        switch severity {
        case .weak: return .green
        case .moderate: return .yellow
        case .high: return .orange
        case .extreme: return .red
        case .none: return .gray
        }
    }
}

// MARK: - Metric Item

struct MetricItem: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(Theme.mono(18, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(Theme.mono(10))
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Activity Event Row

struct ActivityEventRow: View {
    let event: SpaceWeatherEvent
    
    var body: some View {
        HStack(spacing: 12) {
            // Event icon
            Image(systemName: event.type.icon)
                .font(.title3)
                .foregroundStyle(colorForType(event.type))
                .frame(width: 36, height: 36)
                .background(colorForType(event.type).opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(event.title)
                        .font(Theme.mono(14, weight: .medium))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    
                    // Show strength if available (for flares without class)
                    if event.type == .solarFlare, let strength = event.strengthDisplay {
                        if !event.title.contains(strength) {
                            Text(strength)
                                .font(Theme.mono(10))
                                .foregroundStyle(.orange)
                        }
                    }
                }
                
                HStack(spacing: 6) {
                    // Source badge
                    SourceBadge(source: event.source)
                    
                    Text(event.type.displayName)
                        .font(Theme.mono(10))
                        .foregroundStyle(.white.opacity(0.5))
                    
                    if event.hpcX != nil {
                        Circle()
                            .fill(.white.opacity(0.3))
                            .frame(width: 3, height: 3)
                        Image(systemName: "location.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 3) {
                SeverityBadge(severity: event.severity)
                Text(event.date.relativeTime)
                    .font(Theme.mono(10))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding(.vertical, 10)
    }
    
    private func colorForType(_ type: SpaceWeatherEventType) -> Color {
        switch type.color {
        case "orange": return .orange
        case "purple": return .purple
        case "red": return .red
        case "yellow": return .yellow
        case "blue": return .blue
        case "green": return .green
        case "cyan": return .cyan
        case "pink": return .pink
        default: return .gray
        }
    }
}

// MARK: - Source Badge

struct SourceBadge: View {
    let source: SpaceWeatherEvent.EventSource
    
    var body: some View {
        Text(source.displayName)
            .font(Theme.mono(8, weight: .semibold))
            .foregroundStyle(colorForSource)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(colorForSource.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 3))
    }
    
    private var colorForSource: Color {
        switch source {
        case .hek: return .blue
        case .goes: return .orange
        case .swpc: return .red
        case .donki: return .purple
        }
    }
}

// MARK: - Source Badge Large (for detail view)

struct SourceBadgeLarge: View {
    let source: SpaceWeatherEvent.EventSource
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(colorForSource)
                .frame(width: 8, height: 8)
            Text(source.displayName)
                .font(Theme.mono(12, weight: .medium))
                .foregroundStyle(colorForSource)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(colorForSource.opacity(0.15))
        .clipShape(Capsule())
    }
    
    private var colorForSource: Color {
        switch source {
        case .hek: return .blue
        case .goes: return .orange
        case .swpc: return .red
        case .donki: return .purple
        }
    }
}

#Preview {
    ActivityView(viewModel: SpaceWeatherViewModel())
}
