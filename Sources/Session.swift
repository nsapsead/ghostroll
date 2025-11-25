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
}
