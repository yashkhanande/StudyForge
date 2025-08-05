//
//  ProfileView.swift
//  StudyForge
//
//  Created by Yash  Khanande on 16/07/25.
//

import SwiftUI
import FirebaseAuth
import Firebase

struct ProfileView: View {
    var user : LeaderboardUser
    @State private var isRequestSent : Bool = false
    var body: some View {
        Spacer()
        VStack{
            VStack(alignment : .center ,spacing : 8 ){
              
                Circle()
                    .fill(Color.indigo.opacity(0.2))
                    .frame(width: 100, height: 100)
                    .overlay(Text(user.name.prefix(1))
                        .font(.system(size: 50, weight: .bold)))
                    .foregroundStyle(Color.indigo)
                Text(user.name)
                    .font(.title)
                    .fontWeight(.bold)
                Text("🔥 Streak \(user.streak)")
                    .font(.headline)
                    .foregroundStyle(Color.orange)
                
                Text("Hey Everyone i am preparing for UPSC And i will be happy to conncet with you")
                    .multilineTextAlignment(.center)
                    .padding()
                Text("Total Time Studied")
                    .fontWeight(.bold)
                    .font(.title2)
                Text("200 Hours")
                    .fontWeight(.semibold)
                
            }
          
            Spacer()
            Button{
                sendFriendRequest()
            }label :{
                Text("Connect")
                    .foregroundStyle(Color.indigo)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.indigo.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }.disabled(isRequestSent)
        }.padding()
            .navigationTitle("Profile")
            .onAppear{
                checkIfRequestAlreadySent()
            }
    }
    func sendFriendRequest(){
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        
        let senderRef = db.collection("users").document(currentUserId)
        let receiverRef = db.collection("users").document(user.id)
        
        senderRef.updateData(["requestSent" : FieldValue.arrayUnion([user.id])])
        
        receiverRef.updateData(["requestReceived" : FieldValue.arrayUnion([currentUserId])]){
            error in
            if error == nil {
                isRequestSent = true
            }
        }
    }
    func checkIfRequestAlreadySent(){
        guard let currentUserId = Auth.auth().currentUser?.uid else {return}
        let db = Firestore.firestore()
        
        db.collection("users").document(currentUserId).getDocument() {
            snapshot , error in
            if let data = snapshot?.data(),
               let sentRequests = data["requestSent"] as? [String]{
                if sentRequests.contains(user.id){
                    isRequestSent = true
                }
            }
        }
    }
}

#Preview {
    ProfileView(user: LeaderboardUser(id:"UID5",name: "Yash", streak: 100, isCurrentUser: false,rank:0))
    
}
