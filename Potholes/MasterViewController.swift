//
//  MasterViewController.swift
//  Potholes
//
//  Created by Liza Linto on 11/3/15.
//  Copyright © 2015 sdsu. All rights reserved.
//

import UIKit
import Alamofire

class MasterViewController: UIViewController,UITableViewDelegate {

    var detailViewController: DetailViewController? = nil
    var potholesDict = [String : [PotHole]]()
    var types = [String]()
    var date :String = ""
    var user : String = ""
    var count : Int = 0
    
    @IBOutlet weak var waitIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.navigationItem.prompt = "Reports from All users"
        self.tabBarController?.navigationItem.titleView?.tintColor = UIColor.greenColor()

        
        let barButtonItemAdd = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "postNewItem:")
        self.tabBarController?.navigationItem.leftBarButtonItem = barButtonItemAdd
        
        let barButtonItemRefresh = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshTable:")
        let buttonFilter: UIButton = UIButton(type: UIButtonType.InfoDark) as UIButton
        buttonFilter.frame = CGRectMake(0, 0, 40, 40)
        buttonFilter.setImage(UIImage(named:"Filter"), forState: UIControlState.Normal)
        buttonFilter.addTarget(self, action: "textEntryAlert:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let barButtonItemFilter: UIBarButtonItem = UIBarButtonItem(customView: buttonFilter)
        self.tabBarController?.navigationItem.rightBarButtonItems = [barButtonItemFilter, barButtonItemRefresh]
        
        

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }

        //network call in background thread and load list items
        
        refreshTable(self)
        
    }
    func postNewItem(sender: AnyObject) {
        performSegueWithIdentifier("postDetail", sender: sender)
    }
    func textEntryAlert(sender : AnyObject){
        
        let title = NSLocalizedString("Filter Options:", comment: "")
        let message = NSLocalizedString("Enter userName and/or from Date or all", comment: "")
        let cancelButtonTitle = NSLocalizedString("Cancel", comment: "")
        let okButtonTitle = NSLocalizedString("Search", comment: "")
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // Add the text field for text entry.
        alertController.addTextFieldWithConfigurationHandler { textField -> Void in
            
            textField.placeholder = "Enter UserName"
            textField.text = self.user
            textField.keyboardType = .NumbersAndPunctuation
            
        }
        
        alertController.addTextFieldWithConfigurationHandler { textField -> Void in

            textField.placeholder = "Enter from Date (mm/dd/yy)"
            textField.text = self.date
            textField.keyboardType = .NumbersAndPunctuation
            
        }
        
        
        // Create the actions.
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel, handler : nil)
        let okAction = UIAlertAction(title: okButtonTitle, style: .Default) { _ in
            
            if let dateField = alertController.textFields?[1] ,
                let nameField = alertController.textFields?[0]{
                
                self.date = dateField.text!
                self.user = nameField.text!
                self.tabBarController?.navigationItem.prompt = self.user.isEmpty ? "Reports From All Users" : "Report from user \(self.user)"
                if (!self.date.isEmpty){
                    self.tabBarController?.navigationItem.prompt = "\(self.navigationItem.prompt!) from \(self.date)"
                }
                self.refreshTable(sender)
            }

        }
        // Add the actions.
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        presentViewController(alertController, animated: true, completion: nil)

        
    }
    func refreshTable(sender: AnyObject){
        
        self.waitIndicator.startAnimating()
        potholesDict = [:]
        fetchPotholes()
    }
    func fetchPotholes(){
        
        let url = "http://bismarck.sdsu.edu/city/categories"
        
        Alamofire.request(.GET, url).responseJSON {response in
            if response.result.isSuccess{
                let categoryArray:NSArray = response.result.value as! NSArray
                self.types = (categoryArray as! [String]).sort(){$0 < $1}
                for type in self.types{
                    self.fetchPotholesFromeDate(type)
                }
            }
        }
    }
    func fetchPotholesFromeDate(type : String){
        
        let url = "http://bismarck.sdsu.edu/city/fromDate"
        let parameters = ["type": type, "date" : date, "user" : user]
        
        Alamofire.request(.GET, url, parameters: parameters)
            .responseJSON {response in
            if response.result.isSuccess {
                let jsonArray:NSArray = response.result.value as! NSArray
                self.definePotHoles(jsonArray, type: type)
                self.performSelectorOnMainThread("updateOnMainThread:", withObject: type, waitUntilDone: false)
            }
        }
    }
    func updateOnMainThread(type : String){
        
        count++
        tableView.reloadData()
        if count == types.count{
            count = 0
            waitIndicator.stopAnimating()
        }
    }
    
    func definePotHoles(jsonNSArray : NSArray, type :String){
        var potholes = [PotHole]()
        for jsonDictionary in jsonNSArray.reverse(){
            
            let potHole = PotHole(type: jsonDictionary["type"] as? String ,
                id: jsonDictionary["id"] as? Int,
                latitude: jsonDictionary["latitude"] as? Double,
                longitude: jsonDictionary["longitude"] as? Double,
                imageType: jsonDictionary["imagetype"] as? String ,
                description: jsonDictionary["description"] as? String,
                date: jsonDictionary["created"] as? String,
                user: nil,
                image : nil)
            potholes.insert(potHole, atIndex: 0)
            
        }
        self.potholesDict[type] = potholes
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = "PotHoles List"
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
                
                let currentPotHole = potholesDict[types[indexPath.section]]![indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController

                controller.potHoleDetailItem = currentPotHole
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
        if segue.identifier == "postDetail"{
           
           let controller = (segue.destinationViewController as! UINavigationController).topViewController as! PostDetailsViewController
            controller.navigationItem.leftItemsSupplementBackButton = true

        }
        
    }

    // MARK: - Table View

     func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return types.count
    }

     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let potholeDict = potholesDict[types[section]] else{
            
            return 0
        }
        return potholeDict.count
    }

     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let pothole = potholesDict[types[indexPath.section]]![indexPath.row]
        cell.textLabel!.text = pothole.date
        cell.detailTextLabel?.text = pothole.description
        if pothole.imageType == "none"{
            cell.imageView?.image = UIImage(named: "NoImage-1")
            
        }else{
            cell.imageView?.image = UIImage(named: "ImageIcon")
        }
        
        return cell
    }
     func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return types[section]
    }
    @IBAction func returnFromPost(segue:UIStoryboardSegue) {

        self.refreshTable(self)
    }
    
    @IBAction func returnFromCancel(segue:UIStoryboardSegue) {
        //No operation to do as user cancelled previous view
       
    }
    

}

