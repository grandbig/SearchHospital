//
//  MapViewController.swift
//  SearchHospital
//
//  Created by Takahiro Kato on 2018/04/12.
//  Copyright (c) 2018年 Takahiro Kato. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import GoogleMaps
import PromiseKit

protocol MapDisplayLogic: class {
    func displayInitialize(viewModel: Map.Initialize.ViewModel)
    func displaySearched(viewModel: Map.Search.ViewModel)
    func displayFetchedPhoto(viewModel: Map.FetchPhoto.ViewModel)
}

class MapViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet private weak var mapView: GMSMapView!

    // MARK: - Properties
    var interactor: MapBusinessLogic?
    var router: (NSObjectProtocol & MapRoutingLogic & MapDataPassing)?
    /// 位置情報マネージャ
    internal var locationManager: CLLocationManager?
    private let defaultLatitude: Double = 35.681167
    private let defaultLongitude: Double = 139.767052

    // MARK: Object lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
  
    // MARK: Setup
    private func setup() {
        let viewController = self
        let interactor = MapInteractor()
        let presenter = MapPresenter()
        let router = MapRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }

    // MARK: Configure
    /// GoogleMapの初期化
    func configureMapView() {
        mapView.isMyLocationEnabled = true
        mapView.mapType = GMSMapViewType.normal
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        mapView.delegate = self
    }

    /// 位置情報サービスの初期化
    func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
        locationManager?.delegate = self
    }
  
    // MARK: Routing
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureMapView()
        configureLocationManager()
    }
    
    // MARK: Initialize
    func initialize(latitude: Double, longitude: Double) {
        let request = Map.Initialize.Request(latitude: latitude, longitude: longitude)
        interactor?.initialize(request: request)
    }

    // MARK: 検索
    func search() {
        let request = Map.Search.Request(latitude: mapView.myLocation?.coordinate.latitude ?? defaultLatitude,
                                         longitude: mapView.myLocation?.coordinate.longitude ?? defaultLongitude)
        interactor?.search(request: request)
    }

    func fetchPhoto(placeId: String) {
        let request = Map.FetchPhoto.Request(placeId: placeId)
        interactor?.fetchPhoto(request: request)
    }

    @IBAction func tappedSearchButton(_ sender: Any) {
        search()
    }
}

// MARK: - MapDisplayLogic
extension MapViewController: MapDisplayLogic {

    func displayInitialize(viewModel: Map.Initialize.ViewModel) {
        switch viewModel.state {
        case let .unInitialized(latitude, longitude, zoomLevel):
            // 初期描画時のマップ中心位置の移動
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: zoomLevel)
            mapView.camera = camera
        default:
            break
        }
    }

    func displaySearched(viewModel: Map.Search.ViewModel) {
        
        switch viewModel.state {
        case let .success(places):
            places.forEach {
                putMarker(place: $0)
            }
        case let .failure(description):
            _ = showAlert(message: description)
        }
    }

    func displayFetchedPhoto(viewModel: Map.FetchPhoto.ViewModel) {
        switch viewModel.state {
        case let .success(image):
            guard let cMarker = mapView.selectedMarker as? CustomGMSMarker else {
                return
            }
            guard let infoWindow = cMarker.infoWindow as? MarkerInfoContentsView else {
                return
            }
            infoWindow.configure(image: image)
        case let .failure(description):
            print(description)
        }
        
    }
}

// MARK: - private methods
extension MapViewController {
    
    /// マップへのマーカのプロット処理
    ///
    /// - Parameter place: 病院のプレイス情報
    private func putMarker(place: Map.Search.ViewModel.Place) {
        // 情報ウィンドウの初期化
        let infoWindow = MarkerInfoContentsView(frame: CGRect(x: 0, y: 0, width: 250, height: 265))
        infoWindow.setup(name: place.name, rating: place.rating ?? 0.0)

        // マーカの初期化
        let marker = CustomGMSMarker()
        marker.placeId = place.placeId
        marker.name = place.name
        marker.position = CLLocationCoordinate2D.init(latitude: place.latitude, longitude: place.longitude)
        marker.rating = place.rating ?? 0.0
        marker.priceLevel = place.priceLevel ?? 0
        marker.openNow = place.openNow
        marker.infoWindow = infoWindow
        marker.icon = R.image.hospitalMarkerIcon()
        marker.appearAnimation = GMSMarkerAnimation.pop
        marker.map = mapView
        marker.tracksInfoWindowChanges = true
    }
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            break
        case .restricted, .denied:
            break
        case .authorizedWhenInUse:
            break
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = locations.last?.coordinate {
            initialize(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }
}

// MARK: - GMSMapViewDelegate
extension MapViewController: GMSMapViewDelegate {

    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        return false
    }

    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        guard let cMarker = marker as? CustomGMSMarker else {
            return nil
        }
        fetchPhoto(placeId: cMarker.placeId)
        return cMarker.infoWindow
    }
}
