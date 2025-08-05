//
//  LoginView.swift
//  StudyForge
//
//  Created by Yash  Khanande on 20/07/25.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var error = ""

    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("userId") var userId: String = ""

    @Binding var path: NavigationPath

    var body: some View {
        VStack(spacing: 20) {
            Text("Login")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(.indigo)
                .padding()
            
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .padding()
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            SecureField("Password", text: $password)
                .textInputAutocapitalization(.never)
                .padding()
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            if !error.isEmpty {
                Text(error).foregroundStyle(.red)
            }
            
            Button {
                login()
            }label :{
                Text("Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.indigo.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
     
            NavigationLink("Don't have an account? Register", destination: RegisterView(path: $path))
        }
        .padding()
    }

    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, err in
            if let err = err {
                self.error = err.localizedDescription
            } else if let uid = result?.user.uid {
                self.userId = uid
                self.isLoggedIn = true
                path.append(Route.home) // ✅ Go straight to TodayView via ContentView
            }
        }
    }
}

#Preview {
    LoginView(path: .constant(NavigationPath()))
}
