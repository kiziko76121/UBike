//
//  UBikeAnnotation.swift
//  UBike
//
//  Created by Mojo on 2019/8/21.
//  Copyright © 2019 Mojo. All rights reserved.
//

import Foundation
import MapKit

class UBikeAnnotation: NSObject,MKAnnotation {
    var coordinate : CLLocationCoordinate2D
    var title : String?
    var subtitle : String?
    var sno : String?
    var sna : String?
    var latitude : Double?
    var longitude : Double?
    var sbi : Int?
    var bemp : Int?
    var address : String?
    var sarea : String?
    
    init(coordinate : CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
