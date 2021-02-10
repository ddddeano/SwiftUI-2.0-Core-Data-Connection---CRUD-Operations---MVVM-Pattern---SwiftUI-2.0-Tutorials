//
//  ContentView.swift
//  KafsoftCRUDOperations
//
//  Created by Daniel Watson on 10/02/2021.
//

import SwiftUI
import CoreData

struct ContentView : View {
    
    var body: some View {
        NavigationView {
            Home()
                .navigationTitle("CoreData")
                .navigationBarTitleDisplayMode(.inline)
        }
        
    }
}

struct Home : View {
    
    @StateObject var model = dataModel()
    
    var body: some View {
        VStack{
            List {
                
                ForEach(model.data, id: \.objectID) { obj in
                    Text(model.getValue(obj: obj))
                        .onTapGesture{model.openUpdateView(obj: obj) }
                }
                .onDelete(perform: model.deleteData(indexSet:))
            }
            .listStyle(InsetListStyle())
            HStack(spacing: 15) {
                TextField("Data here", text: $model.txt )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: model.writeData) {
                    Text("Save")
                }
            }
            .padding()
        }
        .sheet(isPresented: $model.isUpdate) {
            UpDateView(model: model)
        }
    }
}

struct UpDateView : View {
    
    @ObservedObject var model : dataModel
    var body : some View {
        VStack(spacing: 20) {
            TextField("Update Here", text: $model.updateTxt)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button(action: model.updateData) {
                Text("Update")
            }
        }
        .padding()
    }
}

class dataModel: ObservableObject {
    let moc = pC.viewContext
    @Published var data : [NSManagedObject] = []
    @Published var txt = ""
    @Published var isUpdate = false
    @Published var updateTxt = ""
    @Published var selectedObj = NSManagedObject()
    
    init() {
        readData()
    }
    
    func readData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Data")
        do {
            let results = try moc.fetch(request)
            
            self.data = results  as! [NSManagedObject]
        }
        catch {
            print(error.localizedDescription)
        }
    }
    func writeData() {
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Data", into: moc)
        entity.setValue(txt, forKey: "value")
        do {
            try moc.save()
            self.data.append(entity)
            txt = ""
        }
        catch {
            print(error.localizedDescription)
        }
    }
    func deleteData(indexSet: IndexSet) {
        for index in indexSet {
            do {
                let obj = data[index]
                moc.delete(obj)
                try moc.save()
                
                let index = data.firstIndex(of: obj)
                data.remove(at: index!)
                
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
        func updateData() {
            let index = data.firstIndex(of: selectedObj)
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Data")
            
            do {
                let results = try moc.fetch(request) as! [NSManagedObject]
                
                let obj = results.first { (obj)  -> Bool in
                    if obj == selectedObj{return true}
                    else {return false}
                }
                obj?.setValue(updateTxt, forKey: "value")
                
                try moc.save()
                
                data[index!] = obj!
                isUpdate.toggle()
                updateTxt = ""
                
            } catch {
                print(error.localizedDescription)
            }
        }
        func getValue(obj: NSManagedObject) -> String {
            return obj.value(forKey: "value") as! String
        }
    func openUpdateView(obj: NSManagedObject) {
        selectedObj = obj
        isUpdate.toggle()
    }
}
