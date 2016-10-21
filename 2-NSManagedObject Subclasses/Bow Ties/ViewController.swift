/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import CoreData

class ViewController: UIViewController {
  
  // MARK: - IBOutlets
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var ratingLabel: UILabel!
  @IBOutlet weak var timesWornLabel: UILabel!
  @IBOutlet weak var lastWornLabel: UILabel!
  @IBOutlet weak var favoriteLabel: UILabel!
  
  // MARK: - CoreData Properties
  var managedObjectContext: NSManagedObjectContext!
  var currentBowtie: Bowtie!
  
  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    insertSampleData()
    
    // Set request
    let request = NSFetchRequest<Bowtie>(entityName: "Bowtie")
    let firstTitle = segmentedControl.titleForSegment(at: 0)!
    request.predicate = NSPredicate(format: "searchKey == %@", firstTitle)
    
    // Execute request
    do {
      let results = try managedObjectContext.fetch(request)
      currentBowtie = results.first
      
      populate(bowtie: results.first!)
    } catch let error as NSError {
      print(error.userInfo)
    }
  }
  
  // MARK: - IBActions
  @IBAction func segmentedControl(_ sender: AnyObject) {
    guard let control = sender as? UISegmentedControl else {
      return
    }
    let selectValue = control.titleForSegment(at: control.selectedSegmentIndex)
    
    let request = NSFetchRequest<Bowtie>(entityName: "Bowtie")
    request.predicate = NSPredicate(format: "searchKey = %@", selectValue!)
    
    do {
      let results = try managedObjectContext.fetch(request)
      currentBowtie = results.first
      populate(bowtie: currentBowtie)
    } catch let error as NSError {
      print(error.userInfo)
    }
  }
  
  @IBAction func wear(_ sender: AnyObject) {
    let times = currentBowtie.timesWorn
    currentBowtie.timesWorn = times + 1
    currentBowtie.lastWorn = NSDate()
    
    // Save back to coreData
    do {
      try managedObjectContext.save()
      populate(bowtie: currentBowtie)
    } catch let error as NSError {
      print(error.userInfo)
    }
  }
  
  @IBAction func rate(_ sender: AnyObject) {
    let alert = UIAlertController(title:"New Rating", message: "Rate this bow tie (0 - 5)", preferredStyle: .alert)
    alert.addTextField { (textField) in
      textField.keyboardType = .decimalPad
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
      guard let textField = alert.textFields?.first else {
        return
      }
      self.update(rating: textField.text)
    }
    
    alert.addAction(cancelAction)
    alert.addAction(saveAction)
    
    present(alert, animated: true, completion: nil)
  }
  
  private func update(rating: String?) {
    guard let ratingString = rating, let rating = Double(ratingString) else {
      return
    }
    // Note: data validation is needed in data model, so need to set range for this value
    do {
      currentBowtie.rating = rating
      try managedObjectContext.save()
      populate(bowtie: currentBowtie)
    } catch let error as NSError {
      if error.domain == NSCocoaErrorDomain && error.code == NSValidationNumberTooLargeError
        || error.code == NSValidationNumberTooSmallError {
        rate(currentBowtie)
      } else {
        print(error.userInfo)
      }
    }
  }
  
  // MARK: - Coredata function
  func insertSampleData() {
    // This will check if there are already data in CoreData
    let fetch = NSFetchRequest<Bowtie>(entityName: "Bowtie")
    fetch.predicate = NSPredicate(format: "searchKey != nil")
    let count = try! managedObjectContext.count(for: fetch)
    
    if count > 0 {
      // Which means data in .plist is already in CoreData
      return
    }
    
    let path = Bundle.main.path(forResource: "SampleData", ofType: "plist")
    let dataArray = NSArray(contentsOfFile: path!)!
    
    for dict in dataArray {
      let entity = NSEntityDescription.entity(forEntityName: "Bowtie", in: managedObjectContext)!
      let bowtie = Bowtie(entity: entity, insertInto: managedObjectContext)
      let bowtieDict = dict as! [String: Any]
      
      bowtie.name = bowtieDict["name"] as? String
      bowtie.searchKey = bowtieDict["searchKey"] as? String
      bowtie.rating = bowtieDict["rating"] as! Double
      
      let colorDict = bowtieDict["tintColor"] as! [String: Any]
      bowtie.tintColor = UIColor.color(dict: colorDict)
      
      // Store photo data
      let imageName = bowtieDict["imageName"] as? String
      let image = UIImage(named: imageName!)
      let photoData = UIImagePNGRepresentation(image!)!
      bowtie.photoData = NSData(data: photoData)
      
      bowtie.lastWorn = bowtieDict["lastWorn"] as? NSDate
      let timesWorn = bowtieDict["timesWorn"] as! NSNumber
      bowtie.timesWorn = timesWorn.int32Value
      bowtie.isFavorite = bowtieDict["isFavorite"] as! Bool
    }
    
    try! managedObjectContext.save()
  }
  
  private func populate(bowtie: Bowtie) {
    guard let imageData = bowtie.photoData as? Data, let lastWorn = bowtie.lastWorn as? Date, let tintColor = bowtie.tintColor as? UIColor else {
        return
    }
    
    imageView.image = UIImage(data: imageData)
    nameLabel.text = bowtie.name
    ratingLabel.text = "Rating: \(bowtie.rating)/5"
    timesWornLabel.text = "# times worn: \(bowtie.timesWorn)"
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .none
    
    lastWornLabel.text = "Last worn: " + dateFormatter.string(from: lastWorn)
    favoriteLabel.isHidden = !bowtie.isFavorite
    view.tintColor = tintColor
  }
}

private extension UIColor {
  static func color(dict: [String: Any]) -> UIColor? {
    guard let r = dict["red"] as? NSNumber,
      let g = dict["green"] as? NSNumber,
      let b = dict["blue"] as? NSNumber else {
      return nil
    }
    return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1.0)
    
  }
}
