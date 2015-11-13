//
//  DetailViewController.swift
//  Potholes
//
//  Created by Liza Linto on 11/3/15.
//  Copyright © 2015 sdsu. All rights reserved.
//

import UIKit
import MapKit
import Alamofire

class DetailViewController: UIViewController {
    
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var descTextView: UITextView!
    
    @IBOutlet weak var latitudeLabel: UILabel!
    
    @IBOutlet weak var longitudeLabel: UILabel!
    
    @IBOutlet weak var potHoleImage: UIImageView!
    
    @IBOutlet weak var potHoleMap: MKMapView!
    
    
    @IBOutlet weak var imageWaitIndicator: UIActivityIndicatorView!
    
    var potHoleDetailItem: PotHole? {
        
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        
        // Update the user interface for the detail item.
        if let potHoleDetails = self.potHoleDetailItem {
            
           if let label = self.typeLabel {
                label.text = potHoleDetails.type
            }
            if let label = self.dateLabel {
                label.text = potHoleDetails.date
            }
           
            if let descTextView = self.descTextView {
                descTextView.text = potHoleDetails.description
            }
            let latitude = String(format: "%g\u{00B0}", potHoleDetails.latitude!)
            let longitude = String(format: "%g\u{00B0}", potHoleDetails.longitude!)
            if let label = self.latitudeLabel {
                label.text = latitude
            }
            if let label = self.longitudeLabel {
                label.text = longitude
            }
            if let potHoleImage = self.potHoleImage {
                
                if potHoleDetails.imageType == "none"{

                    potHoleImage.image = UIImage(named: "NoImage")
                    imageWaitIndicator.stopAnimating()

                }else{
                   // fetch image
                    requestImage(potHoleDetails.id!)
                    
                }
            }
            
            let potHoleLocation = CLLocationCoordinate2D(latitude: potHoleDetails.latitude!, longitude: potHoleDetails.longitude!)
            
            
            let mark = Place(id: 0, title:"PotHole is here", subtitle:"\(latitude)), \(longitude) ", coordinate:potHoleLocation)
            if let potHoleMap = self.potHoleMap{
                
                potHoleMap.addAnnotation(mark)
                
                let region = MKCoordinateRegionMakeWithDistance(potHoleLocation, 100, 100)
                
                if abs(potHoleDetails.latitude!) < 90 && abs(potHoleDetails.longitude!) < 180  {
                    potHoleMap.setRegion(region, animated: true)
                }
            }
            
        }
    }
    func requestImage(imageID:Int) {
        
        Alamofire.request(.GET, "http://bismarck.sdsu.edu/city/image", parameters: ["id": imageID])
            .responseData { response in
                
                if let imageData = response.result.value {
                    if let image = UIImage.init(data: imageData ){
                        self.setImage(image)
                    }
                }
        }
        
    }
   
    
    func setImage(image: NSObject) {
        if let potHoleImage = self.potHoleImage{
            let realImage = image as! UIImage
            potHoleImage.image = realImage
            imageWaitIndicator.stopAnimating()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

