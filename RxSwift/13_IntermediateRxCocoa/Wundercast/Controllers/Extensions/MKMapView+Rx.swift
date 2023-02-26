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

import Foundation
import MapKit
import RxSwift
import RxCocoa

extension MKMapView: HasDelegate {
    public typealias Delegate = MKMapViewDelegate
}

class RxMKMapViewDelegateProxy: DelegateProxy<MKMapView, MKMapViewDelegate>, DelegateProxyType, MKMapViewDelegate {
    
    public weak private(set) var mapView: MKMapView?
    
    public init(mapView: ParentObject) {
        self.mapView = mapView
        super.init(parentObject: mapView, delegateProxy: RxMKMapViewDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        self.register { RxMKMapViewDelegateProxy(mapView: $0) }
    }
}

extension Reactive where Base: MKMapView {
    public var delegate: DelegateProxy<MKMapView, MKMapViewDelegate> {
        return RxMKMapViewDelegateProxy.proxy(for: base)
    }
    
    // MARK: D.2
//    public func setDelegate(_ delegate: MKMapViewDelegate) -> Disposable {
//        return RxMKMapViewDelegateProxy.installForwardDelegate(
//            delegate,
//            retainDelegate: false,
//            onProxyForObject: self.base
//        )
//    }
    
    // MARK: D.5 overlays 바인딩 Observer
//    var overlays: Binder<[MKOverlay]> {
//        return Binder(self.base) { mapView, overlays in
//            mapView.removeOverlays(mapView.overlays)
//            mapView.addOverlays(overlays)
//        }
//    }
    
    // MARK: D.7 사용자가 새로운 지역으로 지도를 drag할 때마다 호출
//    public var regionDidChangeAnimated: ControlEvent<Bool> {
//        let source = delegate
//            .methodInvoked(#selector(MKMapViewDelegate.mapView(_:regionDidChangeAnimated:)))
//            .map { parameters in
//                return (parameters[1] as? Bool) ?? false
//            }
//        return ControlEvent(events: source)
//    }
    
    // MARK: Challenge 1
//    public var givenLocation: Binder<CLLocationCoordinate2D> {
//        return Binder(self.base) { map, location in
//            let span = MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
//            map.region = MKCoordinateRegion(center: location, span: span)
//        }
//    }
}
