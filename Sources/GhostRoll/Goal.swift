import Foundation

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
