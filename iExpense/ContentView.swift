//
//  ContentView.swift
//  iExpense
//
//  Created by Mario Alberto Barragán Espinosa on 02/11/19.
//  Copyright © 2019 Mario Alberto Barragán Espinosa. All rights reserved.
//

import SwiftUI

struct ExpenseItem: Identifiable, Codable {
    let id = UUID()
    let name: String
    let type: String
    let amount: Int
}

class Expenses: ObservableObject {
    
    @Published var items: [ExpenseItem] {
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
    
    @ObservedObject var expenses = Expenses()
    
    @State private var showingAddExpense = false
    
    func amountColor(_ amount: Int) -> Color {
        if amount <= 10 {
            return Color.red
        } else if amount <= 100 {
            return Color.yellow
        } else {
            return Color.green
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(expenses.items) { item in
                     HStack {
                           VStack(alignment: .leading) {
                               Text(item.name)
                                   .font(.headline)
                               Text(item.type)
                           }
                           Spacer()
                           Text("$\(item.amount)")
                            .foregroundColor(self.amountColor(item.amount))
                       }
                }
            .onDelete(perform: removeItems)
            }
            .navigationBarTitle("iExpense")
            .navigationBarItems(leading: EditButton(), trailing:
                Button(action: {
                    self.showingAddExpense = true
                }) {
                    Image(systemName: "plus")
                }
            )
        }.sheet(isPresented: $showingAddExpense) {
            AddView(expenses: self.expenses)
        }
    }
    
    func removeItems(at offsets: IndexSet) {
        expenses.items.remove(atOffsets: offsets)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
