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
        print("123")
//        if self.isFavorite {
//            self.isFavorite = true
            if let image = UIImage(named: "favorite") {
                sender.setImage(image, for: .normal)
            }
//        }else{
//            self.isFavorite = false
//            if let image = UIImage(named: "unFavorite") {
//                self.favoriteButton.setImage(image, for: .normal)
//            }
//
//        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ListViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.common.datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ListTableViewCell
        cell.stationName.text = self.common.datas[indexPath.row].sna
        cell.tot.text = self.common.datas[indexPath.row].tot
        cell.sbi.text = "\(self.common.datas[indexPath.row].sbi)"
        cell.bemp.text = "\(self.common.datas[indexPath.row].bemp)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let dateString = self.common.datas[indexPath.row].mday
        let date = dateFormatter.date(from: dateString)
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        cell.mday.text = dateFormatter.string(from: date!)
        cell.address.text = self.common.datas[indexPath.row].ar
        
        // assign the index of the youtuber to button tag
        cell.favoriteButton.tag = indexPath.row
        
        // call the subscribeTapped method when tapped
        cell.favoriteButton.addTarget(self, action: #selector(favoritePress), for: .touchUpInside)
        return cell
    }
    

}
