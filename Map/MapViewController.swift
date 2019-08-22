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
//        if let image = UIImage(named: "follow.png") {
//            self.userTrackingMode.setImage(editImage.thumbnailImage(image: image, width: 40, height: 40, circle: true,background: false), for: .normal)
//        }
//        self.isFollow = true
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

//        let coordinate = CLLocationCoordinate2DMake(25.026021, 121.50424309)
//        let annotation = UBikeAnnotation(coordinate:coordinate)
//        
//        self.mainMapView.addAnnotation(annotation)
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
//        annotation.coordinate =  coordinate
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
//        guard let coordinate = locations.last?.coordinate else {
//            return
//        }
//        self.latitude = coordinate.latitude
//        self.longitude = coordinate.longitude
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
            //            annotationView?.image = UIImage(named: subtitle!)
            
            switch subtitle {
            case "red":
                annotationView?.markerTintColor = #colorLiteral(red: 1, green: 0.2705882353, blue: 0.2274509804, alpha: 1)
            case "orange":
                annotationView?.markerTintColor = #colorLiteral(red: 1, green: 0.6235294118, blue: 0.03921568627, alpha: 1)
            default:
                annotationView?.markerTintColor = #colorLiteral(red: 0.1960784314, green: 0.8431372549, blue: 0.2941176471, alpha: 1)
            }
        }
        
//        var imageName = "BarIcon.png"
//        for userTracking in self.userTrackings{
//            if(userTracking.storeID == annotation.title){
//                imageName = "Love.png"
//                annotationView?.markerTintColor = UIColor.red
//                annotationView?.displayPriority = .defaultHigh
//                break
//            }
//        }
//
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
//        guard let title = annotation.title as? String else{
//            assertionFailure("Fail to get annotation?.title.")
//            return
//        }
        guard let sbi = annotation.sbi,let bemp = annotation.bemp,
            let sna = annotation.sna,let address = annotation.address else{
                return
        }
        self.sbiLabel.text = "\(sbi)"
        self.bempLabel.text = "\(bemp)"
        self.stationNameLabel.text = "\(sna)"
        self.addressLabel.text = "\(address)"
//        //load images
//        queryStoreImage(storeID:title)
        
//        for store in self.stores{
//            if store.storeID == title{
//                self.tempStore = store
//                self.storeNameLabel.text = store.storeName
//                self.storeAddressLabel.text = store.address
//                self.telLabel.text = store.tel
//                guard let avgFraction = store.avgFraction else{
//                    continue
//                }
//                guard avgFraction != 0 else{
//                    self.farctionLabel.text = "-"
//                    break
//                }
//                self.farctionLabel.text = String(avgFraction)
//                break
//            }
//        }
        
//        if checkIsUserTracking(value: title){
//            self.favoriteBtn.image = UIImage(named: "Favorite")
//        }else{
//            self.favoriteBtn.image = UIImage(named: "UnFavorite")
//        }
    }
    
    //leave Annotation
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView){
//        self.photos = []
//        self.tempAnnotation = nil
        self.view.sendSubviewToBack(detailView)
    }
}
