//
//  ViewController.swift
//  MapBook
//
//  Created by user201040 on 8/25/21.
//

import UIKit
import MapKit
import CoreLocation
import CoreData
class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var commentText: UITextField!
    
    var chosenLatitude = Double()
    var chosenLongitude = Double()
    
    var chosenID : UUID?
    
    @IBOutlet weak var mapView: MKMapView!
    //pronalazenje lokacije korisnika
    var locationManager = CLLocationManager()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self
        locationManager.delegate = self
        //preciznost lokacije
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //trazenje dozvole
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //provera da li je izabrano nesto pri slanju
        if chosenID?.uuidString != "" {
            nameText.text = chosenID?.uuidString
            //napisati fetch za izabrani titleId 
            
        }
        
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(choseLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(gestureRecognizer)
        
        //hide keyboard
        let gestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer2)
        
        
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @objc func choseLocation(gestureRecognizer : UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            
            let touchPoint = gestureRecognizer.location(in: self.mapView)
            let touchedCoordinates = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            
            chosenLatitude = touchedCoordinates.latitude
            chosenLongitude = touchedCoordinates.longitude
            
            let anotation = MKPointAnnotation()
            anotation.coordinate = touchedCoordinates
            anotation.title = nameText.text
            anotation.subtitle = commentText.text
            self.mapView.addAnnotation(anotation)
            
        }
    
    }
    
    
    //didupdate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let region = MKCoordinateRegion(center: location, span: span)
        
        mapView.setRegion(region, animated: true)
        
    }
    
    
    @IBAction func saveClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        
        
        newPlace.setValue(UUID(), forKey: "id")
        newPlace.setValue(nameText.text , forKey: "title")
        newPlace.setValue(commentText.text , forKey: "subtitle")
        
        newPlace.setValue(chosenLongitude, forKey: "longitude")
        newPlace.setValue(chosenLatitude, forKey: "latitude")
        
        
        do {
            try context.save()
            print("saved")
        } catch {
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPlace"), object: nil)
        navigationController?.popViewController(animated: true)
        
    }
    

}

