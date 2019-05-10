//
//  DirectionsViewController.swift
//  GoogleDirectionDemo
//
//  Created by LogicalWings Mac on 30/10/18.
//  Copyright © 2018 LogicalWings Mac. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import GooglePlacePicker

import MapKit

class DirectionsViewController: UIViewController {

    @IBOutlet weak var txtFrom: UITextField!
    @IBOutlet weak var txtTo: UITextField!
    var sender = UITextField()
    var fromCoordinate : CLLocationCoordinate2D?
    var toCoordinate : CLLocationCoordinate2D?
    
    //@IBOutlet weak var mapview: GMSMapView!
    
    @IBOutlet weak var mapview: MKMapView!
    @IBOutlet weak var viewDetails: UIView!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblSpeed: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var viewDetailBottom: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapview.delegate = self
        mapview.showsScale = true
        mapview.showsPointsOfInterest = true
        mapview.showsUserLocation = true

        // Do any additional setup after loading the view.
    }
    
    @IBAction func txtFromEditing(_ sender: UITextField) {
        
        self.sender = txtFrom
        showGoogleMapsAutoCompleteViewController()
        
    }
    @IBAction func txtToEditing(_ sender: UITextField) {
        self.sender = txtTo
        showGoogleMapsAutoCompleteViewController()
    }
    
    func showGoogleMapsAutoCompleteViewController(){
    
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    @IBAction func btnGetDirections(_ sender: UIButton) {
        
        if fromCoordinate != nil && toCoordinate != nil{
            
            //getPolylineRoute(from: fromCoordinate!, to: toCoordinate!)
            
            drawDirection(from: fromCoordinate!, to: toCoordinate!)
            
        }else{
            print("select to and from places")
        }
    }
    
    
    func drawDirection(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D)
    {
     
        let locationFrom = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let locationTo = CLLocation(latitude: to.latitude, longitude: to.longitude)
        
        let distancemeters = locationFrom.distance(from: locationTo)
        
        print(distancemeters)
        
        if viewDetailBottom.constant == 66{
            
            lblDistance.text = "\(String(format: "%.0f km", distancemeters/1000))"
            
            UIView.animate(withDuration: 10) {
                self.viewDetailBottom.constant = 0
            }
            
            self.view.bringSubviewToFront(viewDetails)
        }
        
        let sourcePlacmark = MKPlacemark(coordinate: from)
        let destPlacemark = MKPlacemark(coordinate: to)
     
        let sourceItem = MKMapItem(placemark: sourcePlacmark)
        let destItem = MKMapItem(placemark: destPlacemark)
     
        let request = MKDirections.Request()
        request.source = sourceItem
        request.destination = destItem
        request.transportType = .walking

        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            
            print(response)
            print(response?.routes)
            
            guard let unwrappedResponse = response else { return }
            
            print(unwrappedResponse.routes)
            
            for route in unwrappedResponse.routes {
                self.mapview.addOverlay(route.polyline)
                self.mapview.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
        
    }
 
    @IBAction func btnClose(_ sender: UIButton) {
    
        if viewDetailBottom.constant == 0{
            
            UIView.animate(withDuration: 10) {
                self.viewDetailBottom.constant = 66
            }
        }
    }
    
    
    /*
    
    // Map PolyLine Code
    
    func getPolylineRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D){
     
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
     
        //let origin = "\(source.latitude),\(source.longitude)"
        //let destination = "\(destination.latitude),\(destination.longitude)"
     
        //let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=true&mode=driving&key=AIzaSyDTZcaR9z4rceO7c9QRk1nNBf1Y2jE7eo8")!
     
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?key=AIzaSyDTZcaR9z4rceO7c9QRk1nNBf1Y2jE7eo8&origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=true&mode=driving")!
     
        print(url)
     
        //let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyDTZcaR9z4rceO7c9QRk1nNBf1Y2jE7eo8"
     
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
                //self.activityIndicator.stopAnimating()
            }
            else {
                do {
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]{
     
                        guard let routes = json["routes"] as? NSArray else {
                            DispatchQueue.main.async {
                                //self.activityIndicator.stopAnimating()
                            }
                            return
                        }
     
                        print(routes)
     
                        if (routes.count > 0) {
                            let overview_polyline = routes[0] as? NSDictionary
                            let dictPolyline = overview_polyline?["overview_polyline"] as? NSDictionary
     
                            let points = dictPolyline?.object(forKey: "points") as? String
     
                            self.showPath(polyStr: points!)
     
                            DispatchQueue.main.async {
                                //self.activityIndicator.stopAnimating()
     
                                let bounds = GMSCoordinateBounds(coordinate: source, coordinate: destination)
                                let update = GMSCameraUpdate.fit(bounds, with: UIEdgeInsets(top: 170, left: 30, bottom: 30, right: 30))
                                self.mapview!.moveCamera(update)
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                //self.activityIndicator.stopAnimating()
                                }
                        }
                    }
                }
                catch {
                    print("error in JSONSerialization")
                    DispatchQueue.main.async {
                        //self.activityIndicator.stopAnimating()
                    }
                }
            }
        })
        task.resume()
    }
    
    func showPath(polyStr :String){
        let path = GMSPath(fromEncodedPath: polyStr)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 3.0
        polyline.strokeColor = UIColor.red
        polyline.map = mapview // Your map view
    }
    */
    
    
}

extension DirectionsViewController:GMSAutocompleteViewControllerDelegate{
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        print(place.name)
        print(place.coordinate.latitude)
        print(place.coordinate.longitude)
        print(place.coordinate)
        
        if sender == txtFrom{
            txtFrom.text = place.name
            fromCoordinate = place.coordinate
        }else{
            txtTo.text = place.name
            toCoordinate = place.coordinate
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        
        print(error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension DirectionsViewController:MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor.blue
        //polylineRenderer.fillColor = UIColor.red
        polylineRenderer.lineWidth = 2
        return polylineRenderer
 
    }
}
