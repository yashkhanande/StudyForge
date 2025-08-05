import Foundation


class studySubject: Codable, Identifiable, Equatable {
    var id = UUID()
    var name: String
    var totalTime: TimeInterval
    var dailyLog: [String: TimeInterval] = [:]

    init(name: String) {
        self.name = name
        self.totalTime = 0
    }

    func addTime(_ seconds: TimeInterval) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayKey = formatter.string(from: Date())
        dailyLog[todayKey, default: 0] += seconds
        totalTime += seconds
    }

    func timeToday() -> TimeInterval {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayKey = formatter.string(from: Date())
        return dailyLog[todayKey, default: 0]
    }

    static func == (lhs: studySubject, rhs: studySubject) -> Bool {
        lhs.id == rhs.id
    }
}
