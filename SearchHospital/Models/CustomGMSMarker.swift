//
//  CustomGMSMarker.swift
//  SearchHospital
//
//  Created by Takahiro Kato on 2018/04/24.
//  Copyright © 2018年 Takahiro Kato. All rights reserved.
//

import Foundation
import GoogleMaps

/// 病院プロット用の拡張GMSMarker
class CustomGMSMarker: GMSMarker {

    /// プレイスID
    public var placeId: String!
    /// プレイス名
    public var name: String!
    /// 評価
    public var rating: Double!
    /// 価格レベル
    public var priceLevel: Int!
    /// 現在の営業状態
    public var openNow: Bool!
    
    /// 初期化
    override init() {
        super.init()
    }
}
