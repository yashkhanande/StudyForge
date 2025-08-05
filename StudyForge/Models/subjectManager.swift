import Foundation
import SwiftUI

extension subjectManager {
    static var preview: subjectManager {
        let manager = subjectManager()
        manager.subjects = [
            studySubject(name: "History"),
            studySubject(name: "Geography"),
            studySubject(name: "new"),
            studySubject(name: "algebra"),
            studySubject(name: "physics"),
            studySubject(name: "polity"),
            studySubject(name: "computing"),
            studySubject(name: "philosophy"),
            studySubject(name: "Geography")
        ]
        return manager
    }
}

class subjectManager: ObservableObject {
    static let shared = subjectManager() // ✅ Required for .environmentObject()

      @Published var subjects: [studySubject] = []
      private let key = "study_subjects"

      init() {
          loadSubjects()
      }

    func addSubject(name: String) {
        let newSubject = studySubject(name: name)
        subjects.append(newSubject)
        saveSubjects()
    }

    func updateTimer(for subject: studySubject, duration: TimeInterval) {
        if let index = subjects.firstIndex(where: { $0.id == subject.id }) {
            subjects[index].addTime(duration)
            saveSubjects()
        }
    }


     func saveSubjects() {
    #if !DEBUG
        if let encoded = try? JSONEncoder().encode(subjects) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    #endif
    }



    private func loadSubjects() {
        if let data = UserDefaults.standard.data(forKey: key) {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([studySubject].self, from: data) {
                self.subjects = decoded
            }
        }
    }
}
