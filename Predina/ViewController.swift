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
        heatmapLayer.map = mapView
}

}
