//
//  FavoritesViewController.swift
//  UBike
//
//  Created by Mojo on 2019/8/19.
//  Copyright © 2019 Mojo. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController {
    
    let common = Common.shared

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        self.loadUBikeData()
        self.common.queryFromCoreData()
    }
    
    func loadUBikeData(){
        self.common.getUBikeDatasFromWeb(tableView:self.tableView)
    }
    
    @objc func favoritePress(_ sender: UIButton) {
        
        
        let deleteFavorite = self.common.favorite.remove(at: sender.tag)
        let moc = CoreDataHelper.shared.managedObjectContext()
        moc.delete(deleteFavorite)
        
        self.common.saveToCoreData()
        let indexPath = IndexPath(row: sender.tag, section: 0)
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        self.tableView.reloadData()
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

extension FavoritesViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.common.favorite.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ListTableViewCell
        
        for data in self.common.datas{
            if data.sno == self.common.favorite[indexPath.row].favoriteStationNo{
                guard let sbi = Int(data.sbi),
                    let bemp = Int(data.bemp) else{
                        print("Int(sbi) or Int(bemp) error")
                        return cell
                }
                cell.stationNameLabel.text = data.sna
                cell.totLabel.text = data.tot
                cell.sbiLabel.text = "\(data.sbi)"
                cell.bempLabel.text = "\(data.bemp)"
                if sbi <= 3{
                    cell.sbiLabel.textColor = #colorLiteral(red: 1, green: 0.3098039216, blue: 0.2666666667, alpha: 1)
                }
                if bemp <= 3{
                    cell.bempLabel.textColor = #colorLiteral(red: 1, green: 0.3098039216, blue: 0.2666666667, alpha: 1)
                }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyyMMddHHmmss"
                let dateString = data.mday
                let date = dateFormatter.date(from: dateString)
                dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
                cell.mdayLabel.text = dateFormatter.string(from: date!)
                cell.addressLabel.text = data.ar
                cell.favoriteButton.tag = indexPath.row
                cell.favoriteButton.addTarget(self, action: #selector(favoritePress), for: .touchUpInside)
                cell.favoriteButton.imageEdgeInsets = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
                return cell
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stationNo = self.common.favorite[indexPath.row].favoriteStationNo
        NotificationCenter.default.post(name: Notification.Name("selectAnnotation"), object: nil, userInfo: ["stationNo":stationNo])
        self.tabBarController!.selectedIndex = 1
    }
}
