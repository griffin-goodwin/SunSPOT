import Foundation

// MARK: - Space Weather Event Types

/// Represents different types of space weather events from NASA DONKI API
enum SpaceWeatherEventType: String, CaseIterable, Identifiable {
    case cme = "CME"
    case geomagneticStorm = "GST"
    case solarFlare = "FLR"
    case solarEnergeticParticle = "SEP"
    case interplanetaryShock = "IPS"
    case radiationBeltEnhancement = "RBE"
    case highSpeedStream = "HSS"
    case activeRegion = "AR"
    case sunspot = "SS"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .cme: return "Coronal Mass Ejection"
        case .geomagneticStorm: return "Geomagnetic Storm"
        case .solarFlare: return "Solar Flare"
        case .solarEnergeticParticle: return "Solar Energetic Particle"
        case .interplanetaryShock: return "Interplanetary Shock"
        case .radiationBeltEnhancement: return "Radiation Belt Enhancement"
        case .highSpeedStream: return "High Speed Stream"
        case .activeRegion: return "Active Region"
        case .sunspot: return "Sunspot"
        }
    }
    
    var icon: String {
        switch self {
        case .cme: return "sun.max.fill"
        case .geomagneticStorm: return "globe.americas.fill"
        case .solarFlare: return "bolt.fill"
        case .solarEnergeticParticle: return "atom"
        case .interplanetaryShock: return "waveform.path.ecg"
        case .radiationBeltEnhancement: return "shield.fill"
        case .highSpeedStream: return "wind"
        case .activeRegion: return "sun.dust.fill"
        case .sunspot: return "smallcircle.filled.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .cme: return "orange"
        case .geomagneticStorm: return "purple"
        case .solarFlare: return "red"
        case .solarEnergeticParticle: return "yellow"
        case .interplanetaryShock: return "blue"
        case .radiationBeltEnhancement: return "green"
        case .highSpeedStream: return "cyan"
        case .activeRegion: return "orange"
        case .sunspot: return "gray"
        }
    }
}

// MARK: - Coronal Mass Ejection

struct CoronalMassEjection: Codable, Identifiable, Sendable {
    let activityID: String
    let catalog: String?
    let startTime: String
    let sourceLocation: String?
    let activeRegionNum: Int?
    let link: String?
    let note: String?
    let cmeAnalyses: [CMEAnalysis]?
    
    var id: String { activityID }
    
    var startDate: Date? {
        ISO8601DateFormatter().date(from: startTime.replacingOccurrences(of: "Z", with: "+00:00"))
    }
}

struct CMEAnalysis: Codable, Sendable {
    let time21_5: String?
    let latitude: Double?
    let longitude: Double?
    let halfAngle: Double?
    let speed: Double?
    let type: String?
    let isMostAccurate: Bool?
    let note: String?
    let levelOfData: Int?
    let link: String?
}

// MARK: - Geomagnetic Storm

struct GeomagneticStorm: Codable, Identifiable, Sendable {
    let gstID: String
    let startTime: String
    let allKpIndex: [KpIndex]?
    let link: String?
    
    var id: String { gstID }
    
    var startDate: Date? {
        ISO8601DateFormatter().date(from: startTime.replacingOccurrences(of: "Z", with: "+00:00"))
    }
    
    var maxKpIndex: Double? {
        allKpIndex?.compactMap { $0.kpIndex }.max()
    }
}

struct KpIndex: Codable, Sendable {
    let observedTime: String
    let kpIndex: Double
    let source: String?
}

// MARK: - Solar Flare

struct SolarFlare: Codable, Identifiable, Sendable {
    let flrID: String
    let instruments: [Instrument]?
    let beginTime: String
    let peakTime: String?
    let endTime: String?
    let classType: String?
    let sourceLocation: String?
    let activeRegionNum: Int?
    let link: String?
    
    var id: String { flrID }
    
    var beginDate: Date? {
        ISO8601DateFormatter().date(from: beginTime.replacingOccurrences(of: "Z", with: "+00:00"))
    }
    
    var flareClass: String {
        classType ?? "Unknown"
    }
}

struct Instrument: Codable, Sendable {
    let displayName: String?
}

// MARK: - Solar Energetic Particle

struct SolarEnergeticParticle: Codable, Identifiable, Sendable {
    let sepID: String
    let eventTime: String
    let instruments: [Instrument]?
    let link: String?
    
    var id: String { sepID }
    
    var eventDate: Date? {
        ISO8601DateFormatter().date(from: eventTime.replacingOccurrences(of: "Z", with: "+00:00"))
    }
}

// MARK: - Interplanetary Shock

struct InterplanetaryShock: Codable, Identifiable, Sendable {
    let catalog: String?
    let activityID: String
    let location: String?
    let eventTime: String
    let link: String?
    let instruments: [Instrument]?
    
    var id: String { activityID }
    
    var eventDate: Date? {
        ISO8601DateFormatter().date(from: eventTime.replacingOccurrences(of: "Z", with: "+00:00"))
    }
}

// MARK: - High Speed Stream

struct HighSpeedStream: Codable, Identifiable, Sendable {
    let hssID: String
    let eventTime: String
    let instruments: [Instrument]?
    let link: String?
    
    var id: String { hssID }
    
    var eventDate: Date? {
        ISO8601DateFormatter().date(from: eventTime.replacingOccurrences(of: "Z", with: "+00:00"))
    }
}

// MARK: - Unified Event Wrapper

struct SpaceWeatherEvent: Identifiable {
    let id: String
    let type: SpaceWeatherEventType
    let date: Date
    let title: String
    let details: String
    let severity: EventSeverity
    let link: String?
    // Coordinates for overlay (Helioprojective Cartesian)
    var hpcX: Double?
    var hpcY: Double?
    // Source tracking
    var source: EventSource = .hek
    // Raw intensity value (DN/s) for flares without class
    var peakIntensity: Double?
    
    enum EventSeverity: String {
        case weak = "Weak"         // < C class flares
        case moderate = "Moderate" // C class flares
        case high = "High"         // M class flares
        case extreme = "Extreme"   // X class flares
        case none = ""             // For non-flare events (CMEs, etc.)
        
        var color: String {
            switch self {
            case .weak: return "green"
            case .moderate: return "yellow"
            case .high: return "orange"
            case .extreme: return "red"
            case .none: return "gray"
            }
        }
    }
    
    enum EventSource: String, CaseIterable {
        case hek = "HEK"          // Heliophysics Events Knowledgebase
        case goes = "GOES"        // GOES X-ray flare data
        case swpc = "SWPC"        // NOAA Space Weather alerts
        case donki = "DONKI"      // NASA DONKI
        
        var displayName: String {
            switch self {
            case .hek: return "SSW Events"
            case .goes: return "GOES"
            case .swpc: return "SWPC"
            case .donki: return "DONKI"
            }
        }
        
        var color: String {
            switch self {
            case .hek: return "blue"
            case .goes: return "orange"
            case .swpc: return "red"
            case .donki: return "purple"
            }
        }
    }
    
    /// Formatted strength display - shows flare class or DN/s
    var strengthDisplay: String? {
        // Check if title contains flare class
        if let colonIndex = title.firstIndex(of: ":") {
            let afterColon = title[title.index(after: colonIndex)...].trimmingCharacters(in: .whitespaces)
            if !afterColon.isEmpty && afterColon.first?.isLetter == true {
                return afterColon
            }
        }
        // Fallback to intensity if available
        if let intensity = peakIntensity {
            return formatIntensity(intensity)
        }
        return nil
    }
    
    private func formatIntensity(_ value: Double) -> String {
        if value >= 1 {
            return String(format: "%.0f DN/s", value)
        }
        else if value >= 1e-8 {
            return String(format: "%.1e W/m²", value)
        } 
        return String(format: "%.2e", value)
    }
}
