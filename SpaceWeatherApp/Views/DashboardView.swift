import SwiftUI

/// Dashboard view with space weather conditions and activity summary
struct DashboardView: View {
    @Bindable var viewModel: SpaceWeatherViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Current conditions header
                    currentConditionsCard
                    
                    // Activity summary for last 24h
                    activitySummarySection
                    
                    // Severity breakdown
                    severityBreakdownSection
                    
                    // Recent high-impact events
                    recentHighImpactSection
                    
                    // Activity by type
                    activityByTypeSection
                }
                .padding()
            }
            .scrollContentBackground(.hidden)
            .background(Theme.backgroundGradient)
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        Task { await viewModel.refresh() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
    }
    
    // MARK: - Current Conditions Card
    
    private var currentConditionsCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Space Weather")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                    Text(overallConditionText)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                // Condition indicator
                ZStack {
                    Circle()
                        .fill(overallConditionColor.opacity(0.2))
                        .frame(width: 60, height: 60)
                    Circle()
                        .fill(overallConditionColor)
                        .frame(width: 40, height: 40)
                    Image(systemName: overallConditionIcon)
                        .font(.title3)
                        .foregroundStyle(.white)
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            // Quick stats row
            HStack(spacing: 0) {
                ConditionStat(
                    label: "Active Regions",
                    value: "\(activeRegionCount)",
                    icon: "sun.dust.fill",
                    color: .orange
                )
                
                Divider()
                    .frame(height: 40)
                    .background(Color.white.opacity(0.2))
                
                ConditionStat(
                    label: "Flares (24h)",
                    value: "\(flaresLast24h)",
                    icon: "bolt.fill",
                    color: .yellow
                )
                
                Divider()
                    .frame(height: 40)
                    .background(Color.white.opacity(0.2))
                
                ConditionStat(
                    label: "CMEs (24h)",
                    value: "\(cmesLast24h)",
                    icon: "sun.max.fill",
                    color: .red
                )
            }
        }
        .padding()
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Activity Summary Section
    
    private var activitySummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("24-Hour Activity")
                .font(.headline)
                .foregroundStyle(.white)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ActivityCard(
                    title: "Total Events",
                    value: "\(eventsLast24h)",
                    subtitle: "in last 24 hours",
                    icon: "chart.bar.fill",
                    color: .blue
                )
                
                ActivityCard(
                    title: "High Severity",
                    value: "\(highSeverityLast24h)",
                    subtitle: highSeverityLast24h > 0 ? "requires attention" : "all clear",
                    icon: "exclamationmark.triangle.fill",
                    color: highSeverityLast24h > 0 ? .orange : .green
                )
                
                ActivityCard(
                    title: "Peak Flare",
                    value: peakFlareClass,
                    subtitle: peakFlareTime,
                    icon: "bolt.fill",
                    color: peakFlareColor
                )
                
                ActivityCard(
                    title: "Strongest CME",
                    value: strongestCMESpeed,
                    subtitle: "km/s",
                    icon: "arrow.up.right",
                    color: .red
                )
            }
        }
    }
    
    // MARK: - Severity Breakdown
    
    private var severityBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Severity Distribution")
                .font(.headline)
                .foregroundStyle(.white)
            
            HStack(spacing: 8) {
                ForEach([SpaceWeatherEvent.EventSeverity.weak, .moderate, .high, .extreme], id: \.rawValue) { severity in
                    SeverityPill(
                        severity: severity,
                        count: countForSeverity(severity),
                        total: viewModel.events.count
                    )
                }
            }
        }
    }
    
    // MARK: - Recent High Impact Events
    
    private var recentHighImpactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(.orange)
                Text("Recent High-Impact Events")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
            }
            
            let highImpactEvents = viewModel.events
                .filter { $0.severity == .high || $0.severity == .extreme }
                .sorted { $0.date > $1.date }
                .prefix(5)
            
            if highImpactEvents.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("No high-impact events recently")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(highImpactEvents)) { event in
                        HighImpactEventRow(event: event)
                        
                        if event.id != highImpactEvents.last?.id {
                            Divider()
                                .background(Color.white.opacity(0.1))
                        }
                    }
                }
                .padding()
                .background(Theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    // MARK: - Activity by Type
    
    private var activityByTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Events by Type")
                .font(.headline)
                .foregroundStyle(.white)
            
            VStack(spacing: 8) {
                ForEach(SpaceWeatherEventType.allCases.filter { viewModel.eventTypeCounts[$0] ?? 0 > 0 }) { type in
                    let count = viewModel.eventTypeCounts[type] ?? 0
                    let maxCount = viewModel.eventTypeCounts.values.max() ?? 1
                    
                    EventTypeBar(
                        type: type,
                        count: count,
                        maxCount: maxCount
                    )
                }
            }
            .padding()
            .background(Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Computed Properties
    
    private var overallConditionText: String {
        if highSeverityLast24h >= 3 { return "Stormy" }
        if highSeverityLast24h >= 1 { return "Active" }
        if eventsLast24h >= 10 { return "Elevated" }
        return "Quiet"
    }
    
    private var overallConditionColor: Color {
        if highSeverityLast24h >= 3 { return .red }
        if highSeverityLast24h >= 1 { return .orange }
        if eventsLast24h >= 10 { return .yellow }
        return .green
    }
    
    private var overallConditionIcon: String {
        if highSeverityLast24h >= 3 { return "bolt.fill" }
        if highSeverityLast24h >= 1 { return "exclamationmark.triangle.fill" }
        if eventsLast24h >= 10 { return "sun.max.fill" }
        return "checkmark"
    }
    
    private var activeRegionCount: Int {
        viewModel.events.filter { $0.type == .activeRegion || $0.type == .sunspot }.count
    }
    
    private var eventsLast24h: Int {
        let cutoff = Date().addingTimeInterval(-24 * 60 * 60)
        return viewModel.events.filter { $0.date > cutoff }.count
    }
    
    private var flaresLast24h: Int {
        let cutoff = Date().addingTimeInterval(-24 * 60 * 60)
        return viewModel.events.filter { $0.type == .solarFlare && $0.date > cutoff }.count
    }
    
    private var cmesLast24h: Int {
        let cutoff = Date().addingTimeInterval(-24 * 60 * 60)
        return viewModel.events.filter { $0.type == .cme && $0.date > cutoff }.count
    }
    
    private var highSeverityLast24h: Int {
        let cutoff = Date().addingTimeInterval(-24 * 60 * 60)
        return viewModel.events.filter { 
            ($0.severity == .high || $0.severity == .extreme) && $0.date > cutoff 
        }.count
    }
    
    private var peakFlareClass: String {
        let flares = viewModel.events.filter { $0.type == .solarFlare }
        if let strongest = flares.max(by: { compareFlareSeverity($0, $1) }) {
            // Extract flare class from title (e.g., "M1.5 Flare")
            let parts = strongest.title.components(separatedBy: " ")
            return parts.first ?? "None"
        }
        return "None"
    }
    
    private var peakFlareTime: String {
        let flares = viewModel.events.filter { $0.type == .solarFlare }
        if let strongest = flares.max(by: { compareFlareSeverity($0, $1) }) {
            return strongest.date.relativeTime
        }
        return "N/A"
    }
    
    private var peakFlareColor: Color {
        let flares = viewModel.events.filter { $0.type == .solarFlare }
        if let strongest = flares.max(by: { compareFlareSeverity($0, $1) }) {
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
    
    private var strongestCMESpeed: String {
        // Try to extract speed from CME event details
        let cmes = viewModel.events.filter { $0.type == .cme }
        if let cme = cmes.first {
            // Try to parse speed from details
            if cme.details.contains("km/s") {
                let pattern = #"(\d+)\s*km/s"#
                if let regex = try? NSRegularExpression(pattern: pattern),
                   let match = regex.firstMatch(in: cme.details, range: NSRange(cme.details.startIndex..., in: cme.details)),
                   let range = Range(match.range(at: 1), in: cme.details) {
                    return String(cme.details[range])
                }
            }
        }
        return "—"
    }
    
    private func compareFlareSeverity(_ a: SpaceWeatherEvent, _ b: SpaceWeatherEvent) -> Bool {
        let severityOrder: [SpaceWeatherEvent.EventSeverity] = [.none, .weak, .moderate, .high, .extreme]
        let aIndex = severityOrder.firstIndex(of: a.severity) ?? 0
        let bIndex = severityOrder.firstIndex(of: b.severity) ?? 0
        return aIndex < bIndex
    }
    
    private func countForSeverity(_ severity: SpaceWeatherEvent.EventSeverity) -> Int {
        viewModel.events.filter { $0.severity == severity }.count
    }
}

// MARK: - Condition Stat

struct ConditionStat: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Activity Card

struct ActivityCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.white)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding()
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Severity Pill

struct SeverityPill: View {
    let severity: SpaceWeatherEvent.EventSeverity
    let count: Int
    let total: Int
    
    var body: some View {
        VStack(spacing: 6) {
            Text("\(count)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(severityColor)
            
            Text(severity.rawValue)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.7))
            
            // Mini progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                    Capsule()
                        .fill(severityColor)
                        .frame(width: total > 0 ? geo.size.width * CGFloat(count) / CGFloat(total) : 0)
                }
            }
            .frame(height: 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(severityColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private var severityColor: Color {
        switch severity {
        case .weak: return .green
        case .moderate: return .yellow
        case .high: return .orange
        case .extreme: return .red
        case .none: return .gray
        }
    }
}

// MARK: - High Impact Event Row

struct HighImpactEventRow: View {
    let event: SpaceWeatherEvent
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: event.type.icon)
                .font(.title3)
                .foregroundStyle(colorForType(event.type))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(event.type.displayName)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.5))
                    Text("•")
                        .foregroundStyle(.white.opacity(0.3))
                    Text(event.date.relativeTime)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            
            Spacer()
            
            SeverityBadge(severity: event.severity)
        }
        .padding(.vertical, 8)
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

// MARK: - Event Type Bar

struct EventTypeBar: View {
    let type: SpaceWeatherEventType
    let count: Int
    let maxCount: Int
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.icon)
                .foregroundStyle(colorForType)
                .frame(width: 24)
            
            Text(type.displayName)
                .font(.subheadline)
                .foregroundStyle(.white)
                .frame(width: 140, alignment: .leading)
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                    Capsule()
                        .fill(colorForType)
                        .frame(width: maxCount > 0 ? geo.size.width * CGFloat(count) / CGFloat(maxCount) : 0)
                }
            }
            .frame(height: 8)
            
            Text("\(count)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .frame(width: 30, alignment: .trailing)
        }
    }
    
    private var colorForType: Color {
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
