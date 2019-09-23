//
//  ListViewController.swift
//  UBike
//
//  Created by Mojo on 2019/8/19.
//  Copyright © 2019 Mojo. All rights reserved.
//

import UIKit
import Gzip
import GoogleMobileAds
import Crashlytics

class ListViewController: UIViewController {
    
    let common = Common.shared
    
    @IBOutlet weak var tableView: UITableView!
    var refreshControl:UIRefreshControl!
    var bannerView : GADBannerView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.refreshControl = UIRefreshControl()
        self.tableView.addSubview(refreshControl)
        self.refreshControl.addTarget(self, action: #selector(loadUBikeData), for: UIControl.Event.valueChanged)
        self.loadUBikeData()
        
        //AD
        self.bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        self.bannerView.translatesAutoresizingMaskIntoConstraints = false
        self.bannerView.adUnitID = "ca-app-pub-4348354487644961/6895023755" //廣告單元ID
        self.bannerView.rootViewController = self
        self.bannerView.load(GADRequest())
        self.bannerView.delegate = self
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    @IBAction func refreshButton(_ sender: Any) {
        self.loadUBikeData()
    }
    
    @objc func loadUBikeData(){
        self.common.getUBikeDatasFromWeb(tableView:self.tableView,refreshControl:self.refreshControl)
    }

    @objc func favoritePress(_ sender: UIButton) {
//        Crashlytics.sharedInstance().crash() //測試當機
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
        guard self.common.datas.count > indexPath.row,
            let sbi = Int(self.common.datas[indexPath.row].sbi),
            let bemp = Int(self.common.datas[indexPath.row].bemp) else{
                print("Int(sbi) or Int(bemp) error")
                return cell
        }
        cell.stationNameLabel.text = self.common.datas[indexPath.row].sna
        cell.totLabel.text = self.common.datas[indexPath.row].tot
        cell.sbiLabel.text = "\(self.common.datas[indexPath.row].sbi)"
        cell.bempLabel.text = "\(self.common.datas[indexPath.row].bemp)"
        if sbi <= 3{
            cell.sbiLabel.textColor = #colorLiteral(red: 1, green: 0.3098039216, blue: 0.2666666667, alpha: 1)
        }
        if bemp <= 3{
            cell.bempLabel.textColor = #colorLiteral(red: 1, green: 0.3098039216, blue: 0.2666666667, alpha: 1)
        }
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
            cell.favoriteButton.imageEdgeInsets = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
        }else{
            cell.favoriteButton.setTitle("unFavorite", for: .normal)
            cell.favoriteButton.setImage(UIImage(named: "unFavorite"), for: .normal)
            cell.favoriteButton.imageEdgeInsets = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
        }
        
        cell.favoriteButton.tag = indexPath.row
        
        cell.favoriteButton.addTarget(self, action: #selector(favoritePress), for: .touchUpInside)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stationNo = self.common.datas[indexPath.row].sno
        NotificationCenter.default.post(name: Notification.Name("selectAnnotation"), object: nil, userInfo: ["stationNo":stationNo])
        self.tabBarController!.selectedIndex = 1
    }

}

//MARK: UIGestureRecognizerDelegate
extension ListViewController: GADBannerViewDelegate {
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        if self.bannerView.superview == nil {
            
            if self.topConstraint != nil {
                self.topConstraint?.isActive = false
            }
            self.view.addSubview(bannerView)
            
            //autolayout
            //廣告上緣－safeArea上緣
            self.bannerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
            //廣告下緣－tableView上緣
            self.bannerView.bottomAnchor.constraint(equalTo: self.tableView.topAnchor, constant: 0).isActive = true
            //廣告左邊－controller'view 左邊
            self.bannerView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
            //廣告右邊－controller'view 右邊
            self.bannerView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
            
        }
    }
}
