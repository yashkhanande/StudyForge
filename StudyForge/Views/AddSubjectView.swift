//
//  AddSubjectView.swift
//  StudyForge
//
//  Created by Yash  Khanande on 16/07/25.
//

import SwiftUI

struct AddSubjectView: View {
    @EnvironmentObject var SubjectManager: subjectManager
    @Environment(\.dismiss) var dismiss
    @State private var subjectName: String = ""
    var body: some View {
        VStack{
            
            TextField("Maths, Science, History, eg..." , text: $subjectName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            Button {
                if !subjectName.isEmpty {
                    SubjectManager.addSubject(name: subjectName)
                    dismiss()
                }
            }label : {
                Text("Save")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(subjectName.isEmpty ? Color.gray : Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
            }
            Spacer()
            
        }
        .navigationTitle("Add Subject")
    }
}
#Preview {
    AddSubjectView()
}
