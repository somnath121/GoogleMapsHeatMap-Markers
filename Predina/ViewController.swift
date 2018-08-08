//
//  ViewController.swift
//  Predina
//
//  Created by SOMNATH CHATTERJEE on 03/08/18.
//  Copyright © 2018 SOMNATH CHATTERJEE. All rights reserved.
//

import UIKit
import GoogleMaps

private var heatmapLayer: GMUHeatmapTileLayer!
private var gradientColors = [UIColor.green, UIColor.red]
private var gradientStartPoints = [0.2, 1.0]
weak var timer: Timer?
var markers = [GMSMarker]()
var i = 0
var mapView = GMSMapView()
class ViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        heatmapLayer = GMUHeatmapTileLayer.init()
        
        // Create a GMSCameraPosition that tells the map to render at a specific coordinate
        let camera = GMSCameraPosition.camera(withLatitude: 54.00366, longitude: -2.547855, zoom: 5.7)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
       // mapView.setMinZoom(5.7, maxZoom: 10)
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        view = mapView
        addHeatmap()
        
        loadRealTimeLocations(timeOfLocation: "05:00")
        startTimer()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func addHeatmap()  {
        var list = [GMUWeightedLatLng]()
        do {
            // Get the data: latitude/longitude positions of occurences.
            if let path = Bundle.main.url(forResource: "Coordinates", withExtension: "json") {
                let data = try Data(contentsOf: path)
                let json = try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.allowFragments]) as! [String:Any]
                
                if let object = json["results"] as? [[String: Any]] {
                    for item in object {
                        if let lat = item["Latitude"] as? Double.FloatLiteralType, let lng = item["Longitude"] as? Double.FloatLiteralType{
                        let coords = GMUWeightedLatLng(coordinate: CLLocationCoordinate2DMake(lat , lng ), intensity: 1.0)
                        list.append(coords)
                        }
                    }
                } else {
                    print("Could not read the JSON.")
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        // Add the latlngs to the heatmap layer.
        heatmapLayer.weightedData = list
        // Create the gradient.
        heatmapLayer.gradient = GMUGradient(colors: gradientColors,
                                            startPoints: gradientStartPoints as [NSNumber],
                                            colorMapSize: 256)
        heatmapLayer.radius = 50;
        heatmapLayer.map = mapView
}
    
    func addAnnotations(locationData:[[String:Any]]) {
        print("locationData: \(locationData)")
        var vehicles = [Vehicle]()
        for vehicle in locationData {
            let vehicleObj = Vehicle(vehicle_name: vehicle["Vehicle"] as! String, lng: (vehicle["Longitude"] as? Double.FloatLiteralType)!, lat: (vehicle["Latitude"] as? Double.FloatLiteralType)!)
            vehicles.append(vehicleObj)
        }
        print("vehicles: \(vehicles)")
        var j = 0;
        for locs in vehicles {
            
            
            if(markers.count != vehicles.count){
                
                let vehicle_marker = GMSMarker()
                vehicle_marker.position = CLLocationCoordinate2D(latitude: locs.lat, longitude: locs.lng)
                vehicle_marker.title = locs.vehicle_name
                vehicle_marker.snippet = "Hey, this is \(locs.vehicle_name)"
                vehicle_marker.map = mapView
                markers.append(vehicle_marker)
            }else{
                let selectedMarker = markers[j]
                selectedMarker.position = CLLocationCoordinate2D(latitude: locs.lat, longitude: locs.lng)
            }
            j += 1;
        }
        print("markers: \(markers)")

    }
    
    func loadRealTimeLocations(timeOfLocation:String!){
        // Get the data: realtime latitude/longitude positions of vehicles.
        
        do{
        if let path = Bundle.main.url(forResource: "realtimelocation", withExtension: "json") {
            let data = try Data(contentsOf: path)
            let json = try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.allowFragments]) as! [String:Any]
            if let object = json["results"] as? [[String: Any]] {
                let foundItems = object.filter{($0["Time"] as! String) == timeOfLocation}
               // print("foundItems: \(foundItems)")
                addAnnotations(locationData: foundItems)
            } else {
                print("Could not read the JSON.")
            }
        }
        }catch{
            print(error.localizedDescription)
        }
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            i += 1
            if(i<=4){
            let timeStr = "05:0\(i)"
            self?.loadRealTimeLocations(timeOfLocation: timeStr)
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    // if appropriate, make sure to stop your timer in `deinit`
    
    deinit {
        stopTimer()
    }
}
