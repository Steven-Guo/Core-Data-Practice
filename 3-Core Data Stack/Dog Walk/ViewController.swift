/**
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
  
  // MARK: - CoreData
  var managedContext: NSManagedObjectContext!
  
  // MARK: - Properties
  lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
  }()
  var walks: [NSDate] = []
  var currentDog: Dog?

  // MARK: - IBOutlets
  @IBOutlet var tableView: UITableView!

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
  
    // CoreData
    let dogName = "Fido"
    let dogFetch: NSFetchRequest<Dog> = Dog.fetchRequest()
    dogFetch.predicate = NSPredicate(format: "%K == %@", #keyPath(Dog.name), dogName)
    
    do {
      let results = try managedContext.fetch(dogFetch)
      if results.count > 0 {
        // If Fido is found, use it
        currentDog = results.first
      } else {
        // If Fido is not found, create a new one
        currentDog = Dog(context: managedContext)
        currentDog?.name = dogName
        try managedContext.save()
      }
    } catch let error as NSError {
      print(error.userInfo)
    }
  }
}

// MARK: - IBActions
extension ViewController {

  @IBAction func add(_ sender: UIBarButtonItem) {
//    walks.append(NSDate())
    
    // Insert a new Walk Entity into CoreData
    let walk = Walk(context: managedContext)
    walk.date = NSDate()
    
    // Insert new walk into current dogs's walk set
//    if let dog = currentDog, let walks = dog.walks?.mutableCopy() as? NSMutableOrderedSet {
//      walks.add(walk)
//      dog.walks = walks
//    }
    currentDog?.addToWalks(walk) // Note: this line is the simplified version of above, thanks to CoreData
    
    // Save to core data
    do {
      try managedContext.save()
    } catch let error as NSError {
      print("Save error, \(error), \n")
      print(error.userInfo)
    }
    
    tableView.reloadData()
  }
}

// MARK: UITableViewDataSource
extension ViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let walks = currentDog?.walks else {
      return 1
    }
    return walks.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    let date = walks[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    guard let walk = currentDog?.walks?[indexPath.row] as? Walk, let walkDate = walk.date as? Date else {
      return cell
    }
    cell.textLabel?.text = dateFormatter.string(from: walkDate)
    return cell
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "List of Walks"
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    guard let walkToRemove = currentDog?.walks?[indexPath.row] as? Walk, editingStyle == .delete else {
      return
    }
    
    managedContext.delete(walkToRemove)
    
    do {
      try managedContext.save()
      tableView.deleteRows(at: [indexPath], with: .automatic)
    } catch let error as NSError {
      print("Error happened when delete row from core data, \(error)")
      print(error.userInfo)
    }
  }
}
