import Foundation
import CoreLocation

/// Aurora forecast data from NOAA OVATION model
struct AuroraForecast: Codable {
    let observationTime: String
    let forecastTime: String
    let dataFormat: String
    let coordinates: [[Double]] // [longitude, latitude, probability]
    
    enum CodingKeys: String, CodingKey {
        case observationTime = "Observation Time"
        case forecastTime = "Forecast Time"
        case dataFormat = "Data Format"
        case coordinates
    }
}

/// Individual aurora data point with probability
struct AuroraPoint: Identifiable, Equatable {
    let id = UUID()
    let longitude: Double
    let latitude: Double
    let probability: Double // 0-100
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    /// Color based on aurora probability
    var color: AuroraIntensity {
        switch probability {
        case 0..<10: return .none
        case 10..<30: return .low
        case 30..<50: return .moderate
        case 50..<70: return .high
        case 70...: return .extreme
        default: return .none
        }
    }

    /// Probability bin 0..9 for 10-point bins (0-10,10-20,...,90-100)
    var probabilityBin: Int {
        let b = Int(floor(probability / 10.0))
        return min(max(b, 0), 9)
    }
    
    // Equatable conformance - compare by data values, not UUID
    static func == (lhs: AuroraPoint, rhs: AuroraPoint) -> Bool {
        lhs.longitude == rhs.longitude &&
        lhs.latitude == rhs.latitude &&
        lhs.probability == rhs.probability
    }
}

/// Aurora intensity levels for visualization
enum AuroraIntensity: String, CaseIterable {
    case none = "None"
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
    case extreme = "Extreme"
    
    var description: String {
        switch self {
        case .none: return "No visible aurora"
        case .low: return "Faint aurora possible"
        case .moderate: return "Aurora visible"
        case .high: return "Bright aurora likely"
        case .extreme: return "Intense aurora storm"
        }
    }
}

/// Kp Index data point
struct KpIndexPoint: Codable, Identifiable {
    let id = UUID()
    let timeTag: String
    let kpIndex: Double
    let estimated: String?
    
    enum CodingKeys: String, CodingKey {
        case timeTag = "time_tag"
        case kpIndex = "kp_index"
        case estimated
    }
    
    /// Kp level description
    var level: KpLevel {
        switch kpIndex {
        case 0..<4: return .quiet
        case 4..<5: return .unsettled
        case 5..<6: return .minorStorm
        case 6..<7: return .moderateStorm
        case 7..<8: return .strongStorm
        case 8..<9: return .severeStorm
        case 9...: return .extremeStorm
        default: return .quiet
        }
    }

    /// Parsed Date from `timeTag` (tries common NOAA formats). Interpreted as UTC.
    var date: Date? {
        let iso = ISO8601DateFormatter()
        if let d = iso.date(from: timeTag) { return d }

        let df = DateFormatter()
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let d = df.date(from: timeTag) { return d }

        // Try without seconds
        df.dateFormat = "yyyy-MM-dd HH:mm"
        return df.date(from: timeTag)
    }
}

/// Kp index level classifications
enum KpLevel: String, CaseIterable {
    case quiet = "Quiet"
    case unsettled = "Unsettled"
    case minorStorm = "G1 Minor Storm"
    case moderateStorm = "G2 Moderate Storm"
    case strongStorm = "G3 Strong Storm"
    case severeStorm = "G4 Severe Storm"
    case extremeStorm = "G5 Extreme Storm"
    
    /// Southernmost latitude where aurora might be visible (approximate)
    var visibilityLatitude: Double {
        switch self {
        case .quiet: return 66
        case .unsettled: return 62
        case .minorStorm: return 58
        case .moderateStorm: return 52
        case .strongStorm: return 48
        case .severeStorm: return 44
        case .extremeStorm: return 40
        }
    }
    
    /// Description of aurora visibility
    var visibilityDescription: String {
        switch self {
        case .quiet: return "Aurora visible in polar regions"
        case .unsettled: return "Aurora visible in northern Alaska, Canada"
        case .minorStorm: return "Aurora visible in Alaska, northern Canada, Scandinavia"
        case .moderateStorm: return "Aurora visible in northern US states, Scotland"
        case .strongStorm: return "Aurora visible as far south as Oregon, Illinois, England"
        case .severeStorm: return "Aurora visible in California, Texas, Mediterranean"
        case .extremeStorm: return "Aurora visible from most of the world"
        }
    }
}

/// Hemisphere selection
enum Hemisphere: String, CaseIterable, Identifiable {
    case north = "Northern"
    case south = "Southern"
    
    var id: String { rawValue }
}
