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
    var types = [String]()
    var urlId = 0


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
       // self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "postNewItem:")
        self.navigationItem.leftBarButtonItem = addButton
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refresh:")
        self.navigationItem.rightBarButtonItem = refreshButton
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
   
        //network call in background thread and load list items
        
        if let url = NSURL(string: "http://bismarck.sdsu.edu/city/categories") {
            
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithURL(url, completionHandler: getWebPage)
            task.resume()
            
        }
        
        
    }
    
    func postNewItem(sender: AnyObject) {
        performSegueWithIdentifier("postDetails", sender: sender)
        
        /*let newPortHole = PotHole(type: "street", id: 0, latitude: 93.2, longitsenderude: 94.2, imageType: ".png", description: "leak", date: NSDate().description, user: "086")
        potholes.insert(newPortHole, atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: types.indexOf(newPortHole.type)!)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)*/


    }
    func refresh(sender: AnyObject){
        
        potholes = [PotHole]()
        types = [String]()
        urlId = 0

        
        if let url = NSURL(string: "http://bismarck.sdsu.edu/city/categories") {
            
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithURL(url, completionHandler: getWebPage)
            task.resume()
            
        }
    }
    func getWebPage(data:NSData?, response:NSURLResponse?, error:NSError?) -> Void {
        
        var status : Int = 0
        if let httpResponse = response as? NSHTTPURLResponse{
            status = httpResponse.statusCode
            let header = httpResponse.allHeaderFields
            header["Content-Type"]
            print ("status code :\(status)")
        }
        
        guard error == nil else {
            print("error: \(error!.localizedDescription): \(error!.userInfo)")
            return
        }
        if data != nil && status == 200 {
            if let webPageContents = NSString(data: data!, encoding: NSUTF8StringEncoding) {
                print(webPageContents)
                
                do {
                    let jsonData:AnyObject = try NSJSONSerialization.JSONObjectWithData(data!,options : NSJSONReadingOptions.AllowFragments)
                    let jsonNSArray:NSArray = jsonData as! NSArray
                    performSelectorOnMainThread("reloadTable:", withObject: jsonNSArray, waitUntilDone: true)
                    
                } catch {
                    print("json serialization error")

                }
            } else {
                print("unable to convert data to text")
            }
        }
    }
    func reloadTable(jsonNSArray:NSArray){
        switch(urlId){
            case 0 :
                defineCategories(jsonNSArray)
                urlId = 1
                for type in types{
                    
                    if let url = NSURL(string: "http://bismarck.sdsu.edu/city/fromDate?type=\(type)") {
                        let session = NSURLSession.sharedSession()
                        let task = session.dataTaskWithURL(url, completionHandler: getWebPage)
                        task.resume()
                    }
               }
            case 1:
            
                fetchPotHoles(jsonNSArray)
        default:
                
                 break
        }
        
        tableView.reloadData()

    }
    func defineCategories(jsonNSArray : NSArray) {
        
        
        types = NSArray(array:jsonNSArray.sort({($0 as! String) < ($1 as! String)}), copyItems: true) as! [String]
        
    }
    func fetchPotHoles(let jsonNSArray : NSArray){
        
        for jsonDictionary in jsonNSArray.reverse(){
            
            let potHoleType = jsonDictionary["type"] as! String
            let potHole = PotHole(type: potHoleType ,
                id: jsonDictionary["id"] as! Int,
                latitude: jsonDictionary["latitude"] as! Float,
                longitude: jsonDictionary["longitude"] as! Float,
                imageType: jsonDictionary["imagetype"] as! String ,
                description: jsonDictionary["description"] as! String,
                date: jsonDictionary["created"] as! String,
                user: "notKnown")
            potholes.insert(potHole, atIndex: 0)

        }

        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                //let object = portholes[indexPath.row] as! NSDate
                let currentPotHole = potholes.filter{$0.type == types[indexPath.section] }[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                //controller.detailItem = object
                controller.potHoleDetailItem = currentPotHole
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
        if segue.identifier == "postDetails"{
           
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! PostDetailsViewController
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true

        }
        
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return types.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return potholes.filter{$0.type == types[section]}.count
        
        
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            
            let object = potholes.filter{$0.type == types[indexPath.section]}[indexPath.row]
            cell.textLabel!.text = object.date
            cell.detailTextLabel?.text = object.description
            return cell
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return types[section]
    }

/*
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            potholes.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }*/


}

