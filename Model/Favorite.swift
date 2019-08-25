//
//  Favorite.swift
//  UBike
//
//  Created by Mojo on 2019/8/22.
//  Copyright © 2019 Mojo. All rights reserved.
//

import Foundation
import CoreData

class Favorite: NSManagedObject {
    @NSManaged var favoriteStationNo : String?
    @NSManaged var sarea : String?
}
