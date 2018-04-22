//
//  HospitalAPI.swift
//  SearchHospital
//
//  Created by Takahiro Kato on 2018/04/19.
//  Copyright © 2018年 Takahiro Kato. All rights reserved.
//

import Foundation
import GooglePlaces
import Moya
import PromiseKit
import SwiftyJSON

internal enum HospitalAPITarget {
    case hospitals(lat: Double, lng: Double)
}

extension HospitalAPITarget: TargetType {
    
    /// API Key
    private var apiKey: String {
        guard let path = Bundle.main.path(forResource: R.string.common.keyFileName(),
                                          ofType: R.string.common.plistExtension()) else {
            fatalError("key.plistが見つかりません")
        }
        
        guard let dic = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            fatalError("key.plistの中身が想定通りではありません")
        }
        
        guard let apiKey = dic[R.string.common.googleApiKeyName()] as? String else {
            fatalError("Google APIのKeyが設定されていません")
        }
        
        return apiKey
    }
    
    // ベースURLを文字列で定義
    private var _baseURL: String {
        return R.string.url.googlePlacesApiPlaceUrl()
    }
    
    public var baseURL: URL {
        return URL(string: _baseURL)!
    }
    
    // enumの値に対応したパスを指定
    public var path: String {
        switch self {
        case .hospitals:
            return ""
        }
    }
    
    // enumの値に対応したHTTPメソッドを指定
    public var method: Moya.Method {
        switch self {
        case .hospitals:
            return .get
        }
    }
    
    // スタブデータの設定
    public var sampleData: Data {
        switch self {
        case .hospitals:
            return "Stub data".data(using: String.Encoding.utf8)!
        }
    }
    
    // パラメータの設定
    var task: Task {
        switch self {
        case .hospitals(let lat, let lng):
            return .requestParameters(parameters: [
                R.string.common.keyFileName(): apiKey,
                R.string.common.locationKeyName(): "\(lat),\(lng)",
                R.string.common.radiusKeyName(): 500,
                R.string.common.typeKeyName(): R.string.common.hospitalTypeValueName()
                ], encoding: URLEncoding.default)
        }
    }
    
    // ヘッダーの設定
    var headers: [String: String]? {
        switch self {
        case .hospitals:
            return nil
        }
    }
}

class HospitalAPI: HospitalProtocol {
    
    private var provider: MoyaProvider<HospitalAPITarget>!

    /// イニシャライザ
    init() {
        provider = MoyaProvider<HospitalAPITarget>()
    }

    // MARK: CRUD operations
    func fetchHospitals() -> Promise<[GMSPlaceLikelihood]> {
        let (promise, resolver) = Promise<[GMSPlaceLikelihood]>.pending()

        GMSPlacesClient.shared().currentPlace { (placeLikelihoods, error) in
            if let error = error {
                print("\(error)")
                resolver.reject(error)
            }
            var result = [GMSPlaceLikelihood]()
            if let likelihoodList = placeLikelihoods {
                for likelihood in likelihoodList.likelihoods {
                    result.append(likelihood)
                }
            }
            resolver.fulfill(result)
        }
        
        return promise
    }
    
    func fetchHospitals(lat: Double, lng: Double) -> Promise<Void> {
        let (promise, resolver) = Promise<Void>.pending()
        
        provider.request(.hospitals(lat: lat, lng: lng)) { result in
            switch result {
            case .success(let response):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let places = try decoder.decode(Places.self, from: response.data)
                    print("places: \(places)")
                    
                    resolver.fulfill(Void())
                } catch {
                    print("error: 変換エラー？")
                }
            case .failure(let error):
                print("error: \(error)")
            }
        }
        
        return promise
    }
}
