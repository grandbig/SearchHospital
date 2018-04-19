//
//  HospitalAPI.swift
//  SearchHospital
//
//  Created by Takahiro Kato on 2018/04/19.
//  Copyright © 2018年 Takahiro Kato. All rights reserved.
//

import Foundation
import GooglePlaces
import PromiseKit

class HospitalAPI: HospitalProtocol {
    
    /// シングルトン
    static let sharedInstance = HospitalAPI()
    
    /// イニシャライザ
    init() {
    }

    // MARK: CRUD operations
    func fetchHospitals() -> Promise<Void> {
        let (promise, resolver) = Promise<Void>.pending()

        GMSPlacesClient.shared().currentPlace { (placeLikelihoods, error) in
            if let error = error {
                print("\(error)")
                resolver.reject(error)
            }
            if let likelihoodList = placeLikelihoods {
                for likelihood in likelihoodList.likelihoods {
                    let place = likelihood.place
                    print("name: \(place.name), types: \(place.types)")
                }
            }
            resolver.fulfill(Void())
        }
        
        return promise
    }
}
