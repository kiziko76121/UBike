//
//  MapViewController.swift
//  UBike
//
//  Created by Mojo on 2019/8/19.
//  Copyright © 2019 Mojo. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mainMapView: MKMapView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var sbiLabel: UILabel!
    @IBOutlet weak var bempLabel: UILabel!
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    
    let common = Common.shared
    var manger = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.detailView.alpha = 0.9
        self.view.sendSubviewToBack(detailView)
        self.mainMapView.delegate = self
        self.mainMapView.showsUserLocation = true   //顯示user位置
        self.mainMapView.userTrackingMode = .follow  //隨著user移動
        
        guard CLLocationManager.locationServicesEnabled() else {
            return
        }
        // Ask user's permission
        self.manger.requestWhenInUseAuthorization()
        
        //start to update location
        self.manger.delegate = self
        self.manger.desiredAccuracy = kCLLocationAccuracyBest//設定為最佳精度
        self.manger.activityType = .automotiveNavigation
        self.manger.startUpdatingLocation() //開始update user位置
        
        self.loadUBikeData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //Remove annotations
        let annotations = self.mainMapView.annotations
        self.mainMapView.removeAnnotations(annotations)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func favoritePress(_ sender: UIButton) {
        if sender.title(for: .normal) == "unFavorite"{
            guard let image = UIImage(named: "favorite") else{
                return
            }
            sender.setImage(image, for: .normal)
            sender.setTitle("favorite", for: .normal)
            let moc = CoreDataHelper.shared.managedObjectContext()
            let favorite  = Favorite(context: moc)
            
            
            favorite.favoriteStationNo = self.common.datas[sender.tag].sno
            self.common.favorite.insert(favorite, at: 0) //放在陣列中最上面的位置
            
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
    
    @IBAction func refreshPress(_ sender: Any) {
        //Remove annotations
        let annotations = self.mainMapView.annotations
        self.mainMapView.removeAnnotations(annotations)
        self.loadUBikeData()
    }
    
    func loadUBikeData(){
        self.common.getUBikeDatasFromWeb()
            for station in self.common.datas{
                self.addAnnotationtoMapView(station: station)
            }
        
    }
    
    func addAnnotationtoMapView(station:Station){
        let sno = station.sno
        let sna = station.sna
        let ar = station.ar
        guard let latitude = Double(station.lat),
            let longitude = Double(station.lng),
            let sbi = Int(station.sbi),
            let bemp = Int(station.bemp) else{
                return
        }
        
        
        
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let annotation = UBikeAnnotation(coordinate:coordinate)

        annotation.title = sno
        annotation.sno = sno
        annotation.sna = sna
        annotation.address = ar
        annotation.latitude = latitude
        annotation.longitude = longitude
        annotation.sbi = sbi
        annotation.bemp = bemp
        
        if sbi <= 3 {
            annotation.subtitle = "orange"
        }else if bemp <= 3{
            annotation.subtitle = "red"
        }else{
            annotation.subtitle = "green"
        }

        self.mainMapView.addAnnotation(annotation)

    }

}

//MARK: CLLocationManagerDelegate
extension MapViewController : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    }
}

//MARK:MKMapViewDelegate
extension MapViewController: MKMapViewDelegate{
    //build annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation
        {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "AnnotationView") as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
            
        }
        
        if let subtitle = annotation.subtitle, subtitle != nil {
            
            switch subtitle {
            case "red":
                annotationView?.markerTintColor = #colorLiteral(red: 1, green: 0.2705882353, blue: 0.2274509804, alpha: 1)
            case "orange":
                annotationView?.markerTintColor = #colorLiteral(red: 1, green: 0.6235294118, blue: 0.03921568627, alpha: 1)
            default:
                annotationView?.markerTintColor = #colorLiteral(red: 0.1960784314, green: 0.8431372549, blue: 0.2941176471, alpha: 1)
            }
        }

        annotationView?.glyphImage = UIImage(named: "bike")
        annotationView?.titleVisibility = .hidden
        annotationView?.subtitleVisibility = .hidden
        annotationView?.canShowCallout = true
        
        return annotationView
    }
    
    //MARK: into Annotation
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView){
        guard view.annotation?.title != "My Location" else{
            return
        }
        self.view.bringSubviewToFront(self.detailView)
        let annotation = view.annotation as! UBikeAnnotation

        guard let sbi = annotation.sbi,let bemp = annotation.bemp,
            let sna = annotation.sna,let address = annotation.address,
        let sno = annotation.sno else{
                return
        }
        self.sbiLabel.text = "\(sbi)"
        self.bempLabel.text = "\(bemp)"
        self.stationNameLabel.text = "\(sna)"
        self.addressLabel.text = "\(address)"
        
        if self.common.checkIsFavorite(value: sno){
            self.favoriteButton.setTitle("favorite", for: .normal)
            self.favoriteButton.setImage(UIImage(named: "favorite"), for: .normal)
        }else{
            self.favoriteButton.setTitle("unFavorite", for: .normal)
            self.favoriteButton.setImage(UIImage(named: "unFavorite"), for: .normal)
        }
    }
    
    //leave Annotation
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView){

        self.view.sendSubviewToBack(detailView)
    }
}
