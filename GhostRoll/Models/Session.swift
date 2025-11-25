import Foundation

enum ClassType: String, CaseIterable, Codable {
    case gi = "gi"
    case noGi = "noGi"
    case striking = "striking"
    case seminar = "seminar"
    
    var displayName: String {
        switch self {
        case .gi: return "Gi"
        case .noGi: return "No-Gi"
        case .striking: return "Striking"
        case .seminar: return "Seminar"
        }
    }
}

struct Session: Identifiable, Codable {
    let id: String
    let date: Date
    let classType: ClassType
    let focusArea: String
    let rounds: Int
    let techniquesLearned: [String]
    let sparringNotes: String?
    let reflection: String?
    let mood: String?
    let location: String?
    let instructor: String?
    let duration: Int // in minutes
    let isScheduledClass: Bool
    
    init(id: String, date: Date, classType: ClassType, focusArea: String, 
         rounds: Int, techniquesLearned: [String], sparringNotes: String? = nil,
         reflection: String? = nil, mood: String? = nil, location: String? = nil,
         instructor: String? = nil, duration: Int = 60, isScheduledClass: Bool = false) {
        self.id = id
        self.date = date
        self.classType = classType
        self.focusArea = focusArea
        self.rounds = rounds
        self.techniquesLearned = techniquesLearned
        self.sparringNotes = sparringNotes
        self.reflection = reflection
        self.mood = mood
        self.location = location
        self.instructor = instructor
        self.duration = duration
        self.isScheduledClass = isScheduledClass
    }
    
    var durationDisplay: String {
        let hours = duration / 60
        let minutes = duration % 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
    
    // MARK: - JSON Conversion
    func toJSON() -> [String: Any] {
        return [
            "id": id,
            "date": ISO8601DateFormatter().string(from: date),
            "classType": classType.rawValue,
            "focusArea": focusArea,
            "rounds": rounds,
            "techniquesLearned": techniquesLearned,
            "sparringNotes": sparringNotes ?? "",
            "reflection": reflection ?? "",
            "mood": mood ?? "",
            "location": location ?? "",
            "instructor": instructor ?? "",
            "duration": duration,
            "isScheduledClass": isScheduledClass
        ]
    }
    
    static func fromJSON(_ json: [String: Any]) -> Session? {
        guard let id = json["id"] as? String,
              let dateString = json["date"] as? String,
              let classTypeString = json["classType"] as? String,
              let classType = ClassType(rawValue: classTypeString),
              let focusArea = json["focusArea"] as? String,
              let rounds = json["rounds"] as? Int,
              let techniquesLearned = json["techniquesLearned"] as? [String] else {
            return nil
        }
        
        let date = ISO8601DateFormatter().date(from: dateString) ?? Date()
        let sparringNotes = json["sparringNotes"] as? String
        let reflection = json["reflection"] as? String
        let mood = json["mood"] as? String
        let location = json["location"] as? String
        let instructor = json["instructor"] as? String
        let duration = json["duration"] as? Int ?? 60
        let isScheduledClass = json["isScheduledClass"] as? Bool ?? false
        
        return Session(
            id: id,
            date: date,
            classType: classType,
            focusArea: focusArea,
            rounds: rounds,
            techniquesLearned: techniquesLearned,
            sparringNotes: sparringNotes,
            reflection: reflection,
            mood: mood,
            location: location,
            instructor: instructor,
            duration: duration,
            isScheduledClass: isScheduledClass
        )
    }
}
