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
import CoreLocation


class Common :NSObject{
    static let shared = Common()
    var locationManager = CLLocationManager()
    var datas : [Station] = []
    var favorite : [Favorite] = []
    let youBikeTPJson = "https://tcgbusfs.blob.core.windows.net/blobyoubike/YouBikeTP.json"
    let youBikeNTPJson = "https://data.ntpc.gov.tw/od/data/api/54DDDC93-589C-4858-9C95-18B2046CC1FC?$format=json"
    var lat = 0.0
    var lng = 0.0
    
    override init(){
        super.init()
        queryFromCoreData()
    }
    
    func queryFromCoreData()  {
        
        let moc = CoreDataHelper.shared.managedObjectContext()
        
        let request = NSFetchRequest<Favorite>(entityName: "Favorite")
        let sortSarea = NSSortDescriptor(key: "sarea", ascending: true)
        let sortFavoriteStationNo = NSSortDescriptor(key: "favoriteStationNo", ascending: true)
        request.sortDescriptors = [sortSarea,sortFavoriteStationNo]
        
        moc.performAndWait {
            
            do{
                self.favorite = try moc.fetch(request)
            }catch{
                print("error \(error)")
                self.favorite = []
            }
            
        }
    }
    
    //MARK: Core Data
    func saveToCoreData() {
        
        CoreDataHelper.shared.saveContext()
        
    }
    
    func getUBikeDatasFromWeb(tableView: UITableView,refreshControl:UIRefreshControl){
        self.datas = []
        // 開始刷新動畫
        refreshControl.beginRefreshing()
        DispatchQueue.global().async {
            self.loadLocation()
            self.getUBikeData(url: self.youBikeTPJson,city:"TP")
            self.getUBikeData(url: self.youBikeNTPJson,city:"NTP")
                DispatchQueue.main.async {
                    tableView.reloadData()
                    // 停止 refreshControl 動畫
                    refreshControl.endRefreshing()
                }
        }
    }
    
    func getUBikeDatasFromWeb(){
        self.datas = []
        self.getUBikeData(url: self.youBikeTPJson,city:"TP")
        self.getUBikeData(url: self.youBikeNTPJson,city:"NTP")
    }
    
    private func getUBikeData(url:String,city:String){
        
        
        guard let url = URL(string: url ),let originalData = try? Data(contentsOf: url ),
            let json = try? JSONSerialization.jsonObject(with: originalData, options: JSONSerialization.ReadingOptions.mutableContainers)
            else{
                print("Get json error")
                return
        }
        
        guard let stationDatas = self.jsonTostationData(json: json, city: city) else{
            return
        }
        
        for stationData in stationDatas{
            let station = Station()
            station.sno = stationData["sno"] as? String ?? ""
            station.sna = stationData["sna"] as? String ?? ""
            station.tot = stationData["tot"] as? String ?? ""
            station.sbi = stationData["sbi"] as? String ?? "0"
            station.sarea = stationData["sarea"] as? String ?? ""
            station.mday = stationData["mday"] as? String ?? ""
            station.lat = stationData["lat"] as? String ?? "0.0"
            station.lat = station.lat.replacingOccurrences(of: " ", with: "")
            station.lng = stationData["lng"] as? String ?? "0.0"
            station.lng = station.lng.replacingOccurrences(of: " ", with: "")
            station.ar = stationData["ar"] as? String ?? ""
            station.bemp = stationData["bemp"] as? String ?? "0"
            station.act = stationData["act"] as? String ?? ""
            self.datas.append(station)
        }
//        self.datas.sort(by: {
//            if  $0.sarea == $1.sarea{
//                return $0.sno < $1.sno
//            }else{
//                return $0.sarea < $1.sarea
//            }
//        })
        self.sortUBikeData()
//        for data in self.datas{
//            print("\(data.sarea),\(data.sno)")
//        }
        
    }
    
    private func jsonTostationData(json:Any,city:String)-> [[String: Any]]? {
        switch city{
        case "TP":
            guard  let firstArray = json as? [String: Any],
                let retVal = firstArray["retVal"] ,
                let datas = retVal as? [String: [String: Any]] else{
                    print("TPJson to data error")
                    return nil
            }
            let stationDatas = Array(datas.values)
            return stationDatas
            
        case "NTP":
            guard  let stationDatas = json as? [[String: Any]] else{
                print("NTPJson to data error")
                return nil
            }
            return stationDatas
        default:
            return nil
        }
    }
    
    func checkIsFavorite(value: String)-> Bool{
        for favorite in self.favorite{
            if favorite.favoriteStationNo == value{
                return true
            }
        }
        return false
    }
    
    func sortUBikeData(){
        let latitude = self.lat
        let longitude = self.lng
        let userLocation = (x:latitude,y:longitude)
        self.datas.sort(by: {
            return sqrt(pow((Double($0.lat)! - userLocation.x), 2) + pow((Double($0.lng)! - userLocation.y), 2)) <
                sqrt(pow((Double($1.lat)! - userLocation.x), 2) + pow((Double($1.lng)! - userLocation.y), 2))
        })
    }

}

extension Common: CLLocationManagerDelegate
{
    
    //開啟定位
    func loadLocation()
    {
        
        locationManager.delegate = self
        //定位方式
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //使用應用程式期間允許訪問位置資料
        locationManager.requestWhenInUseAuthorization()
        //開啟定位
        locationManager.startUpdatingLocation()
    }
    

    //獲取定位資訊
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //取得locations陣列的最後一個
        let location:CLLocation = locations[locations.count-1]
//        currLocation = locations.last!
        //判斷是否為空
        if(location.horizontalAccuracy > 0){
            self.lat = location.coordinate.latitude
            self.lng = location.coordinate.longitude
//            print("緯度:\(self.lng)")
//            print("經度:\(self.lat)")
            //停止定位
            locationManager.stopUpdatingLocation()
        }
        
    }
    
    //出現錯誤
    private func locationManager(manager: CLLocationManager, didFinishDeferredUpdatesWithError error: NSError?) {
        print(error)
    }
    
    
    
}
