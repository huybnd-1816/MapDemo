//
//  LocationManager.swift
//  MapDemo
//
//  Created by nguyen.duc.huyb on 6/13/19.
//  Copyright © 2019 nguyen.duc.huyb. All rights reserved.
//

import MapKit

protocol LocationUpdateProtocol {
    func directionDidUpdateToLocation(steps: [MKRoute.Step])
    func showError(error: String)
}

class LocationService: NSObject {
    static let shared = LocationService()
    private var locationManager = CLLocationManager()
    private var currentCoordinate: CLLocationCoordinate2D! // Coordinate = Lat and Long
    private var steps: [MKRoute.Step] = []
    private var stepCounter: Int = 0
    fileprivate var pointAnnotation: CustomPointAnnotation!
    fileprivate var pinAnnotationView: MKPinAnnotationView!
    var mapView: MKMapView!
    var delegate: LocationUpdateProtocol!
    
    private override init () {
        super.init()
        configLocationManager()
    }
    
    fileprivate func configLocationManager() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        startReceivingSignificantLocationChanges()
    }
    
    // MKMapItem - includes a geographic location and any interesting data that might apply to that location
    // MKPlacemark -  includes information such as the country, state, city, and street address associated with the specified coordinate
    private func getDirections(to destination: MKMapItem) {
        let sourcePlacemark = MKPlacemark(coordinate: currentCoordinate)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        
        // Remove all polyline in overlay
        for poll in mapView.overlays {
            mapView.removeOverlay(poll)
        }
        
        // Remove all annotation in mapView
        mapView.removeAnnotations(mapView.annotations)
        
        
        pointAnnotation = CustomPointAnnotation()
        pointAnnotation.coordinate = destination.placemark.coordinate
        pointAnnotation.imageName = "icon-pin"
        pointAnnotation.title = "My Destination"
        
        pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "pin")
        mapView.addAnnotation(pinAnnotationView.annotation!)
        
        //Request routes
        let directionsRequest = MKDirections.Request()
        directionsRequest.source = sourceMapItem // Start point
        directionsRequest.destination = destination // End point
        directionsRequest.transportType = .automobile // Transport Type
        
        // Setup region for coordinate between current coordinate and destination to chage zoom value (Coordinate Span)
        let centerPoint = CLLocationCoordinate2D(latitude: (currentCoordinate.latitude + destination.placemark.coordinate.latitude) / 2,
                                                 longitude: (currentCoordinate.longitude + destination.placemark.coordinate.longitude) / 2)
        let region = MKCoordinateRegion(center: centerPoint, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        mapView.setRegion(region, animated: true)
        
        let directions = MKDirections(request: directionsRequest)
        // Begin calculating the request routes
        directions.calculate { [weak self] (response, error) in
            guard let self = self else { return }
            
            if let response = response,
                let primaryRoute = response.routes.first {
                
                self.mapView.addOverlay(primaryRoute.polyline)
                self.locationManager.monitoredRegions.forEach {
                    self.locationManager.stopMonitoring(for: $0)
                }
                
                // Create region monitor
                self.steps = primaryRoute.steps
                self.setupRegionMonitor(steps: primaryRoute.steps)
                
                let initialMessage = "In \(self.steps[0].distance) meters, \(self.steps[0].instructions) then in \(self.steps[1].distance) mters, \(self.steps[1].instructions)."
                print(initialMessage)
                
                self.delegate.directionDidUpdateToLocation(steps: primaryRoute.steps)
                self.stepCounter += 1
            } else if let error = error {
                self.delegate.showError(error: "\(error.localizedDescription)")
            }
        }
    }
    
    private func setupRegionMonitor(steps: [MKRoute.Step]) {
        for i in 0 ..< steps.count {
            let step = steps[i]
            let region = CLCircularRegion(center: step.polyline.coordinate, radius: 20, identifier: "\(i)")
            self.locationManager.startMonitoring(for: region)
            
            let circle = MKCircle(center: region.center, radius: region.radius)
            self.mapView.addOverlay(circle)
        }
    }
    
    func configLocationSearchRequest(_ searchText: String) {
        guard CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse,
            currentCoordinate != nil else {
            return
        }
        
        // Setup location search request
        let localSearchRequest = MKLocalSearch.Request()
        localSearchRequest.naturalLanguageQuery = searchText
        
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { [weak self] (response, error) in
            guard let self = self else { return }
            if let response = response,
                let firstMapItem = response.mapItems.first {
                self.getDirections(to: firstMapItem)    
            } else if let error = error {
                self.delegate.showError(error: error.localizedDescription)
            }
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    // Called when app get new location of user
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        currentCoordinate = currentLocation.coordinate
        print("LOCATION UPDATE")
    }
    
    func startReceivingSignificantLocationChanges() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedAlways {
            // User has not authorized access to location information.
            return
        }
        
        if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
            // The service is not available.
            return
        }
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    // Stopping location services when authorization is denied
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .denied {
            // Notify the user of any errors.
            delegate.showError(error: error.showDescription())
            
            // Location updates are not authorized.
            manager.stopMonitoringSignificantLocationChanges()
            return
        }
    }
    
    // Check Location Authorization status
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            // Disable your app's location features
            delegate.showError(error: ErrorMessage.locationFeatureIsDenied.rawValue)
            break
        case .authorizedWhenInUse:
            // Enable only your app's when-in-use features.
            print(ErrorMessage.locationFeatureIsAuthorizedWhenInUse.rawValue)
            break
        case .authorizedAlways:
            // Enable any of your app's location services.
            print("locationFeatureIsAuthorizedAlways")
            //Zoom to user location
            mapView.userTrackingMode = .followWithHeading
            break
        case .notDetermined:
            print(ErrorMessage.locationFeatureIsNotDetermined)
            locationManager.requestAlwaysAuthorization()
            break
        default:
            break
        }
    }
    
    // Called when user enter the specified region
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        stepCounter += 1
        if stepCounter < steps.count {
            let currentStep = steps[stepCounter]
            print("In \(currentStep.distance) meters, \(currentStep.instructions)")
            delegate.directionDidUpdateToLocation(steps: steps)
            
        } else {
            let message = "Arrived at destination"
            print(message)
            stepCounter = 0
            locationManager.monitoredRegions.forEach {
                self.locationManager.stopMonitoring(for: $0)
            }
        }
    }
}

extension MainViewController: MKMapViewDelegate {
    // Drawing the specified overlay
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // MKPolyline - a shape contains one or more connected line segments
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor(hexString: "04A6FF")
            renderer.lineWidth = 10
            return renderer
        }
        
        // MKCircle - a circular overlay with a configurable radius and centered on a specific geographic coordinate.
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.strokeColor = .red
            renderer.fillColor = .red
            renderer.alpha = 0.5
            return renderer
        }
        
        return MKOverlayRenderer()
    }
    
    //    MARK: - Custom Annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is CustomPointAnnotation else { return nil }
        let reuseIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.canShowCallout = true
            let cpa = annotation as! CustomPointAnnotation
            annotationView?.image = UIImage(named: cpa.imageName)
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
}
