//
//  KafsoftCRUDOperationsApp.swift
//  KafsoftCRUDOperations
//
//  Created by Daniel Watson on 10/02/2021.
//

import SwiftUI
import CoreData

@main
struct KafsoftCRUDOperationsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, pC.viewContext)
        }
    }
}

var pC: NSPersistentContainer = {
    
    let container = NSPersistentContainer(name: "CoreData" )
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
        if let error = error as NSError? {
            fatalError( "unresolved error \(error), \(error.userInfo)")
        }
    })
    return container
}()
func saveContext () {
    let context = pC.viewContext
    if context.hasChanges {
        do {
            try context.save()
        } catch {
            
            let nserror = error as NSError
            fatalError( "unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
