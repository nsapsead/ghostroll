import SwiftUI

struct Goal: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let category: String
    let createdAt: Date
    let targetDate: Date?
    var isCompleted: Bool
    let colorHex: String // Store as hex string
    
    init(id: String, title: String, description: String, category: String,
         createdAt: Date, targetDate: Date? = nil, isCompleted: Bool = false, colorHex: String) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.createdAt = createdAt
        self.targetDate = targetDate
        self.isCompleted = isCompleted
        self.colorHex = colorHex
    }
    
    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
    
    // MARK: - JSON Conversion
    func toJSON() -> [String: Any] {
        var json: [String: Any] = [
            "id": id,
            "title": title,
            "description": description,
            "category": category,
            "createdAt": ISO8601DateFormatter().string(from: createdAt),
            "isCompleted": isCompleted,
            "color": colorHex
        ]
        
        if let targetDate = targetDate {
            json["targetDate"] = ISO8601DateFormatter().string(from: targetDate)
        }
        
        return json
    }
    
    static func fromJSON(_ json: [String: Any]) -> Goal? {
        guard let id = json["id"] as? String,
              let title = json["title"] as? String,
              let description = json["description"] as? String,
              let category = json["category"] as? String,
              let createdAtString = json["createdAt"] as? String,
              let createdAt = ISO8601DateFormatter().date(from: createdAtString),
              let isCompleted = json["isCompleted"] as? Bool,
              let colorHex = json["color"] as? String else {
            return nil
        }
        
        let targetDate: Date?
        if let targetDateString = json["targetDate"] as? String {
            targetDate = ISO8601DateFormatter().date(from: targetDateString)
        } else {
            targetDate = nil
        }
        
        return Goal(
            id: id,
            title: title,
            description: description,
            category: category,
            createdAt: createdAt,
            targetDate: targetDate,
            isCompleted: isCompleted,
            colorHex: colorHex
        )
    }
    
    // MARK: - Copy with updates
    func copyWith(id: String? = nil, title: String? = nil, description: String? = nil,
                  category: String? = nil, createdAt: Date? = nil, targetDate: Date? = nil,
                  isCompleted: Bool? = nil, colorHex: String? = nil) -> Goal {
        return Goal(
            id: id ?? self.id,
            title: title ?? self.title,
            description: description ?? self.description,
            category: category ?? self.category,
            createdAt: createdAt ?? self.createdAt,
            targetDate: targetDate ?? self.targetDate,
            isCompleted: isCompleted ?? self.isCompleted,
            colorHex: colorHex ?? self.colorHex
        )
    }
}

// MARK: - Color Extension for Hex Support
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
