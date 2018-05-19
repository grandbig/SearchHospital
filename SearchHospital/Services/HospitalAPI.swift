//
//  HospitalAPI.swift
//  SearchHospital
//
//  Created by Takahiro Kato on 2018/04/19.
//  Copyright © 2018年 Takahiro Kato. All rights reserved.
//

import Foundation
import Moya
import PromiseKit
import GooglePlaces

internal enum HospitalAPITarget {
    case hospitals(lat: Double, lng: Double)
}

internal enum APIError: Error {
    case cancel
    case apiError(description: String)
    case decodeError
}

internal enum GooglePlacesError: Error {
    case cancel
    case notFoundError
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
        switch self {
        case .hospitals:
            return R.string.url.googlePlacesApiPlaceUrl()
        }
        
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
        case let .hospitals(lat, lng):
            return .requestParameters(parameters: [
                R.string.common.keyFileName(): apiKey,
                R.string.common.locationKeyName(): "\(lat),\(lng)",
                R.string.common.radiusKeyName(): 1500,
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
    
    /// 指定の緯度、経度から一定範囲内の病院を検索する処理
    ///
    /// - Returns: 病院のプレイス情報
    func fetchHospitals(lat: Double, lng: Double) -> Promise<[Place]> {
        let (promise, resolver) = Promise<[Place]>.pending()
        
        provider.request(.hospitals(lat: lat, lng: lng)) { result in
            switch result {
            case .success(let response):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let places = try decoder.decode(Places.self, from: response.data)
                    
                    resolver.fulfill(places.results)
                } catch {
                    resolver.reject(APIError.decodeError)
                }
            case .failure(let error):
                resolver.reject(APIError.apiError(description: error.localizedDescription))
            }
        }
        
        return promise
    }

    func fetchPhoto(placeId: String) -> Promise<UIImage?> {
        let (promise, resolver) = Promise<UIImage?>.pending()

        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeId) { (photos, error) in
            if let error = error {
                resolver.reject(error)
                return
            }
            guard let firstPhoto = photos?.results.first else {
                resolver.reject(GooglePlacesError.notFoundError)
                return
            }
            GMSPlacesClient.shared().loadPlacePhoto(firstPhoto, callback: { (image, error) in
                if let error = error {
                    resolver.reject(error)
                    return
                }
                resolver.fulfill(image)
            })
        }
        
        return promise
    }
}
