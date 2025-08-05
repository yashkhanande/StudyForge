//
//  LeaderboardView 2.swift
//  StudyForge
//
//  Created by Yash  Khanande on 30/07/25.
//
import SwiftUI
import Firebase
import FirebaseAuth

struct LeaderboardView: View {
    @ObservedObject var userService = UserService.shared

    @State private var leaderboardUsers: [LeaderboardUser] = []
    @State private var isLoading: Bool = true
    @State private var showError: Bool = false

    var topUsers: [(index: Int, user: LeaderboardUser)] {
        Array(
            leaderboardUsers
                .sorted(by: { $0.streak > $1.streak })
                .prefix(100)
                .enumerated()
                .map { (offset, user) in (index: offset, user: user) }
        )
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Loading leaderboard...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if showError {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                        Text("Failed to load leaderboard.")
                        Button("Retry") {
                            fetchLeaderboard()
                        }
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(topUsers, id: \.user.id) { index, user in
                            NavigationLink(destination: ProfileView(user: user)) {
                                HStack {
                                    Text("#\(index + 1)")
                                        .font(.subheadline)
                                        .foregroundColor(user.isCurrentUser ? .indigo : .gray)

                                    Circle()
                                        .fill(Color.blue.opacity(0.2))
                                        .frame(width: 35, height: 35)
                                        .overlay(Text(String(user.name.prefix(1))).fontWeight(.bold))

                                    Text(user.isCurrentUser ? "You" : user.name)
                                        .fontWeight(user.isCurrentUser ? .bold : .regular)

                                    Spacer()

                                    Text("\(user.streak) 🔥")
                                        .foregroundColor(user.isCurrentUser ? .indigo : .primary)
                                }
                            }
                            .padding(.vertical, 6)
                        }
                    }
                }
            }
            .navigationTitle("Leaderboard")
            .onAppear {
                fetchLeaderboard()
            }
        }
    }

    private func fetchLeaderboard() {
        isLoading = true
        showError = false

        guard let firebaseUID = Auth.auth().currentUser?.uid else {
            showError = true
            isLoading = false
            return
        }

        let currentUser = userService.currentUser

        // Avoid blank screen if currentUser not ready
        guard !currentUser.name.isEmpty else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                fetchLeaderboard()
            }
            return
        }

        let db = Firestore.firestore()
        db.collection("users")
            .whereField("goal", isEqualTo: currentUser.studyGoal.rawValue.lowercased())
            .whereField("country", isEqualTo: currentUser.country)
            .order(by: "streak", descending: true)
            .limit(to: 100)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    isLoading = false

                    if let error = error {
                        print("❌ Error fetching leaderboard: \(error)")
                        showError = true
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        showError = true
                        return
                    }

                    var fetchedUsers: [LeaderboardUser] = []
                    for (index, doc) in documents.enumerated() {
                        let data = doc.data()
                        let uid = doc.documentID
                        let name = data["name"] as? String ?? "Unknown"
                        let streak = data["streak"] as? Int ?? 0

                        fetchedUsers.append(
                            LeaderboardUser(
                                id: uid,
                                name: name,
                                streak: streak,
                                isCurrentUser: uid == firebaseUID,
                                rank: index + 1
                            )
                        )
                    }

                    // If current user not in top 100, add manually
                    if !fetchedUsers.contains(where: { $0.id == firebaseUID }) {
                        fetchedUsers.append(
                            LeaderboardUser(
                                id: firebaseUID,
                                name: currentUser.name,
                                streak: currentUser.streak,
                                isCurrentUser: true,
                                rank: -1
                            )
                        )
                    }

                    leaderboardUsers = fetchedUsers
                }
            }
    }
}


#Preview {
    LeaderboardView()
        .environmentObject(UserService.shared)
}
