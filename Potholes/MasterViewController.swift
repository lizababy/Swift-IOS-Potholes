//
//  MasterViewController.swift
//  Potholes
//
//  Created by Liza Linto on 11/3/15.
//  Copyright © 2015 sdsu. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController,UITableViewDelegate {

    var detailViewController: DetailViewController? = nil
    var potholes = [PotHole]()
    var types = [String]()
    var urlId = 0
    var date :String = ""
    var user : String = ""

    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var userLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBAction func showTextEntryAlert(sender: UIButton) {
        
        textEntryAlert(sender)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userLabel.text = user.isEmpty ? "All" : user
        dateLabel.text = date.isEmpty ? "All" : date

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
        performSegueWithIdentifier("postDetail", sender: sender)
        
        /*let newPortHole = PotHole(type: "street", id: 0, latitude: 93.2, longitsenderude: 94.2, imageType: ".png", description: "leak", date: NSDate().description, user: "086")
        potholes.insert(newPortHole, atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: types.indexOf(newPortHole.type)!)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)*/


    }
    func textEntryAlert(sender : AnyObject){
        
        let title = NSLocalizedString("Filter Options:", comment: "")
        let message = NSLocalizedString("Enter userName and/or from Date or all", comment: "")
        let cancelButtonTitle = NSLocalizedString("Cancel", comment: "")
        let okButtonTitle = NSLocalizedString("Search", comment: "")
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // Add the text field for text entry.
        alertController.addTextFieldWithConfigurationHandler { textField -> Void in
            // If you need to customize the text field, you can do so here.
             textField.placeholder = "Enter UserName"
             textField.text = self.user
            textField.keyboardType = .NumbersAndPunctuation

            
        }
        alertController.addTextFieldWithConfigurationHandler { textField -> Void in
            // If you need to customize the text field, you can do so here.
            textField.placeholder = "Enter from Date (mm/dd/yy)"
            textField.text = self.date
            textField.keyboardType = .NumbersAndPunctuation

        }
        
        
        // Create the actions.
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel) { _ in
            NSLog("The \"Text Entry\" alert's cancel action occured.")
        }
        
        let okAction = UIAlertAction(title: okButtonTitle, style: .Default) { _ in
            if let dateField = alertController.textFields?[1] , let nameField = alertController.textFields?[0]{
                guard dateField.text!.isEmpty && nameField.text!.isEmpty else{
                    
                    self.date = dateField.text!
                    self.user = nameField.text!
                    self.dateLabel.text = self.date.isEmpty ? "All" : self.date
                    self.userLabel.text = self.user.isEmpty ? "All" : self.user
                    
                    self.refresh(sender)

                    return
                    
                }
                return
            }

        }
        // Add the actions.
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        presentViewController(alertController, animated: true, completion: nil)

        
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
                    
                    if let url = NSURL(string: "http://bismarck.sdsu.edu/city/fromDate?type=\(type)&date=\(date)&user=\(user)") {
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
        if segue.identifier == "postDetail"{
           
           let controller = (segue.destinationViewController as! UINavigationController).topViewController as! PostDetailsViewController
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true

        }
        
    }

    // MARK: - Table View

     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return types.count
    }

     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return potholes.filter{$0.type == types[section]}.count
        
        
    }

     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            
            let object = potholes.filter{$0.type == types[indexPath.section]}[indexPath.row]
            cell.textLabel!.text = object.date
            cell.detailTextLabel?.text = object.description
            return cell
    }
     func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
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

