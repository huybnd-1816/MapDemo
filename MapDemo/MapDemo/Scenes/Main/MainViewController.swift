//
//  ViewController.swift
//  MapDemo
//
//  Created by nguyen.duc.huyb on 6/12/19.
//  Copyright © 2019 nguyen.duc.huyb. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

final class MainViewController: UIViewController, RouteViewProtocol {
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var mapView: MKMapView!
    
    private lazy var routeViewController: RouteViewController = {
        let vc = storyboard?.instantiateViewController(withIdentifier: "RouteViewController") as! RouteViewController
        addChild(vc)
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    
    private func config() {
        LocationService.shared.mapView = mapView
        LocationService.shared.delegate = self
        searchBar.showsCancelButton = false
        hideKeyboardWhenTappedAround()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "RouteVCSegue") {
            routeViewController = segue.destination as! RouteViewController
            routeViewController.view.isHidden = true
            routeViewController.delegate = self
        }
    }
    
    func communicateToMainVC() {
        print("")
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        guard let searchText = searchBar.text,
            searchBar.text != "" else {
                showAlert(message: ErrorMessage.searchTextIsNil.rawValue)
                return
        }
        
        LocationService.shared.configLocationSearchRequest(searchText)
        routeViewController.view.isHidden = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        routeViewController.view.isHidden = true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
}

extension MainViewController: LocationUpdateProtocol {
    func directionDidUpdateToLocation(steps: [MKRoute.Step]) {
        routeViewController.steps = steps
    }
    
    func showError(error: String) {
        // Clear all polyline in overlay
        for poll in mapView.overlays {
            mapView.removeOverlay(poll)
        }
        
        showAlert(message: error)
        routeViewController.view.isHidden = true
    }
}

