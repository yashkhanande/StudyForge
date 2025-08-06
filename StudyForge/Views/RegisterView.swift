//
//  RegisterView.swift
//  StudyForge
//
//  Created by Yash  Khanande on 20/07/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct RegisterView: View {
    @Binding var path: NavigationPath
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var selectedCountry = "Other"
    @State private var errorMessage = ""
    @State private var showSuccess = false

    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("userId") private var storedUserId: String = ""

    let countries = ["USA", "India", "UK", "Australia", "Canada"]

    var body: some View {
        NavigationStack{
            VStack(spacing : 20){
                Text("Register")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.indigo)
                   

                Form{
                    VStack (spacing: 20){
                        //
                        Section{
                            Group{
                                TextField("Name", text: $name)
                                TextField("Email", text: $email)
                                SecureField("Password", text: $password)
                            }
                            .autocapitalization(.none)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            
                            Picker("Select Country",selection: $selectedCountry) {
                                Spacer()
                                ForEach(countries, id: \.self) { Text($0) }
                            }.pickerStyle(.menu)
                            
                        }
                        
                        
                    }
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage).foregroundColor(.red)
                    }
                    
                    
                    
                   
                    
                    
                    if showSuccess {
                        Text("Registration Successful!")
                            .foregroundColor(.green)
                    }
                }.scrollContentBackground(.hidden)
                VStack{
                    Button {
                        register()
                    }label:{Text("Register")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.indigo.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                }.padding()
               
            }.background(Color.gray.opacity(0.1))
        }
    }
    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }

            guard let uid = result?.user.uid else {
                errorMessage = "Unexpected error: User ID not found"
                return
            }

            let userData: [String: Any] = [
                "id": uid,
                "name": name,
                "email": email,
                "country": selectedCountry,
                "goal": "", // ✅ Optional for now
                "streak": 0,
                "requestSent": [],
                "requestReceived": []
            ]

            Firestore.firestore().collection("users").document(uid).setData(userData) { err in
                if let err = err {
                    errorMessage = err.localizedDescription
                } else {
                    showSuccess = true
                    storedUserId = uid
                    isLoggedIn = true
                    path.append(Route.home) // ✅ Skip goal selection
                }
            }
        }
    }
}

#Preview {
    RegisterView(path: .constant(NavigationPath()))
}
