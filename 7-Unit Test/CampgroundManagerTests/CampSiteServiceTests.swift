//
//  CampSiteServiceTests.swift
//  CampgroundManager
//
//  Created by Steven on 10/26/16.
//  Copyright © 2016 Razeware. All rights reserved.
//

import XCTest
import UIKit
import CoreData
import CampgroundManager

class CampSiteServiceTests: XCTestCase {
  
  // MARK: Properties
  var campSiteService: CampSiteService!
  var coreDataStack: CoreDataStack!
  
  override func setUp() {
    super.setUp()
    coreDataStack = TestCoreDataStack()
    campSiteService = CampSiteService(managedObjectContext: coreDataStack.mainContext, coreDataStack: coreDataStack)
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
    campSiteService = nil
    coreDataStack = nil
  }
  
  func testAddCampsite() {
    let campsite = campSiteService.addCampSite(1, electricity: true, water: true)
    
    XCTAssertTrue(campsite.siteNumber == 1 , "number error")
    XCTAssertTrue(campsite.electricity!.boolValue, "should have elec")
    XCTAssertTrue(campsite.water!.boolValue, "should have walter")
  }
  
  func testRootContextIsSavedAfterAddingCampsite() {
    let derivedContext = coreDataStack.newDerivedContext()
    campSiteService = CampSiteService(managedObjectContext: derivedContext, coreDataStack: coreDataStack)
    
    expectation(forNotification: NSNotification.Name.NSManagedObjectContextDidSave.rawValue, object: coreDataStack.mainContext) { notification in
      return true
    }
    
    let campSite = campSiteService.addCampSite(1, electricity: true, water: true)
    XCTAssertNotNil(campSite)
    
    waitForExpectations(timeout: 2.0) { error in
      XCTAssertNil(error, "Save error")
    }
  }
  
  func testGetCampSiteWithMatchingSiteNumber() {
    _ = campSiteService.addCampSite(1, electricity: true, water: true)
    let campSite = campSiteService.getCampSite(1)
    XCTAssertNotNil(campSite, "Should return")
  }
  
  func testGetCampSiteNoMatchingSiteNumber() {
    _ = campSiteService.addCampSite(1, electricity: true, water: true)
    let campSite = campSiteService.getCampSite(2)
    XCTAssertNil(campSite, "Should return")
  }
}
