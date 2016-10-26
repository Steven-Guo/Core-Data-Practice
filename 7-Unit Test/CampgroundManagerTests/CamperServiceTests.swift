//
//  CamperServiceTests.swift
//  CampgroundManager
//
//  Created by Steven on 10/26/16.
//  Copyright © 2016 Razeware. All rights reserved.
//

import XCTest
import CampgroundManager
import CoreData

class CamperServiceTests: XCTestCase {
  
  // MARK: Properties
  var camperService: CamperService!
  var coreDataStack: CoreDataStack!
  
  override func setUp() {
    super.setUp()
    coreDataStack = TestCoreDataStack()
    camperService = CamperService(managedObjectContext: coreDataStack.mainContext, coreDataStack: coreDataStack)
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
    camperService = nil
    coreDataStack = nil
  }
  
  func testAddCamper() {
    let camper = camperService.addCamper("BB", phoneNumber: "123123123")
    XCTAssertNotNil(camper, "Camper can't be nil")
    XCTAssertTrue(camper?.fullName == "BB")
    XCTAssertTrue(camper?.phoneNumber == "123123123")
  }
  
  func testRootContextIsSavedAfterAddingCamper() {
    // 1
    let derivedContext = coreDataStack.newDerivedContext()
    camperService = CamperService(managedObjectContext: derivedContext, coreDataStack: coreDataStack)
    
    // 2
    expectation(forNotification: NSNotification.Name.NSManagedObjectContextDidSave.rawValue, object: coreDataStack.mainContext) { notification in
      return true
    }
    
    // 3
    let camper = camperService.addCamper("BBB", phoneNumber: "123123123")
    XCTAssertNotNil(camper)
    
    // 4
    waitForExpectations(timeout: 2.0) { error in
      XCTAssertNil(error, "Save not occur")
    }
  }
}
