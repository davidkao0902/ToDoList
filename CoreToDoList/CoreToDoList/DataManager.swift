//
//  DataManager.swift
//  CoreToDoList
//
//  Created by David Kao on 2021-03-22.
//

import Foundation
import CoreData

class DataManager {
    
    static let shared = DataManager()
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "CoreToDoList")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func addToDoItem(title: String, notes: String, isCompleted: Bool, needReminderDate: Bool, reminderDate: Date) -> ToDoItem {
        let item = ToDoItem(context: persistentContainer.viewContext)
        item.title = title
        item.notes = notes
        item.isCompleted = isCompleted
        item.needReminderDate = needReminderDate
        item.reminderDate = reminderDate
        return item
    }
    
    func getAllToDoItems() -> [ToDoItem] {
        let request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        
        request.sortDescriptors = [NSSortDescriptor(key: "isCompleted", ascending: true), NSSortDescriptor(key: "reminderDate", ascending: true)]
        
        var fetchedToDoItems: [ToDoItem] = []
        
        do {
            fetchedToDoItems = try persistentContainer.viewContext.fetch(request)
        } catch {
            print("Error fetching items")
        }
        return fetchedToDoItems
    }
    
    func getCompletedToDoItems() -> [ToDoItem] {
        
        let request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        
        request.sortDescriptors = [NSSortDescriptor(key: "reminderDate", ascending: true)]
        
        request.predicate = NSPredicate(format: "isCompleted == true")
        
        var fetchedToDoItems: [ToDoItem] = []
        
        do {
            fetchedToDoItems = try persistentContainer.viewContext.fetch(request)
        } catch {
            print("Error fetching items")
        }
        return fetchedToDoItems
    }
    
    func getIncompleteToDoItems() -> [ToDoItem] {
        
        let request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        
        request.sortDescriptors = [NSSortDescriptor(key: "reminderDate", ascending: true)]
        
        request.predicate = NSPredicate(format: "isCompleted == false")
        
        var fetchedToDoItems: [ToDoItem] = []
        
        do {
            fetchedToDoItems = try persistentContainer.viewContext.fetch(request)
        } catch {
            print("Error fetching items")
        }
        return fetchedToDoItems
    }
    // MARK: - Core Data Saving support

    func save () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func delete (item: ToDoItem) {
        let context = persistentContainer.viewContext
        context.delete(item)
        save()
    }
}
