//
//  Station.swift
//  UBike
//
//  Created by Mojo on 2019/8/19.
//  Copyright © 2019 Mojo. All rights reserved.
//

import Foundation

class Station: Codable {
    var sno : String = "" //站點代號
    var sna : String = "" //場站名稱
    var tot : String = "" //場站總停車格
    var sbi : String = "0" //場站目前車輛數量
    var sarea : String = "" //場站區域
    var mday : String = "" //資料更新時間
    var lat : String = "0.0" //緯度
    var lng : String = "0.0"//經度
    var ar : String = "" //地
    var bemp : String = "0" //空位數量
     var act : String = "" //全站禁用狀態
}
