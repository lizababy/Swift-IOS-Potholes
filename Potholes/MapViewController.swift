//
//  MapViewController.swift
//  Potholes
//
//  Created by Liza Linto on 11/12/15.
//  Copyright © 2015 sdsu. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Alamofire


class MapViewController: UIViewController, MKMapViewDelegate {
    
    var potholes = [PotHole]()
    
    @IBOutlet weak var potholeMap: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        potholeMap.delegate = self
        
        Alamofire.request(.GET, "http://bismarck.sdsu.edu/city/fromLocation", parameters: ["type": "street", "date" : "", "user" : "", "start-latitude" :32.7,"end-latitude" :32.8,"start-longitude" :-118,"end-longitude" :-117 ])
            .responseJSON {response in
            if response.result.isSuccess {
                let potholesArray:NSArray = response.result.value as! NSArray
                self.performSelectorOnMainThread("definePotHoles:", withObject: potholesArray, waitUntilDone: false)
            }
        }

    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.title = "Potholes Map"
    }
    func definePotHoles(jsonNSArray : NSArray){
        
        var mapRect = MKMapRectNull
        var annotationID = 0
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
            if abs(potHole.latitude!) < 90 && abs(potHole.longitude!) < 180  {
                potholes.insert(potHole, atIndex: annotationID)

                let coordinateLocation = CLLocationCoordinate2D(latitude: potHole.latitude!, longitude: potHole.longitude!)
                let mark = Place(id: annotationID ,title:"PotHole is here", subtitle:"\(potHole.latitude!)), \(potHole.longitude!) ", coordinate:coordinateLocation)
                
                potholeMap.addAnnotation(mark)
            
                
                let mapPoint = MKMapPointForCoordinate(coordinateLocation)
                mapRect = MKMapRectUnion(mapRect, MKMapRectMake(mapPoint.x,mapPoint.y,100,1000*120))
                annotationID++
            }
        }
        if !potholes.isEmpty{
            let region = MKCoordinateRegionForMapRect(mapRect)
            potholeMap.setRegion(region, animated: true)
        }
        
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        performSegueWithIdentifier("showDetail", sender: view)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "showDetail" {
                let currentPotHole = potholes[((sender!.annotation as? Place)?.id)!]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
            
                controller.potHoleDetailItem = currentPotHole
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            
        }
        
    }

}
