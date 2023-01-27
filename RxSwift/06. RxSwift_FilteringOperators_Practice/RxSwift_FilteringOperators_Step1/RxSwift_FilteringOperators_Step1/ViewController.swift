//
//  ViewController.swift
//  RxSwift_FilteringOperators_Step1
//
//  Created by 전민수 on 2023/01/27.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    var start = 0
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        let numbers = Observable<Int>.create { observer in
            let start = self.getStartNumber()

            observer.onNext(start)
            observer.onNext(start + 1)
            observer.onNext(start + 2)
            observer.onCompleted()

            return Disposables.create()
        }.share()

        numbers
            .subscribe(
                onNext: { element in
                    print("element [\(element)]")
                },
                onCompleted: {
                    print("=============")
                }
            )
            .disposed(by: bag)

        numbers
            .subscribe(
                onNext: { element in
                    print("element [\(element)]")
                },
                onCompleted: {
                    print("=============")
                }
            )
            .disposed(by: bag)
    }

    func getStartNumber() -> Int {
        start += 1

        return start
    }


}

