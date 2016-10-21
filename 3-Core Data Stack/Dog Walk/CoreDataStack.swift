//
//  CoreDataStack.swift
//  Dog Walk
//
//  Created by Steven on 10/16/16.
//  Copyright © 2016 Razeware. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
  private let modelName: String
  
  init(modelName: String) {
    self.modelName = modelName
  }
  
  private lazy var storeContainer: NSPersistentContainer = {
    let container: NSPersistentContainer = NSPersistentContainer(name: self.modelName)
    container.loadPersistentStores { (storeDescription, error) in
      if let error = error as? NSError {
        print(error.userInfo)
      }
    }
    return container
  }()
  
  lazy var managedObjectContext: NSManagedObjectContext = {
    return self.storeContainer.viewContext
  }()
  
  func saveContext() {
    guard managedObjectContext.hasChanges else { return }
    do {
      try managedObjectContext.save()
    } catch let error as NSError {
      print(error.userInfo)
    }
  }
}
