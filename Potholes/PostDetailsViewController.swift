//
//  PostDetailsViewController.swift
//  Potholes
//
//  Created by Liza Linto on 11/6/15.
//  Copyright © 2015 sdsu. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import MobileCoreServices
import Alamofire

class PostDetailsViewController: UIViewController,UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
   
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var latitudeDesc: UILabel!
    
    @IBOutlet weak var imageSelected: UIImageView!
    @IBOutlet weak var longitudeDesc: UILabel!
    @IBOutlet weak var waitIndicator: UIActivityIndicatorView!
    
    var locationManager:CLLocationManager = CLLocationManager()
    var pothole : PotHole = PotHole()
   
    @IBAction func imageSelectButton(sender: UIButton) {
        
        let libraryButtonTitle = NSLocalizedString("Pick from Library", comment: "")
        let cancelButtonTitle = NSLocalizedString("Cancel", comment: "")

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        // Create the actions.
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel, handler : nil)
         let libraryAction = UIAlertAction(title: libraryButtonTitle, style: .Default) { _ in
           self.pickMediaFromSource(UIImagePickerControllerSourceType.PhotoLibrary)
        }
        
        // Add the actions.
        
        alertController.addAction(libraryAction)
        alertController.addAction(cancelAction)
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.Camera){
            let cameraButtonTitle = NSLocalizedString("New Photo", comment: "Camera")
            
            let cameraAction = UIAlertAction(title: cameraButtonTitle, style: .Default) { _ in
                self.pickMediaFromSource(UIImagePickerControllerSourceType.Camera)
            }
            
            alertController.addAction(cameraAction)
            
        }
        
        
        
        if let ppc = alertController.popoverPresentationController {
            ppc.sourceView = sender
            ppc.sourceRect = sender.bounds
        }
       
        presentViewController(alertController, animated: true, completion: nil)

    }
    @IBAction func postToWeb(sender: AnyObject?) {
        
        if pothole.user!.isEmpty {
            editUserIdAlert(sender)
            return
        }
        waitIndicator.startAnimating()
        pothole.description = descriptionTextView.text
        let urlpost = "http://bismarck.sdsu.edu/city/report"
        var parameters :[String : AnyObject] = ["type":(pothole.type)!, "latitude":(pothole.latitude)! , "longitude" : (pothole.longitude)!, "user" : (pothole.user)!, "imagetype" : (pothole.imageType)!, "description":(pothole.description)!]
        if pothole.imageType! != "none"{
            parameters["image"] = pothole.image!
        }
       
        let postRequest = Alamofire.request(.POST, urlpost, parameters: parameters, encoding: .JSON)
        postRequest.responseJSON { response in
            guard response.result.isSuccess else {
                postRequest.responseString { response in
                    if let errorString = response.result.value {
                        
                        self.waitIndicator.stopAnimating()
                        self.showAlert("Failure!", message: errorString)
                    }
                }
                return
            }
            
            let data = response.result.value
            self.waitIndicator.stopAnimating()
            self.pothole.id = data!["id"] as? Int
            self.showAlert("Success!", message: "The report is successfully posted!")
        }
        
    }
    func showAlert(title : String, message : String){
        let alertController = UIAlertController(title: title, message: "The report is successfully posted!", preferredStyle:.Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }

    @IBAction func editUserIdAlert(sender : AnyObject?){
        
        let title = NSLocalizedString("User ID Login", comment: "")
        let message = NSLocalizedString("Please enter a user Id to register with app. This can be edited always", comment: "")
        let okButtonTitle = NSLocalizedString("Done", comment: "")
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // Add the text field for text entry.
        alertController.addTextFieldWithConfigurationHandler { textField -> Void in
            // If you need to customize the text field, you can do so here.
            textField.placeholder = "Enter UserName"
            textField.text = self.pothole.user!
            textField.keyboardType = .Default
        }
        // Create the actions.
        let okAction = UIAlertAction(title: okButtonTitle, style: .Default) { _ in
            
            if let nameField = alertController.textFields?.first{
                
                self.pothole.user = nameField.text
                self.saveUser()
            }
            
        }
        // Add the actions.
        alertController.addAction(okAction)
        
        presentViewController(alertController, animated: true, completion: nil)
        
        
    }
    func pickMediaFromSource(sourceType:UIImagePickerControllerSourceType) {
        let mediaTypes: [String]? = UIImagePickerController.availableMediaTypesForSourceType(sourceType)
        guard mediaTypes != nil && mediaTypes?.count > 0 else {
            return
        }
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let picker = UIImagePickerController()
            picker.mediaTypes = [kUTTypeImage as String]
                        picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = sourceType
            presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo editingInfo: [String : AnyObject]){
        let mediaType = editingInfo[UIImagePickerControllerMediaType] as! String
        guard mediaType == kUTTypeImage as String else {
            return
        }
        if let image = editingInfo[UIImagePickerControllerEditedImage] as? UIImage {
            
            imageSelected.image = image
            let imageData = UIImageJPEGRepresentation(image, 0.0)
            // Encode the image
            let base64Image:String = imageData!.base64EncodedStringWithOptions(
                NSDataBase64EncodingOptions.EncodingEndLineWithLineFeed)
            pothole.imageType = "jpeg"
            pothole.image = base64Image
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion:nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
                    
        // Do any additional setup after loading the view.
        
        descriptionTextView.delegate = self
        
        //Restore the saved User ID
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        pothole.user = userDefaults.stringForKey("user") ?? ""
        if pothole.user!.isEmpty {
            
            editUserIdAlert(self)
        }
        pothole.type = "street"
        pothole.imageType = "none"
        pothole.latitude = 0.0
        pothole.longitude = 0.0
        pothole.imageType = "none"
    
        imageSelected.image = UIImage(named: "SelectImage")
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
    }
    func saveUser(){
            
        /*Save the user Id */
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(pothole.user!, forKey: "user")
    }
    func displayLocationInfo(placemark: CLPlacemark) {
        // if placemark != nil {
        //stop updating location to save battery life
        let locality = placemark.locality ?? ""
        let postalCode = placemark.postalCode ?? ""
        let administrativeArea = placemark.administrativeArea ?? ""
        let country = placemark.country ?? ""
        descriptionTextView.text = locality + ", "  + postalCode + ", " + administrativeArea + ", " + country
        // }
    }

    

    //Requesting permission for using Location Services
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
            switch status {
            
                case .Authorized,
                     .AuthorizedWhenInUse:
                    locationManager.startUpdatingLocation()
            
                default:
                    locationManager.stopUpdatingLocation()
            }
    }
    // Getting Location
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
                
                let latitude = location.coordinate.latitude
                let longitude = location.coordinate.longitude
        
                pothole.latitude = latitude
                pothole.longitude = longitude

                latitudeDesc.text = String(format: "%g\u{00B0}", latitude)
                longitudeDesc.text = String(format: "%g\u{00B0}", longitude)
                let horizontalAccuracy = location.horizontalAccuracy

                let potHoleLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
            let mark = Place(id: 0 , title:"PotHole is here", subtitle:"\(latitude)), \(longitude) ", coordinate:potHoleLocation)
                mapView.addAnnotation(mark)
        
                let region = MKCoordinateRegionMakeWithDistance(potHoleLocation, 100, 100)
        
                mapView.setRegion(region, animated: true)
            
                CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
                    if (error != nil) {
                        print("Reverse geocoder failed with error" + error!.localizedDescription)
                        return
                    }
                    
                    if placemarks!.count > 0 {
                        let pm = placemarks![0] as CLPlacemark
                        self.displayLocationInfo(pm)
                    } else {
                        print("Problem with the data received from geocoder")
                    }
                })
        
                if horizontalAccuracy < 40 {
                
                    locationManager.stopUpdatingLocation()
                }
            
        }
    }
    //Handle location services Error
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        //Handle error here
    }
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
