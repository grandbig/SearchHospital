//
//  AppDelegate.swift
//  SearchHospital
//
//  Created by Takahiro Kato on 2018/04/01.
//  Copyright © 2018年 Takahiro Kato. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if let path = Bundle.main.path(forResource: R.string.common.keyFileName(), ofType: R.string.common.plistExtension()) {
            if let dic = NSDictionary(contentsOfFile: path) as? [String: Any] {
                if let apiKey = dic[R.string.common.googleApiKeyName()] as? String {
                    GMSServices.provideAPIKey(apiKey)
                    GMSPlacesClient.provideAPIKey(apiKey)
                }
            }
        }
        Fabric.with([Crashlytics.self])
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

}
