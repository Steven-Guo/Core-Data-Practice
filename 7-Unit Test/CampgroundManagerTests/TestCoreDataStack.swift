//
//  TestCoreDataStack.swift
//  CampgroundManager
//
//  Created by Steven on 10/26/16.
//  Copyright © 2016 Razeware. All rights reserved.
//

@testable import CampgroundManager
import Foundation
import CoreData

class TestCoreDataStack: CoreDataStack {
  convenience init() {
    self.init(modelName: "CampgroundManager")
  }
  
  override init(modelName: String) {
    super.init(modelName: modelName)
    
    let persistenStoreDescription = NSPersistentStoreDescription()
    persistenStoreDescription.type = NSInMemoryStoreType
    
    let container = NSPersistentContainer(name: modelName)
    container.persistentStoreDescriptions = [persistenStoreDescription]
    
    container.loadPersistentStores { (storeDescription, error) in
      if let error = error as? NSError {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
    
    self.storeContainer = container
  }
}
