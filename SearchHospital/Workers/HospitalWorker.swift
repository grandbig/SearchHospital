//
//  HospitalWorker.swift
//  SearchHospital
//
//  Created by Takahiro Kato on 2018/04/19.
//  Copyright © 2018年 Takahiro Kato. All rights reserved.
//

import Foundation
import PromiseKit

protocol HospitalProtocol {

    func fetchHospitals(lat: Double, lng: Double) -> Promise<[Place]>
}

class HospitalWorker {
    var dataStore: HospitalProtocol
    
    init(dataStore: HospitalProtocol) {
        self.dataStore = dataStore
    }
    
    func fetchHospitals(lat: Double, lng: Double) -> Promise<[Place]> {
        return dataStore.fetchHospitals(lat: lat, lng: lng)
    }
}
