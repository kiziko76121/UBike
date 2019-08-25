//
//  ListViewController.swift
//  UBike
//
//  Created by Mojo on 2019/8/19.
//  Copyright © 2019 Mojo. All rights reserved.
//

import UIKit
import Gzip

class ListViewController: UIViewController {
    
    let common = Common.shared
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadUBikeData()
    }
    
    @IBAction func refreshButton(_ sender: Any) {
        self.loadUBikeData()
    }
    
    func loadUBikeData(){
        self.common.getUBikeDatasFromWeb(tableView:self.tableView)
    }

    @objc func favoritePress(_ sender: UIButton) {
        if sender.title(for: .normal) == "unFavorite"{
            guard let image = UIImage(named: "favorite") else{
                return
            }
            sender.setImage(image, for: .normal)
            sender.setTitle("favorite", for: .normal)
            let moc = CoreDataHelper.shared.managedObjectContext()
            let favorite  = Favorite(context: moc)
            
            
            favorite.favoriteStationNo = self.common.datas[sender.tag].sno
            favorite.sarea = self.common.datas[sender.tag].sarea
            self.common.favorite.insert(favorite, at: 0)
            
            self.common.saveToCoreData()
        }else{
            guard let image = UIImage(named: "unFavorite") else{
                return
            }
            sender.setImage(image, for: .normal)
            sender.setTitle("unFavorite", for: .normal)
            
            for index in 0..<self.common.favorite.count{
                if self.common.favorite[index].favoriteStationNo == self.common.datas[sender.tag].sno{
                    let deleteFavorite = self.common.favorite.remove(at: index)
                    let moc = CoreDataHelper.shared.managedObjectContext()
                    moc.delete(deleteFavorite)
                    break
                }
            }
            self.common.saveToCoreData()
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        self.hidesBottomBarWhenPushed = true
    }
 

}

extension ListViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.common.datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ListTableViewCell
        cell.stationNameLabel.text = self.common.datas[indexPath.row].sna
        cell.totLabel.text = self.common.datas[indexPath.row].tot
        cell.sbiLabel.text = "\(self.common.datas[indexPath.row].sbi)"
        cell.bempLabel.text = "\(self.common.datas[indexPath.row].bemp)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let dateString = self.common.datas[indexPath.row].mday
        let date = dateFormatter.date(from: dateString)
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        cell.mdayLabel.text = dateFormatter.string(from: date!)
        cell.addressLabel.text = self.common.datas[indexPath.row].ar
        
        if self.common.checkIsFavorite(value: self.common.datas[indexPath.row].sno){
            cell.favoriteButton.setTitle("favorite", for: .normal)
            cell.favoriteButton.setImage(UIImage(named: "favorite"), for: .normal)
        }else{
            cell.favoriteButton.setTitle("unFavorite", for: .normal)
            cell.favoriteButton.setImage(UIImage(named: "unFavorite"), for: .normal)
        }

        cell.favoriteButton.tag = indexPath.row
        
        cell.favoriteButton.addTarget(self, action: #selector(favoritePress), for: .touchUpInside)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stationNo = self.common.datas[indexPath.row].sno
        print("ListstationNo=\(stationNo)")
        NotificationCenter.default.post(name: Notification.Name("selectAnnotation"), object: nil, userInfo: ["stationNo":stationNo])
        self.tabBarController!.selectedIndex = 1
    }

}
