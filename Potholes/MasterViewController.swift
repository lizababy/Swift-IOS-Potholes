//
//  MasterViewController.swift
//  Potholes
//
//  Created by Liza Linto on 11/3/15.
//  Copyright © 2015 sdsu. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var potholes = [PotHole]()
    var types = [Type]()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        
        //network call in background thread and load list items
        /*for var i = 0 ; i < types.count ; i++ {
            
            let newType = Type(typeId : i, description : "category \(i)")
            types.insert(newType, atIndex: i)
        }*/
        var newType = Type(typeId : 0, description : "category \(0) Water")
        types.insert(newType, atIndex: 0)
        newType = Type(typeId : 1, description : "category \(1) Street")
        types.insert(newType, atIndex: 1)


    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {
        //potholes.insert(NSDate(), atIndex: 0)
        let newPortHole = PotHole(type: Type(typeId: 0,description: "water"), id: 0, latitude: 93.2, longitude: 94.2, imageType: ".png", description: "leak", date: NSDate(), user: "086")
        potholes.insert(newPortHole, atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: newPortHole.type.typeId)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                //let object = portholes[indexPath.row] as! NSDate
                let currentPotHole = potholes[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                //controller.detailItem = object
                controller.potHoleDetailItem = currentPotHole
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return types.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return potholes.filter{$0.type.typeId == section }.count
        
        
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let object = potholes[indexPath.row]
        cell.textLabel!.text = object.description
        cell.detailTextLabel?.text = object.date.description
        return cell
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return types[section].description
    }


    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            potholes.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

