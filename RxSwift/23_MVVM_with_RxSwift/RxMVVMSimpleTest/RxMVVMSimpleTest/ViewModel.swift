//
//  ViewModel.swift
//  RxMVVMSimpleTest
//
//  Created by Groot on 2023/03/12.
//

import RxSwift
import RxCocoa

//뷰모델들끼리 상호작용을 하므로, 추후에 상위 뷰모델이 생겼을 때 사용할 용도.
protocol ViewModel: ViewControllerBindable {
    
}

class MainViewModel: ViewModel {
    let labelText: Driver<String?>
    let upButtonTapped = PublishSubject<Void>()
    let downButtonTapped = PublishSubject<Void>()
    var actionOccurred = PublishSubject<ViewController.Action>()
    
    init(initialValue: Int) {
//        let delta = Observable
//            .merge(upButtonTapped.map { +1 }, downButtonTapped.map { -1 })
        
        let delta = actionOccurred
            .map { action -> Int in
                switch action {
                case .up: return 1
                case .down: return -1
                }
            }
        
        let number = delta
            .scan(initialValue, accumulator: +)
            .startWith(initialValue)
        
        self.labelText = number
            .map { String($0) }
            .asDriver(onErrorJustReturn: "error")
    }
}
