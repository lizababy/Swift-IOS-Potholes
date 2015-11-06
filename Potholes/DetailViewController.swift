//
//  DetailViewController.swift
//  Potholes
//
//  Created by Liza Linto on 11/3/15.
//  Copyright © 2015 sdsu. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var latitudeLabel: UILabel!
    
    @IBOutlet weak var longitudeLabel: UILabel!
    
    @IBOutlet weak var potHoleImage: UIImageView!
    
    @IBOutlet weak var userLabel: UILabel!
    
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
            if let label = self.userLabel {
                label.text = potHoleDetails.user
            }
            if let label = self.descriptionLabel {
                label.text = potHoleDetails.description
            }
            if let label = self.latitudeLabel {
                label.text = potHoleDetails.latitude.description
            }
            if let label = self.longitudeLabel {
                label.text = potHoleDetails.longitude.description
            }
            
            
            
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

