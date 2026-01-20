import SwiftUI
import Charts

/// X-ray flux chart - shows data for the selected time range
/// Chart range matches the filter (6h, 1d, 3d, 7d) ending at "now"
struct XRayFluxChart: View {
    @Bindable var viewModel: SpaceWeatherViewModel
    let height: CGFloat
    @State private var showSXR_A: Bool = true
    @State private var showSXR_B: Bool = true
    
    // Reference date for chart end - actual "now"
    @State private var referenceDate: Date = Date()
    
    init(viewModel: SpaceWeatherViewModel, height: CGFloat = 120) {
        self.viewModel = viewModel
        self.height = height
    }
    
    // Chart shows from (now - timeRange) to now
    private var chartStartDate: Date {
        referenceDate.addingTimeInterval(-viewModel.overlayTimeRangeHours * 3600)
    }
    
    private var chartEndDate: Date {
        referenceDate  // Actual now
    }
    
    // Get the most recent flux reading
    private var currentFlux: XRayFluxDataPoint? {
        viewModel.xrayFluxData.last
    }
    
    // Format time range for display
    private var timeRangeLabel: String {
        let hours = viewModel.overlayTimeRangeHours
        if hours < 24 { return "\(Int(hours))h" }
        else if hours == 24 { return "1d" }
        else { return "\(Int(hours / 24))d" }
    }
    
    // Flare class thresholds (log10 values)
    private let flareClasses: [(name: String, logValue: Double, color: Color)] = [
        ("X", -4, .red),
        ("M", -5, .orange),
        ("C", -6, .yellow),
        ("B", -7, .green),
        ("A", -8, .blue)
    ]
    
    // Y-axis range - computed from visible data (log10) with padding and sensible clamps
    private var yAxisRange: ClosedRange<Double> {
        // If both channels are shown, present the full canonical range for context
        if showSXR_A && showSXR_B {
            return -8.5 ... -3.5
        }

        var values: [Double] = []
        if showSXR_A {
            for p in viewModel.chartFluxDataA {
                if let f = p.flux, f > 0 { values.append(log10(f)) }
            }
        }
        if showSXR_B {
            for p in viewModel.chartFluxData {
                if let f = p.flux, f > 0 { values.append(log10(f)) }
            }
        }

        // Fallback fixed range when no data
        if values.isEmpty {
            return -8.5 ... -3.5
        }

        var lower = values.min() ?? -8.5
        var upper = values.max() ?? -3.5

        // Ensure a minimum visual span
        if abs(upper - lower) < 0.2 {
            lower -= 0.25
            upper += 0.25
        }

        // Larger padding when only one series is visible so axis feels roomier
        let span = max(0.001, upper - lower)
        let pad = max(0.5, span * 0.35)
        lower -= pad
        upper += pad

        // Clamp to sensible physical bounds for SXR logs
        lower = max(lower, -10.0)
        upper = min(upper, -3.0)

        return lower...upper
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with current value
            HStack {
                HStack(spacing: 4) {
                    Text("X-Ray Flux")
                        .font(Theme.mono(12))
                        .foregroundStyle(.white.opacity(0.6))
                    Text(timeRangeLabel)
                        .font(Theme.mono(10))
                        .foregroundStyle(.white.opacity(0.4))
                }
                
                Spacer()
                
                if let flux = currentFlux {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(colorForClass(flux.estimatedClass))
                            .frame(width: 8, height: 8)
                        Text(flux.estimatedClass)
                            .font(Theme.mono(15, weight: .bold))
                            .foregroundStyle(colorForClass(flux.estimatedClass))
                        
                        if let fluxValue = flux.flux {
                            Text("(\(formatFlux(fluxValue)))")
                                .font(Theme.mono(11))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                }
            }
            
            // Chart - shows full time range
            if viewModel.isLoadingFlux {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        ProgressView()
                            .tint(.orange)
                        Text("Loading \(timeRangeLabel) data...")
                            .font(Theme.mono(12))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    Spacer()
                }
                .frame(height: height)
            } else if viewModel.xrayFluxData.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        ProgressView()
                            .tint(.orange)
                        Text("Loading flux data...")
                            .font(Theme.mono(12))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    Spacer()
                }
                .frame(height: height)
            } else {
                Chart {
                    // Flare class threshold lines with labels
                    ForEach(flareClasses, id: \.name) { flareClass in
                        RuleMark(y: .value("Class", flareClass.logValue))
                            .lineStyle(StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
                            .foregroundStyle(flareClass.color.opacity(0.4))
                    }
                    
                    // SXR-A flux line (shorter wavelength, more energetic) - lighter
                    if showSXR_A {
                        ForEach(viewModel.chartFluxDataA) { point in
                            if let date = point.date, let flux = point.flux, flux > 0 {
                                LineMark(
                                    x: .value("Time", date),
                                    y: .value("Flux", log10(flux)),
                                    series: .value("Channel", "SXR-A")
                                )
                                .foregroundStyle(.cyan)
                                .lineStyle(StrokeStyle(lineWidth: 1))
                            }
                        }
                    }

                    // SXR-B flux line (primary for classification) - prominent
                    if showSXR_B {
                        ForEach(viewModel.chartFluxData) { point in
                            if let date = point.date, let flux = point.flux, flux > 0 {
                                LineMark(
                                    x: .value("Time", date),
                                    y: .value("Flux", log10(flux)),
                                    series: .value("Channel", "SXR-B")
                                )
                                .foregroundStyle(.orange)
                                .lineStyle(StrokeStyle(lineWidth: 1.5))
                            }
                        }
                    }
                    
                    // // Current time indicator
                    // RuleMark(x: .value("Now", referenceDate))
                    //     .foregroundStyle(Theme.accentColor.opacity(0.8))
                    //     .lineStyle(StrokeStyle(lineWidth: 2))
                }
                .chartForegroundStyleScale([
                    "SXR-A": Color.cyan,
                    "SXR-B": Color.orange
                ])
                .chartYScale(domain: yAxisRange)
                .chartXScale(domain: chartStartDate...chartEndDate)
                .chartYAxis {
                    AxisMarks(position: .trailing, values: flareClasses.map { $0.logValue }) { value in
                        AxisGridLine().foregroundStyle(.white.opacity(0.1))
                        AxisValueLabel {
                            if let v = value.as(Double.self),
                               let flareClass = flareClasses.first(where: { $0.logValue == v }) {
                                Text(flareClass.name)
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundStyle(flareClass.color)
                            }
                        }
                    }
                }
                .chartXAxis {
                    // Adjust axis marks based on window size
                    let hours = viewModel.overlayTimeRangeHours
                    AxisMarks(values: .stride(by: hours <= 24 ? .hour : .day, count: hours <= 24 ? 6 : 1)) { _ in
                        AxisGridLine().foregroundStyle(.white.opacity(0.1))
                    }
                }
                .frame(height: height)
                .drawingGroup()
            }
            
                // Legend and time labels
            HStack {
                Text(formatTimeLabel(chartStartDate))
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.4))
                
                Spacer()
                
                // Legend with larger, tappable toggles (consistent size and contrast)
                HStack(spacing: 12) {
                    Button(action: { withAnimation { showSXR_A.toggle() } }) {
                        HStack(spacing: 10) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.cyan)
                                .frame(width: 28, height: 12)
                                .opacity(showSXR_A ? 1.0 : 0.3)

                            Text("0.5-4Å")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(width: 120, height: 38)
                        .background(showSXR_A ? Color.cyan.opacity(0.12) : Color.black.opacity(0.20))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(showSXR_A ? Color.cyan.opacity(0.9) : Color.clear, lineWidth: 1.5)
                        )
                        .contentShape(RoundedRectangle(cornerRadius: 10))
                        .accessibilityLabel("Toggle S X R A channel visibility")
                    }
                    .buttonStyle(.plain)

                    Button(action: { withAnimation { showSXR_B.toggle() } }) {
                        HStack(spacing: 10) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.orange)
                                .frame(width: 28, height: 12)
                                .opacity(showSXR_B ? 1.0 : 0.3)

                            Text("1-8Å")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(width: 120, height: 38)
                        .background(showSXR_B ? Color.orange.opacity(0.12) : Color.black.opacity(0.20))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(showSXR_B ? Color.orange.opacity(0.9) : Color.clear, lineWidth: 1.5)
                        )
                        .contentShape(RoundedRectangle(cornerRadius: 10))
                        .accessibilityLabel("Toggle S X R B channel visibility")
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
                
                Text(formatTimeLabel(chartEndDate))
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding()
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onChange(of: viewModel.xrayFluxData.count) { _, _ in
            // Update reference date when new data loads
            referenceDate = Date()
        }
        .onChange(of: viewModel.overlayTimeRangeHours) { _, _ in
            // Update reference date when time range changes
            referenceDate = Date()
        }
        .onChange(of: showSXR_A) { _, _ in
            // Force chart refresh when toggling visibility
            referenceDate = Date()
        }
        .onChange(of: showSXR_B) { _, _ in
            // Force chart refresh when toggling visibility
            referenceDate = Date()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            // Refresh the reference "now" when the app becomes active (reopened)
            referenceDate = Date()
        }
    }
    
    private func colorForClass(_ flareClass: String) -> Color {
        if flareClass.hasPrefix("X") { return .red }
        if flareClass.hasPrefix("M") { return .orange }
        if flareClass.hasPrefix("C") { return .yellow }
        if flareClass.hasPrefix("B") { return .green }
        return .blue
    }
    
    private func formatFlux(_ value: Double) -> String {
        String(format: "%.1e", value)
    }
    
    private func formatTimeLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")  // All SWPC data is in UTC
        let hours = viewModel.overlayTimeRangeHours
        
        // For smaller windows, show time; for larger windows, show date
        if hours <= 6 {
            formatter.dateFormat = "HH:mm"
        } else if hours <= 24 {
            formatter.dateFormat = "MMM d HH:mm"
        } else {
            formatter.dateFormat = "MMM d"
        }
        
        return formatter.string(from: date) + " UTC"
    }
}
