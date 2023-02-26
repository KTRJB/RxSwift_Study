/*
 * Copyright (c) 2014-2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import RxSwift
import RxCocoa
import MapKit
// MARK: C.1 CoreLocation import
//import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var geoLocationButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchCityName: UITextField!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    
    let bag = DisposeBag()
    
    // MARK: C.2 CLLocationManager 객체 생성
//    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: C.3 사용자에게 위치 정보 공유 허가
//        geoLocationButton.rx.tap
//            .subscribe(onNext: { _ in
//                self.locationManager.requestWhenInUseAuthorization()
//                self.locationManager.startUpdatingLocation()
//            })
//            .disposed(by: bag)

        // MARK: C.4 사용자의 위치를 받고 있는지 확인하는 임시 코드
//        locationManager.rx.didUpdateLocations
//            .subscribe(onNext: { (locations) in
//                print(locations)
//            })
//            .disposed(by: bag)

        // MARK: C.5 유효한 위치를 받아오는 Observable
//        let currentLocation = locationManager.rx.didUpdateLocations
//            .map { (locations) in
//                return locations[0]
//            }
//            .filter { (location) in
//                return location.horizontalAccuracy < kCLLocationAccuracyHundredMeters
//            }

        // MARK: C.6 현재 데이터를 이용하여 날씨 업데이트 하기
//        let geoInput = geoLocationButton.rx.tap.asObservable()
//            .do(onNext: {
//                self.locationManager.requestWhenInUseAuthorization()
//                self.locationManager.startUpdatingLocation()
//            })
//
//        let geoLocation = geoInput.flatMap {
//            return currentLocation.take(1)
//        }
//
//        let geoSearch = geoLocation.flatMap { (location) in
//            return ApiController.shared.currentWeather(lat: location.coordinate.latitude,
//                                                       lon: location.coordinate.longitude)
//            .catchAndReturn(ApiController.Weather.dummy)
//        }
                
        // MARK: D.1 map view 버튼을 누르면 지도가 표시 or 사라지도록
//        mapButton.rx.tap
//            .subscribe(onNext: {
//                self.mapView.isHidden = !self.mapView.isHidden
//            })
//            .disposed(by: bag)

        // MARK: D.3 delegete 설정
//        mapView.rx.setDelegate(self)
//            .disposed(by: bag)
//
        style()
    
        let search = searchCityName.rx.controlEvent(.editingDidEndOnExit).asObservable()
                    .map { self.searchCityName.text }
                    .flatMap { text in
                        return ApiController.shared.currentWeather(city: text ?? "Error")
                        }
                    .asDriver(onErrorJustReturn: ApiController.Weather.empty)
        
        // MARK: B.1 검색할 동안 activity indicator 표시하기
//        let searchInput = searchCityName.rx.controlEvent(.editingDidEndOnExit).asObservable()
//            .map { self.searchCityName.text }
//            .filter { ($0 ?? "").count > 0 }
//
//        let search = searchInput.flatMap { text in
//            return ApiController.shared.currentWeather(city: text ?? "Error")
//                .catchAndReturn(ApiController.Weather.dummy)
//        }
//            .asDriver(onErrorJustReturn: ApiController.Weather.dummy)
        
        
        // MARK: C.7
//        let textSearch = searchInput.flatMap { text in
//            return ApiController.shared.currentWeather(city: text ?? "Error")
//                .catchAndReturn(ApiController.Weather.dummy)
//        }
        
        // MARK: D.8 regionDidChangeAnimated 이벤트에 반응하기
//        let mapInput = mapView.rx.regionDidChangeAnimated
//            .skip(1)
//            .map { (_) in
//                self.mapView.centerCoordinate
//            }

//        let mapSearch = mapInput.flatMap { (coordinate) in
//            return ApiController.shared.currentWeather(lat: coordinate.latitude, lon: coordinate.longitude)
//                .catchAndReturn(ApiController.Weather.dummy)
//        }
        
//        let search = Observable.from([textSearch,
//                                      geoSearch,
//                                      mapSearch
//                                     ])
//            .merge()
//            .asDriver(onErrorJustReturn: ApiController.Weather.dummy)
        
        
        // MARK: D.6 overlays 바인딩 사용
//        search.map { [$0.overlay()] }
//            .drive(mapView.rx.overlays)
//            .disposed(by: bag)
        
        // MARK: B.2 날씨 요청 이벤트 수신 Observable
//        let running = Observable.from([
//            searchInput.map { _ in true },
//            search.map { _ in false }.asObservable(),
//            // MARK: C.7
////            geoInput.map({ _ in true }),
//            // MARK: D.9
////            mapInput.map({ _ in true })
//        ])
//            .merge()
//            .startWith(true)
//            .asDriver(onErrorJustReturn: false)
       
        // MARK: B.
//        running
//            .skip(1)
//            .drive(activityIndicator.rx.isAnimating)
//            .disposed(by: bag)
//
//        running
//            .drive(tempLabel.rx.isHidden)
//            .disposed(by: bag)
//
//        running
//            .drive(humidityLabel.rx.isHidden)
//            .disposed(by: bag)
//
//        running
//            .drive(iconLabel.rx.isHidden)
//            .disposed(by: bag)
//
//        running
//            .drive(cityNameLabel.rx.isHidden)
//            .disposed(by: bag)
        
        search.map { "\($0.temperature)° C" }
            .drive(tempLabel.rx.text)
            .disposed(by: bag)
        
        search.map { $0.icon }
            .drive(iconLabel.rx.text)
            .disposed(by: bag)
        
        search.map { "\($0.humidity)%" }
            .drive(humidityLabel.rx.text)
            .disposed(by: bag)
        
        search.map { $0.cityName }
            .drive(cityNameLabel.rx.text)
            .disposed(by: bag)
        
        
        
        // MARK: Challenge 1
//        let geoAndTextSearch = Observable.from([geoSearch, textSearch])
//            .merge()
//            .asDriver(onErrorJustReturn: ApiController.Weather.dummy)
//
//        geoAndTextSearch.map({ $0.coordinate })
//            .drive(mapView.rx.givenLocation)
//            .disposed(by: bag)
        
        // MARK: Challenge 2
//        mapInput.flatMap { (location) in
//            return ApiController.shared.currentWeatherAround(lat: location.latitude, lon: location.longitude)
//                .catchAndReturn([])
//        }
//        .asDriver(onErrorJustReturn: [])
//        .map({ $0.map({ $0.overlay() }) })
//        .drive(mapView.rx.overlays)
//        .disposed(by: bag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        Appearance.applyBottomLine(to: searchCityName)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Style
    
    private func style() {
        view.backgroundColor = UIColor.aztec
        searchCityName.textColor = UIColor.ufoGreen
        tempLabel.textColor = UIColor.cream
        humidityLabel.textColor = UIColor.cream
        iconLabel.textColor = UIColor.cream
        cityNameLabel.textColor = UIColor.cream
    }
    
}

// D4. MKMapViewDelegate 채택
extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? ApiController.Weather.Overlay {
            let overlayView = ApiController.Weather.OverlayView(overlay: overlay, overlayIcon: overlay.icon)
            return overlayView
        }
        return MKOverlayRenderer()
    }
    
}

