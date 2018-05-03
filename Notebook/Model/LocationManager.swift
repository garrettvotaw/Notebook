//
//  LocationManager.swift
//  Notebook
//
//  Created by Garrett Votaw on 5/3/18.
//  Copyright © 2018 Garrett Votaw. All rights reserved.
//

import Foundation
import CoreLocation

enum LocationError: Error {
    case disallowedByUser
    case locationUnavailable
    case networkFailure
}

protocol LocationDelegate: class {
    func obtainedLocation(_ coordinate: CLLocation)
    func failedWithError(_ error: LocationError)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    weak var delegate: LocationDelegate?
    private let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
    }
    
    func requestAuthorization() throws {
        let status = CLLocationManager.authorizationStatus()
        switch status {
            case .denied, .restricted: throw LocationError.disallowedByUser
            case .notDetermined: manager.requestWhenInUseAuthorization()
        default: return
        }
    }
    
    func requestLocation() {
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let error = error as? CLError else {return}
        
        switch error.code {
        case .network: delegate?.failedWithError(.networkFailure)
        case .denied: delegate?.failedWithError(.disallowedByUser)
        case .locationUnknown: delegate?.failedWithError(.locationUnavailable)
        default: return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            delegate?.failedWithError(.locationUnavailable)
            return
        }
        delegate?.obtainedLocation(location)
    }
}
