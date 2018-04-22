//
//  HospitalWorker.swift
//  SearchHospital
//
//  Created by Takahiro Kato on 2018/04/19.
//  Copyright © 2018年 Takahiro Kato. All rights reserved.
//

import Foundation
import GooglePlaces
import PromiseKit

protocol HospitalProtocol {

    func fetchHospitals() -> Promise<[GMSPlaceLikelihood]>
    func fetchHospitals(lat: Double, lng: Double) -> Promise<Void>
}

class HospitalWorker {
    var dataStore: HospitalProtocol
    
    init(dataStore: HospitalProtocol) {
        self.dataStore = dataStore
    }

    func fetchHospitals() -> Promise<[GMSPlaceLikelihood]> {
        return dataStore.fetchHospitals()
    }
    
    func fetchHospitals(lat: Double, lng: Double) -> Promise<Void> {
        return dataStore.fetchHospitals(lat: lat, lng: lng)
    }
}
