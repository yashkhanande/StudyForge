//
//  GoalSelectionView.swift
//  StudyForge
//
//  Created by Yash  Khanande on 20/07/25.
//
import SwiftUI
import FirebaseFirestore

struct GoalSelectionView: View {
    let userId: String
    @Binding var path: NavigationPath

    @State private var country: String = ""
    @State private var selectedCountry: String = ""
    @State private var selectedGoal = ""
    @State private var goals: [String] = []
    @State private var error = ""
    @State private var isLoading = true
    @State private var showSuccessAlert = false
    @State private var selectedFlavor: String = ""
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("userId") private var storedUserId: String = ""

    let countries: [String] = ["India", "USA", "UK", "Australia", "Canada"]

    var body: some View {
        VStack(spacing: 20) {
            
            if isLoading {
                ProgressView("Loading user data...")
            } else {
               

                    Text("Set or Update Goal")
                        .font(.title)
                        .padding(.top)
               
                
                List{
                        Picker(selection: $selectedCountry) {
                            ForEach(countries, id: \.self) { Text($0) }
                        }label : {
                            Text("Select Country")
                            Text("For You Want To prepare")
                        }
                        
                        Picker( selection: $selectedGoal) {
                            ForEach(goals, id: \.self) { Text($0) }
                        }label : {
                            Text("Select Goal")
                        }
                    
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .frame(height: 170)
                    Button{
                        saveGoalAndCountry()
                    }label :{
                        Text("💾 Save Changes")
                    }
                    .foregroundStyle(Color.indigo)
                    .disabled(selectedGoal.isEmpty || selectedCountry.isEmpty)
                    .padding()
                    .background(Color.indigo.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                Spacer()
                if !error.isEmpty {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding()
        .onAppear {
            fetchUserData()
        }
        .onChange(of: selectedCountry) {
            updateGoals(for: selectedCountry)
            selectedGoal = goals.first ?? ""
        }
        .alert("🎯 Goal Updated", isPresented: $showSuccessAlert) {
            Button("OK") {
                path.append(Route.home)
            }
        } message: {
            Text("Your goal and country have been successfully saved.")
        }
    }

    // MARK: - Firestore Fetch
    func fetchUserData() {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { doc, err in
            if let err = err {
                self.error = "Failed to fetch user data: \(err.localizedDescription)"
                self.isLoading = false
                return
            }

            guard let data = doc?.data() else {
                self.error = "User data not found"
                self.isLoading = false
                return
            }

            self.country = data["country"] as? String ?? ""
            self.selectedCountry = self.country // Initialize selectedCountry
            let existingGoal = data["goal"] as? String ?? ""

            updateGoals(for: self.country)
            self.selectedGoal = existingGoal.isEmpty ? (goals.first ?? "") : existingGoal
            self.isLoading = false
        }
    }

    // MARK: - Local Goal Update
    func updateGoals(for country: String) {
        switch country {
        case "India":
            goals = ["UPSC", "JEE", "NEET", "SSC", "GATE"]
        case "USA":
            goals = ["SAT", "GRE", "TOEFL", "MCAT", "GMAT"]
        default:
            goals = ["General Goal 1", "General Goal 2"]
        }
    }

    // MARK: - Save Goal and Country in One Firestore Call
    func saveGoalAndCountry() {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)

        let updateData: [String: Any] = [
            "country": selectedCountry,
            "goal": selectedGoal
        ]

        userRef.setData(updateData, merge: true) { error in
            if let error = error {
                self.error = "Failed to save data: \(error.localizedDescription)"
            } else {
                self.storedUserId = userId
                self.isLoggedIn = true
                self.showSuccessAlert = true
            }
        }
    }
}


#Preview {
    GoalSelectionView(userId: "test-id", path: .constant(NavigationPath()))
}
