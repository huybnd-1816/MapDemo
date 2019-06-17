//
//  RouteViewController.swift
//  MapDemo
//
//  Created by nguyen.duc.huyb on 6/14/19.
//  Copyright © 2019 nguyen.duc.huyb. All rights reserved.
//

import UIKit
import MapKit

protocol RouteViewProtocol: class {
    func communicateToMainVC()
}

final class RouteViewController: UIViewController {
    @IBOutlet weak var routesCollectionView: UICollectionView!
    var steps: [MKRoute.Step] = [] {
        didSet {
            routesCollectionView.reloadData()
        }
    }
    
    weak var delegate: RouteViewProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nibName = UINib(nibName: "RouteCell", bundle:nil)
        routesCollectionView.register(nibName, forCellWithReuseIdentifier: "RouteCell")
    }
}

extension RouteViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return steps.count - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RouteCell", for: indexPath) as! RouteCell
        cell.configCell(currentStep: steps[indexPath.row + 1])
        return cell
    }
}
