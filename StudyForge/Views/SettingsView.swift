//
//  SettingsView.swift
//  StudyForge
//
//  Created by Yash  Khanande on 15/07/25.
import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @Binding var path: NavigationPath
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("userId") private var userId: String = ""

    var body: some View {
        List{
            Text("Settings")
                .font(.largeTitle.bold())
                .padding(.horizontal)
         
                NavigationLink(destination: GoalSelectionView(userId: userId, path: $path) ){
                    Text("🎯 Set / Update Goal")
                    //                    .frame(maxWidth: .infinity)
                    //                    .padding()
                        .foregroundStyle(Color.black)
                    //.background(Color.blue.opacity(0.2))
                    //                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
         
                Button("🚪 Log Out") {
                    logout()
                }
            
//            .frame(maxWidth: .infinity)
//            .padding()
//            .background(Color.red.opacity(0.2))
//            .clipShape(RoundedRectangle(cornerRadius: 12))
        }.listStyle(GroupedListStyle())
        
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
            userId = ""
            path = NavigationPath() // ✅ Full reset
        } catch {
            print("Logout error: \(error.localizedDescription)")
        }
    }
}

#Preview {
    SettingsView(path: .constant(NavigationPath()))
}
