//
//  ContentView.swift
//  Plannerly(3)
//
//  Created by Fengyi Hu on 31/07/2021.
//

import SwiftUI

struct ExpenseItem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let flag: Bool
    let travelDate : Date
    let travelNote : String
}

class Expenses: ObservableObject {
    @Published var items = [ExpenseItem]() {
        didSet {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
    
    init() {
        if let items = UserDefaults.standard.data(forKey: "Items") {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([ExpenseItem].self, from: items) {
                self.items = decoded
                return
            }
        }

        self.items = []
    }
}

struct ContentView: View {
    let menu = Bundle.main.decode([MenuSection].self, from: "menu.json")
    let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            return formatter
        }()
    
    @State private var latestTravelDate = Date()
    @State private var selectedTab = 0
    @State private var showingSheet = false
    @ObservedObject var expenses = Expenses()
    @State private var showingAddExpense = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ScrollView{
                VStack{
                    HStack(alignment: .top){
                        Text("Next Travel Date")
                            .font(.headline)
                        Text("\(latestTravelDate, formatter: dateFormatter)")
                            .font(.headline)
                        Spacer()
                    }
                    Spacer(minLength: 20)
                    HStack{
                        Text("Upcoming Tasks")
                            .font(.title)
                        Spacer()
                        Button(action: {
                                    self.selectedTab = 1
                                }) {
                                    Text("See All")
                                }
                    }
                    HStack{
                        VStack (alignment: .leading) {
                            Spacer(minLength: 10)
                            Text("1. GP registration")
                            Text("2. Uni IT setup")
                            Text("3. Grocery and shopping")
                        }
                        Spacer()
                    }
                    Spacer(minLength: 20)
                    HStack{
                        Text("Did you know")
                            .font(.title)
                        Spacer()
                    }
                    ScrollView(.horizontal) {
                        HStack(spacing: 20) {
                            HighlightView(illus: "british museum", catagory:"Places To Go", title: "The British Museum is older than the USA")
                                .frame(width: 350, height: 400)
                            HighlightView(illus: "big ben", catagory:"Fun Facts", title: "Big Ben is not actually called Big Ben")
                                .frame(width: 350.0, height: 400)
                            HighlightView(illus: "london eye", catagory: "Places To Go", title: "The London Eye was originally planned as a temporary structure")
                                .frame(width: 350.0, height: 400)
                        }
                    }
                    Spacer(minLength: 20)
                    HStack{
                        Text("From students to students")
                            .font(.title)
                        Spacer()
                    }
                    Text("Have questions? Connect to students just like you. Just go to forum, post your question, and wait for a reply.")
                }
            }.padding()
                .tabItem {
                    Image(systemName: "star")
                    Text("Home")
                }
                .tag(0)

            NavigationView {
                List {
                    Section(header: Text("My Tasks")){
                        ForEach(expenses.items) { item in
                            VStack{
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(item.name)
                                            .font(.headline)
                                            .foregroundColor(item.flag ?.red : Color(.label))
                                        Text(item.travelNote)
                                    }
                                    Spacer()
                                    Text("\(item.travelDate, formatter: dateFormatter)")
                                }
                            }
                        }.onDelete(perform: removeItems)
                    }
                    
                    ForEach(menu) { section in
                                        Section(header: Text(section.name)) {
                                            ForEach(section.items) { item in
                                                NavigationLink(destination: ItemDetailView(item: item)) {
                                                    ItemRowView(item: item)
                                                }
                                            }
                                        }
                    }.onDelete(perform: removeItems)
                }
                .navigationBarTitle("Task List")
                .navigationBarItems(trailing:
                    Button(action: {
                        self.showingAddExpense = true
                    }) {
                        Image(systemName: "plus")
                    }
                )
                .sheet(isPresented: $showingAddExpense) {
                    AddView(expenses: self.expenses)
                }
            }
                .tabItem {
                    Image(systemName: "text.badge.checkmark")
                    Text("Tasks")
                }
                .tag(1)
            
            ForumView()
                .tabItem {
                    Image(systemName: "newspaper")
                    Text("Forum")
                }
                .tag(2)
        }
    }
    func removeItems(at offsets: IndexSet) {
        expenses.items.remove(atOffsets: offsets)
    }
}


struct HighlightView : View {
    var illus : String
    var catagory : String
    var title : String
    var body : some View {
        VStack {
            ZStack {
                Image(illus).resizable()
                LinearGradient(gradient: Gradient(colors: [.clear,Color.black.opacity(0.5)]), startPoint: .top, endPoint: .bottom)
                
                VStack (alignment: .leading) {
                    Text(catagory).foregroundColor(.white).bold()
                    Spacer()
                    Text(title).foregroundColor(.white).font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).bold()
                }.padding()
            }
        }.cornerRadius(20).padding([.leading, .bottom, .trailing])
    }
}

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Text("Profile")
        Button("Dismiss") {
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ItemDetailView: View {
    let item: MenuItem
    @State var taskDate = Date()

    
    var body: some View {
        VStack(alignment: .leading) {
            Text(item.description)
            DatePicker(selection: $taskDate, displayedComponents: .date) {
                            Text("Select a date")
                        }
            Spacer(minLength: 10)
            Text("Recommended Provider: \(item.photoCredit)").font(.title2)
            Image(item.mainImage)
                .resizable()
                .scaledToFit()
            Spacer()
        }.padding()
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ItemRowView: View {
    let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            return formatter
        }()
    let item: MenuItem

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
            }
            Spacer()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
