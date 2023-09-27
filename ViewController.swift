//
//  ViewController.swift
//  GroupApp
//
//  Created by KELSEY COLLINS on 2/9/23.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var restorantInputOutlet: UITextField!
    @IBOutlet weak var mapOutlet: MKMapView!
    var locationManager = CLLocationManager()
    var current : CLLocation!
    
    var restorant : [MKMapItem] = []
    var nearbyRestaurants: [restaurant] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
                
        mapOutlet.showsUserLocation = false
        mapOutlet.delegate = self
        
        
    }
    
    // Centers the map on the user's location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Current location of the user
        let center = locationManager.location!.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: center, span: span)
        mapOutlet.setRegion(region, animated: true)
    }
    
    // Gets called when the info button is clicked on a pin
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMenu" {
            let controller = segue.destination as! PickerViewController
            
            // Waits to get the menu of the selected restaurant, then tells the PickerViewController that the menu has loaded
            Task{
                do{
                    order = [:]
                    tempMenu = try await getMenu(latestId)
                    controller.menuLoaded()
                } catch{
                    print(error)
                }
            }
        }
    }
    
    // Defines what annotations should look like
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Restuarant"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            do{
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                let id = nearbyRestaurants[Int(annotation.subtitle!!)!].brand_id
                let url = URL(string: try getBrandInfo(id).logo!)
                let data =  try? Data(contentsOf: url!)
                
                let pinImage = UIImage(data: data!)
                let size = CGSize(width: 50, height: 50)
                UIGraphicsBeginImageContext(size)
                pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                
                annotationView?.image = resizedImage
                
                
                
                
                
                
                
                // Adds a button to the popup that calls the restaurantClicked fucntion
                let btn = UIButton(type: .detailDisclosure)
                annotationView?.rightCalloutAccessoryView = btn
                btn.tag = Int(annotation.subtitle!!)!
                btn.addTarget(self, action: #selector(restaurantClicked), for: .touchDown)
            } catch{
                print(error)
            }
            
        } else {
            annotationView?.annotation = annotation
        }


        
        
        return annotationView
    }
    
    

    
    
    
    var latestId = "" // Stores the last restaurant that was selected
    @objc func restaurantClicked(_ button: UIButton) {
        latestId = nearbyRestaurants[button.tag].brand_id
        self.performSegue(withIdentifier: "showMenu", sender: self)
        
    }
    
    //search Restorant
    @IBAction func rearchAction(_ sender: UIBarButtonItem) {
        let allAnnotations = self.mapOutlet.annotations
        self.mapOutlet.removeAnnotations(allAnnotations)
        let coordinates = locationManager.location!.coordinate
        Task{
            do{
                let nearby = try await getRestaurant(coordinates.latitude, coordinates.longitude,1000,25)
                nearbyRestaurants = nearby
                for (index, item) in nearby.enumerated() {
                    let location = CLLocation(latitude: item.lat,longitude: item.lng)
                    let newPin = MKPointAnnotation()
                    let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                    
                    mapOutlet.setRegion(region, animated: true)
                    // search item and it will pin that item
                    if restorantInputOutlet.text == item.name || restorantInputOutlet.text == ""{
                        newPin.coordinate = location.coordinate
                        newPin.title = item.name
                        newPin.subtitle = String(index)
                        mapOutlet.addAnnotation(newPin)
                    }
                }
            }
            catch{
                print(error)
            }
        }
    }
}



