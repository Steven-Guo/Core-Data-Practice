//
//  ReservationServiceTests.swift
//  CampgroundManager
//
//  Created by Steven on 10/26/16.
//  Copyright © 2016 Razeware. All rights reserved.
//

import XCTest
import CoreData
import CampgroundManager
import Foundation

class ReservationServiceTests: XCTestCase {
  
  // MARK: Properties
  var campSiteService: CampSiteService!
  var camperService: CamperService!
  var reservationService: ReservationService!
  var coreDataStack: CoreDataStack!
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
    coreDataStack = TestCoreDataStack()
    camperService = CamperService(managedObjectContext: coreDataStack.mainContext, coreDataStack: coreDataStack)
    campSiteService = CampSiteService(managedObjectContext: coreDataStack.mainContext, coreDataStack: coreDataStack)
    reservationService = ReservationService(managedObjectContext: coreDataStack.mainContext, coreDataStack: coreDataStack)
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
    camperService = nil
    campSiteService = nil
    reservationService = nil
    coreDataStack = nil
  }
  
  func testReserveCampSitePositiveNumberOfDays() {
    let camper = camperService.addCamper("asdf", phoneNumber: "123123123")!
    let campSite = campSiteService.addCampSite(15, electricity: false, water: false)
    
    let result = reservationService.reserveCampSite(campSite, camper: camper, date: Date(), numberOfNights: 5)
    
    XCTAssertNotNil(result.reservation, "reservation can't be nil")
    XCTAssertNil(result.error, "error should be nil")
    XCTAssertTrue(result.reservation?.status == "Reserved", "Status should be reserved")
  }
  
  func testReserveCampSiteNegativeNumberOfDays() {
    let camper = camperService.addCamper("asdf", phoneNumber: "123123123")!
    let campSite = campSiteService.addCampSite(15, electricity: false, water: false)
    
    let result = reservationService.reserveCampSite(campSite, camper: camper, date: Date(), numberOfNights: -1)
    
    XCTAssertNotNil(result.reservation, "reservation can't be nil")
    XCTAssertNotNil(result.error, "error should not be nil")
    XCTAssertTrue(result.error?.userInfo["Problem"] as? String == "Invalid number of days", "Should have error")
    XCTAssertTrue(result.reservation?.status == "Invalid", "Status should be Invalid")
  }
  
  // MARK: - Test getCampSites()
  func testGetEmptyCampSites() {
    let result = campSiteService.getCampSites()
    XCTAssertEqual(result, [], "Result should be empty")
    
    // Or the following
    //    XCTAssertTrue(result.count == 0, "Result should be empty")
  }
  
  func testGetCampSite() {
    _ = campSiteService.addCampSite(1, electricity: true, water: false)
    let sites = campSiteService.getCampSites()
    XCTAssertTrue(sites.count == 1, "There should be no site!!!")
  }
  
  func testGetCampSites() {
    _ = campSiteService.addCampSite(2, electricity: true, water: false)
    _ = campSiteService.addCampSite(3, electricity: false, water: true)
    
    let result = campSiteService.getCampSites()
//    XCTAssertNotEqual(result, [], "Result should not be empty")
    XCTAssertTrue(result.count == 2, "Result should be 2")
  }
  
  // MARK: - Test deleteCampSite
  func testDeleteCampSiteExists() {
    _ = campSiteService.addCampSite(1, electricity: true, water: true)
    
    var result = campSiteService.getCampSite(1)
    XCTAssertNotNil(result, "Site 1 should exist")
    
    campSiteService.deleteCampSite(1)
    result = campSiteService.getCampSite(1)
    XCTAssertNil(result, "Result should be nil")
  }
  
  // MARK: - Test get next site number
  func testGetNextSiteNumberNoSite() {
    let siteNumber = campSiteService.getNextCampSiteNumber()
    XCTAssertTrue(siteNumber == 1, "Number should be 1 if there is no site")
  }
  
  func testGetNextSiteNumberOneSite() {
    _ = campSiteService.addCampSite(1, electricity: true, water: true)
    let siteNumber = campSiteService.getNextCampSiteNumber()
    XCTAssertTrue(siteNumber == 2, "The first site is 1, this should be 2!!!!!")
  }
  
  func testGetNextSiteNumberWithGap() {
    _ = campSiteService.addCampSite(10, electricity: true, water: true)
    let siteNumber = campSiteService.getNextCampSiteNumber()
    XCTAssertTrue(siteNumber == 11, "Number should be 11")
  }
  
  func testGetNextSiteNumberWithManySites() {
    _ = campSiteService.addCampSite(15, electricity: true, water: true)
    _ = campSiteService.addCampSite(19, electricity: true, water: true)
    let siteNumber = campSiteService.getNextCampSiteNumber()
    XCTAssertTrue(siteNumber == 20, "Next number should be 20!!!")
  }
}
