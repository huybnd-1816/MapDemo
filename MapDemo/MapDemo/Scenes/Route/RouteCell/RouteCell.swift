//
//  RouteCell.swift
//  MapDemo
//
//  Created by nguyen.duc.huyb on 6/14/19.
//  Copyright © 2019 nguyen.duc.huyb. All rights reserved.
//

import UIKit
import MapKit

final class RouteCell: UICollectionViewCell {
    @IBOutlet private weak var directionLabel: UILabel!
    
    func configCell(currentStep: MKRoute.Step) {
        directionLabel.text = "Đi \(currentStep.distance) mét, \(currentStep.instructions)"
    }
}
