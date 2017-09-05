//
//  ViewController.swift
//  HitList
//
//  Created by Hoang Nguyen on 9/4/17.
//  Copyright © 2017 Hoang Nguyen. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    var people: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "The List" //Creates navigation bar title
    
        //Registers tableView with this viewController
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

    }

    @IBAction func addName(_ sender: UIBarButtonItem) { //Add a name to the list
        
        let alert = UIAlertController(title: "New Name", message: "Add a new name", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in
            
            guard let textField = alert.textFields?.first,
                let nameToSave = textField.text else {
                    return
            }
            
            self.save(name: nameToSave)
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true) 
    }
    
    func save(name: String) { //Saves to disc
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        //Create scratch pad or managed object context to work with managed objects
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Create managed object and insert it into the managed object context
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext)!
        
        let person = NSManagedObject(entity: entity, insertInto: managedContext)
        
        //Set name attribute using key-value coding
        person.setValue(name, forKeyPath: "name")
        
        /* Commit changes to person and save to disk by calling save, insert new managed object into people array  */
        do {
            try managedContext.save()
            people.append(person)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /* Create managed object context, pull application delegate and grab a reference to its persistent container */
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Fetches from Core Data all objects from the Entity Person
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        
        //Hand the fetch request over to the managed object context to do heavy lifting 
        do {
            people = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo) ")
        }
        
    }

}

//Table View Extension

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let person = people[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = person.value(forKeyPath: "name") as? String
        return cell
    }
    
}

