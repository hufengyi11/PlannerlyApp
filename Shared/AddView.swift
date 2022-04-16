//
//  AddView.swift
//  Plannerly(3)
//
//  Created by Fengyi Hu on 13/08/2021.
//

import SwiftUI

struct AddView: View {
    let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            return formatter
        }()

    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var flag = false
    @State private var travelNote = ""
    @State private var travelDate = Date()
    @ObservedObject var expenses: Expenses


    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                Toggle("Flag the task", isOn: $flag)
                DatePicker(selection: $travelDate, displayedComponents: .date) {
                                Text("Travel date")
                            }
                //TextField("Add some notes", text: $amount)
                    .keyboardType(.numberPad)
                TextField("Add some notes", text: $travelNote)
            }
            .navigationBarTitle("Add new task")
            .navigationBarItems(trailing: Button("Save") {
                let item = ExpenseItem(name: self.name, flag: self.flag, travelDate: self.travelDate, travelNote: self.travelNote)
                    self.expenses.items.append(item)
                    self.presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView(expenses: Expenses())
    }
}
