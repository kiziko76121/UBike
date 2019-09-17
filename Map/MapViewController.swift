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
    var stationNo = ""
    var tempAnnotation : MKAnnotation?
    var intoAnnotation : UBikeAnnotation?
    var nowLocation : CLLocationCoordinate2D?
    var tempLatitude = 0.0
    var tempLongitude = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        // Do any additional setup after loading the view.
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(self.selectAnnotation(notification:)), name: Notification.Name("selectAnnotation"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.stationNo == ""{
            self.loadUBikeData()
        }else{
            for station in self.common.datas{
                let sno = station.sno
                guard let latitude = Double(station.lat),
                    let longitude = Double(station.lng) else{
                        print("Transformation lat,lng error")
                        return
                }
                if self.stationNo == sno{
                    self.tempLatitude = latitude
                    self.tempLongitude = longitude
                    break
                }
            }
            self.loadUBikeData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //Remove annotations
        let annotations = self.mainMapView.annotations
        self.mainMapView.removeAnnotations(annotations)
        self.tempAnnotation = nil
        self.stationNo = ""
    }
    
    @objc  func selectAnnotation(notification :  Notification){
        self.stationNo = notification.userInfo?["stationNo"] as! String
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
        guard let intoAnnotation = self.intoAnnotation else{
            return
        }
        if sender.title(for: .normal) == "unFavorite"{
            guard let image = UIImage(named: "favorite") else{
                return
            }
            sender.setImage(image, for: .normal)
            sender.setTitle("favorite", for: .normal)
            let moc = CoreDataHelper.shared.managedObjectContext()
            let favorite  = Favorite(context: moc)
            
           
            favorite.favoriteStationNo = intoAnnotation.sno
            favorite.sarea = intoAnnotation.sarea
            self.common.favorite.insert(favorite, at: 0) //放在陣列中最上面的位置
            self.common.saveToCoreData()
        }else{
            guard let image = UIImage(named: "unFavorite") else{
                return
            }
            sender.setImage(image, for: .normal)
            sender.setTitle("unFavorite", for: .normal)
            
            for index in 0..<self.common.favorite.count{
                if self.common.favorite[index].favoriteStationNo == intoAnnotation.sno{
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
        DispatchQueue.global().async {
            self.common.getUBikeDatasFromWeb()
            DispatchQueue.main.async {
                for station in self.common.datas{
                    self.addAnnotationtoMapView(station: station)
                }
                if self.stationNo != ""{
                    self.selectAnnotationFromList()
                }
            }
        }
    }
    
    func selectAnnotationFromList(){
//        print("selectAnnotationFromList")
        
            guard let annotation = self.tempAnnotation else{
                return
            }
//            print("Zooming in on annotation")
            self.mainMapView.selectAnnotation(annotation, animated: true)
            //Zooming in on annotation
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
            self.mainMapView.setRegion(region, animated: true)
           
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                self.stationNo = ""
                self.tempLatitude = 0.0
                self.tempLongitude = 0.0
            })
    }
    
    func addAnnotationtoMapView(station:Station){
        let sno = station.sno
        let sna = station.sna
        let ar = station.ar
        let sarea = station.sarea
        guard let latitude = Double(station.lat),
            let longitude = Double(station.lng),
            let sbi = Int(station.sbi),
            let bemp = Int(station.bemp) else{
                print("Transformation lat,lng,sbi,bemp error")
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
        annotation.sarea = sarea
        
        if sbi <= 3 {
            annotation.subtitle = "lessBike"
        }else if bemp <= 3{
            annotation.subtitle = "fullBike"
        }else{
            annotation.subtitle = "internal"
        }
        
        
        let annotations = self.mainMapView.annotations
       
        
        if self.stationNo == "",let nowLocation = self.nowLocation{
            
            if (latitude > nowLocation.latitude + 0.01 ||
                latitude < nowLocation.latitude - 0.01 ||
                longitude > nowLocation.longitude + 0.01 ||
                longitude < nowLocation.longitude - 0.01)
            {
                for ant in annotations {
                    if !(ant is MKUserLocation){
                        let uBikeAnnotation = ant as! UBikeAnnotation
                        if uBikeAnnotation.sno == annotation.sno{
                            self.mainMapView.removeAnnotation(uBikeAnnotation)
                        }
                    }
                }
                return
            }
        }else if self.stationNo != ""{
            if (latitude > self.tempLatitude + 0.01 ||
                latitude < self.tempLatitude - 0.01 ||
                longitude > self.tempLongitude + 0.01 ||
                longitude < self.tempLongitude - 0.01)
            {
                return
            }
        }
        
        if self.stationNo == sno{
            self.tempAnnotation = annotation
        }
        
        for ant in annotations {
            if !(ant is MKUserLocation){
                let uBikeAnnotation = ant as! UBikeAnnotation
                if uBikeAnnotation.sno == annotation.sno{
                    uBikeAnnotation.bemp = annotation.bemp
                    uBikeAnnotation.sbi = annotation.sbi
                    return
                }
            }
        }
        
        self.mainMapView.addAnnotation(annotation)
        

    }

}

//MARK: CLLocationManagerDelegate
extension MapViewController : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    }
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        

//        print("center.latitude=\(mapView.region.center.latitude)") //目前緯度
//        print("center.longitude=\(mapView.region.center.longitude)") //目前經度
        if self.stationNo == ""{
//            let annotations = self.mainMapView.annotations
//            self.mainMapView.removeAnnotations(annotations)
            self.nowLocation = mapView.region.center

            self.loadUBikeData()
        }
//        self.selectAnnotationFromList()

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
            case "lessBike":
                annotationView?.markerTintColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
            case "fullBike":
                annotationView?.markerTintColor = #colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 1)
            default:
                annotationView?.markerTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            }
        }

        annotationView?.glyphImage = UIImage(named: "bike")
        annotationView?.titleVisibility = .hidden
        annotationView?.subtitleVisibility = .hidden
        annotationView?.canShowCallout = true
        
        return annotationView
    }
//    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
////        print(mapView.annotations)
//        self.mainMapView?.showAnnotations(mapView.annotations, animated: true)
//    }
    
    //MARK: into Annotation
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView){
        guard view.annotation?.title != "My Location" else{
            return
        }
        self.view.bringSubviewToFront(self.detailView)
        let annotation = view.annotation as! UBikeAnnotation
        
        self.intoAnnotation = annotation

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
