//
//  Constant.swift
//  MapDemo
//
//  Created by nguyen.duc.huyb on 6/13/19.
//  Copyright © 2019 nguyen.duc.huyb. All rights reserved.
//

import CoreLocation

enum ErrorMessage: String {
    case searchTextIsNil = "Please fill your destination"
    case locationFeatureIsDenied = "Your app cannot enable location services due to authorization"
    case locationFeatureIsAuthorizedWhenInUse = "Your app enable location services when in use"
    case locationFeatureIsNotDetermined = "Cannot determine your status authorization"
}

extension CLError {
    func showDescription() -> String {
        switch self.code {
        case .locationUnknown:
            return "Location is currently unknown"
        case .denied:
            return "Access to location or ranging has been denied by the user"
        case .network:
            return "Network-related error"
        case .headingFailure :
            return "Heading could not be determined"
        case .regionMonitoringDenied:
            return "Location region monitoring has been denied by the user"
        case .regionMonitoringFailure:
            return "A registered region cannot be monitored"
        case .regionMonitoringSetupDelayed:
            return "Core Location could not immediately initialize region monitoring"
        case .regionMonitoringResponseDelayed:
            return "While events for this fence will be delivered, delivery will not occur immediately"
        case .geocodeFoundNoResult:
            return "A geocode request yielded no result"
        case .geocodeFoundPartialResult:
            return "A geocode request yielded a partial result"
        case .geocodeCanceled:
            return "A geocode request was cancelled"
        case .deferredFailed:
            return "Deferred mode failed"
        case .deferredNotUpdatingLocation:
            return "Deferred mode failed because location updates disabled or paused"
        case .deferredAccuracyTooLow:
            return "Deferred mode not supported for the requested accuracy"
        case .deferredDistanceFiltered:
            return "Deferred mode does not support distance filters"
        case .deferredCanceled:
            return "Deferred mode request canceled a previous request"
        case .rangingUnavailable:
            return "Ranging cannot be performed"
        case .rangingFailure:
            return "General ranging failure"
        default:
            return self.localizedDescription
        }
    }
}
