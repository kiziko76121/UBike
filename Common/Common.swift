//
//  Common.swift
//  UBike
//
//  Created by Mojo on 2019/8/19.
//  Copyright © 2019 Mojo. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Common {
    static let shared = Common()
    var datas : [Station] = []
    var favorite : [Favorite] = []
    let youBikeTPJson = "https://tcgbusfs.blob.core.windows.net/blobyoubike/YouBikeTP.json"
    
    init(){
        queryFromCoreData()
    }
    
    func queryFromCoreData()  {
        
        let moc = CoreDataHelper.shared.managedObjectContext()
        
        let request = NSFetchRequest<Favorite>(entityName: "Favorite")
        
        moc.performAndWait {
            
            do{
                self.favorite = try moc.fetch(request)
            }catch{
                print("error \(error)")
                self.favorite = []
            }
            
        }
    }
    
    func getUBikeDatasFromWeb(tableView: UITableView){
        DispatchQueue.global().async {
            self.getUBikeData()
            DispatchQueue.main.async {
                tableView.reloadData()
            }
        }
    }
    
    func getUBikeDatasFromWeb(){
        self.getUBikeData()
    }
    
    private func getUBikeData(){
        
        self.datas = []
        guard let url = URL(string: self.youBikeTPJson),let originalData = try? Data(contentsOf: url ),
            let json = try? JSONSerialization.jsonObject(with: originalData, options: JSONSerialization.ReadingOptions.mutableContainers)
            else{
                print("Get json error")
                return
        }
        
        guard  let data = json as? [String: Any],
            let retVal = data["retVal"] ,
            let stationDatas = retVal as? [String: [String: Any]] else{
                print("Get json error")
                return
        }
        
        for stationData in stationDatas{
            let station = Station()
            station.sno = stationData.value["sno"] as? String ?? ""
            station.sna = stationData.value["sna"] as? String ?? ""
            station.tot = stationData.value["tot"] as? String ?? ""
            station.sbi = stationData.value["sbi"] as? String ?? "0"
            station.sarea = stationData.value["sarea"] as? String ?? ""
            station.mday = stationData.value["mday"] as? String ?? ""
            station.lat = stationData.value["lat"] as? String ?? "0.0"
            station.lng = stationData.value["lng"] as? String ?? "0.0"
            station.ar = stationData.value["ar"] as? String ?? ""
            station.bemp = stationData.value["bemp"] as? String ?? "0"
            station.act = stationData.value["act"] as? String ?? ""
            self.datas.append(station)
        }
        self.datas =  self.datas.sorted(by: {$0.sarea < $1.sarea})
        
    }

}
