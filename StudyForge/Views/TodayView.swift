import SwiftUI
import Foundation

struct TodayView: View {
    @EnvironmentObject var SubjectManager: subjectManager
    @State private var SelectedSubject: studySubject? = nil
    @ObservedObject var userService = UserService.shared
    @State private var isStudying: Bool = false
    @State private var studyDuration: TimeInterval = 0
    @State private var timer: Timer? = nil
    @State private var showStreakToast: Bool = false

    let quote: String = "Discipline is the bridge between goals and accomplishment."
    var today = Date()

    var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: today)
    }

    var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: today)
    }

    var totalTimeToday: TimeInterval {
        SubjectManager.subjects.reduce(0) {
            $0 + $1.timeToday()
        }
    }

    func startTimer() {
        isStudying = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            studyDuration += 1
        }
        RunLoop.current.add(timer!, forMode: .common)
    }

    func stopTimer() {
        print("Studied for \(formatTime(studyDuration))")
        timer?.invalidate()
        timer = nil
        isStudying = false

        if let subject = SelectedSubject {
            SubjectManager.updateTimer(for: subject, duration: studyDuration)
            SelectedSubject = nil
        }

        let updatedTotal = totalTimeToday + studyDuration
        userService.updateStreakIfNeeded(totalToday: updatedTotal)

        studyDuration = 0
    }

    func formatTime(_ seconds: TimeInterval) -> String {
        let hrs = Int(seconds) / 3600
        let mins = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d:%02d", hrs, mins, secs)
    }

    func deleteSubject(at offsets: IndexSet) {
        SubjectManager.subjects.remove(atOffsets: offsets)
        SubjectManager.saveSubjects()
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                // 🔹 Top bar: Date + Premium + Streak
                HStack(alignment: .center) {
                    HStack(spacing: 5) {
                        Text(dayString)
                        Text(monthString)
                            .foregroundStyle(Color.indigo)
                    }
                    .font(.title)
                    .fontWeight(.semibold)

                    HStack(spacing: 3) {
                        Image(systemName: "crown.fill")
                            .foregroundStyle(Color.red.gradient)
                        Text("Premium")
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .frame(height: 20)
                    .padding(.horizontal, 5)
                    .background(Color.yellow.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 30))

                    Spacer()

                    HStack {
                        Text("\(userService.currentUser.streak)")
                            .font(.subheadline)
                        Image(systemName: "flame.fill")
                            .foregroundStyle(Color.red)
                            .font(.subheadline)
                    }
                    .frame(height: 30)
                    .padding(.horizontal, 15)
                    .background(Color.orange.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                }.onAppear {
                    userService.refreshUserFromFirestore { success in
                        if success {
                            print("✅ User data refreshed from Firestore.")
                        } else {
                            print("⚠️ Using local cached user data.")
                        }
                    }
                }

                .padding(.horizontal)

                Text(quote)
                    .font(.subheadline)
                    .italic()
                    .multilineTextAlignment(.center)

                // 🔹 Add subject
                HStack {
                    NavigationLink {
                        AddSubjectView()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Subjects")
                        }
                        .font(.subheadline)
                    }
                    Spacer()
                }
                .padding(.horizontal)

                // 🔹 Total time
                HStack {
                    Text("Total Time:")
                        .font(.title2)
                        .bold()
                    Spacer()
                    Text(formatTime(totalTimeToday + (isStudying ? studyDuration : 0)))
                        .bold()
                }
                .padding(.top)
                .padding(.horizontal)

                // 🔹 Subject List
                ScrollView {
                    VStack(spacing: 18) {
                        ForEach(SubjectManager.subjects) { subject in
                            Button {
                                // 🟢 Stop previous session if active
                                if isStudying {
                                    stopTimer()
                                }
                                SelectedSubject = subject
                                startTimer()
                            } label: {
                                HStack {
                                    Text(subject.name)
                                        .font(.subheadline)
                                    Spacer()
                                    Text(
                                        formatTime(
                                            subject.timeToday() + (isStudying && SelectedSubject?.id == subject.id ? studyDuration : 0)
                                        )
                                    )
                                }
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        .onDelete(perform: deleteSubject)
                    }
                    .padding(.horizontal)
                }

                // 🔹 Timer Section
                if isStudying {
                    HStack {
                        Text(SelectedSubject?.name ?? "Studying")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(Color.indigo)

                        Spacer()

                        Text(formatTime(studyDuration))
                            .font(.title2)
                            .bold()

                        Button {
                            stopTimer()
                        } label: {
                            Image(systemName: "pause.fill")
                                .foregroundColor(.white)
                                .padding(5)
                                .background(Color.red)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .onReceive(userService.$didUpdateStreak) { updated in
                if updated {
                    showStreakToast = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        userService.didUpdateStreak = false
                    }
                }
            }
            .alert("🔥 Streak Updated", isPresented: $showStreakToast) {
                Button("Ok", role: .cancel) {}
            }
        }
    }
}

#Preview {
    NavigationStack {
        TodayView()
            .environmentObject(subjectManager.preview)
    }
}
