### Observables 실습 - 그루트, 주디, 예톤, 수꿍
```swift
import UIKit
import RxSwift

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        makeObservableJust()
        //        makeObservableOf()
        //        makeObservableFrom()
        //        makeObservableEmpty()
        //        makeObservableNever()
        //        makeObservableRange()
        //        testDispose()
        //        testCreate()
        //        makeObservableFactory()
        //        makeSingle()
        //        testDo()
    }
    
    func makeObservableJust() {
        let observableNumber = Observable<Int>.just(1) // just는 단일값
        
        observableNumber.subscribe (onNext: { event in
            print(event) // print 1
        }).disposed(by: disposeBag)
        
        observableNumber.subscribe { event in
            print(event) // next(1), completed
        }.disposed(by: disposeBag)
        
        observableNumber.subscribe { event in
            if let element = event.element {
                print(element)
            } // 1만 출력
        }.disposed(by: disposeBag)
    }
    
    func makeObservableOf() {
        let observableNumbers = Observable<Int>.of(1, 2, 3) // of는 다중요소
        
        observableNumbers.subscribe (onNext: { event in
            print(event) // print 1, 2, 3 세번 출력
        }).disposed(by: disposeBag)
        
        
        let observableNumberArray = Observable.of([1, 2, 3]) // of에 배열로 넣으면 배열로 출력
        
        observableNumberArray.subscribe (onNext: { event in
            print(event) // print [1, 2, 3] 배열 출력
        }).disposed(by: disposeBag)
    }
    
    func makeObservableFrom() {
        let observableNumbersFrom = Observable<Int>.from([1, 2, 3])// 오직 array 만 취한다.
        
        observableNumbersFrom
            .subscribe(onNext: { int in
                print(int)
            },onError: { Error in
            },  onCompleted: {
                print("Complete")
            }).disposed(by: disposeBag)
        
        observableNumbersFrom.subscribe (onNext: { event in
            print(event) // print 1, 2, 3 세번 출력
        }).disposed(by: disposeBag)
    }
    
    func makeObservableEmpty() {
        let observableNumbersEmpty = Observable<Void>.empty() // onCompleted만 방출한다, 값이 0개임
        
        observableNumbersEmpty
            .subscribe(onNext: { Void in
                print(Void)
            },onError: { Error in
            },  onCompleted: {
                print("Complete")
            }).disposed(by: disposeBag)
    }
    
    func makeObservableNever() {
        let observableNumbersNever = Observable<Void>.never() // 아무것도 안함??, onCompleted도 방출하지 않음.
        
        observableNumbersNever
            .debug() // 구독하고 있는걸 알 수 있다
            .subscribe(onNext: { Void in
                print(Void)
            },onError: { Error in
            },  onCompleted: {
                print("Complete")
            }).disposed(by: disposeBag)
    }
    
    func makeObservableRange() {
        let observableNumbersRange = Observable<Int>.range(start: 1, count: 100000) // start부터 count만큼 1씩 증가하면서 데이터를 보내준다.
        
        observableNumbersRange
            .subscribe(onNext: { number in
                print(number)
            },onError: { Error in
            },  onCompleted: {
                print("Complete")
            }).disposed(by: disposeBag)
    }
    
    func testDispose() {
        let observable = Observable.of("A", "B", "C")
        let subscription = observable
            .debug()
            .subscribe({ (event) in
                print(event)
            })
        
        subscription.dispose()
    }
    
    func testCreate() {
        let observable = Observable<Int>.create { (observer) in
            observer.onNext(1)
            observer.onNext(2)
            observer.onNext(3)
            //            observer.onError(ObserverbleError.invalid) // error를 방출하면 onCompleted는 호출되지 않는다.
            observer.onCompleted()
            return Disposables.create()
        }
        
        observable
            .subscribe (onNext: { element in
                print(element)
            } , onError: { error in
                print(error)
            } , onCompleted: {
                print("Complete")
            }, onDisposed: {
                print("Disposed")
            }).disposed(by: disposeBag)
    }
    
    func makeObservableFactory() {
        var count = 0
        
        let noFactory = Observable<Int>.of(count)
        let factory: Observable<Int> = Observable.deferred { // deferred는 lazy var와 같은 느낌
            count += 1
            
            return Observable.of(count)
        }
        
        for _ in 0...3 {
            noFactory.subscribe(onNext: {
                print($0)
            }).disposed(by: disposeBag)
            
            factory.subscribe(onNext: {
                print($0)
            }).disposed(by: disposeBag)
        }
    }
    
    func makeSingle() {
        let single = Single<Int>.create { event in
            event(.success(1))
            event(.success(2)) // 출력되지 않는다. -> success를 호출하면 그 뒤로는 보내지 않고 끝나버림
            event(.failure(ObserverbleError.invalid))
            
            return Disposables.create()
        }
        
        single
            .debug()
            .subscribe (onSuccess: { number in
                print(number)
            }, onFailure: { error in
                print(error)
            }).disposed(by: disposeBag)
    }
    
    func testDo() {
        let observableNumbersNever = Observable<Void>.never() // 아무것도 안함??, onCompleted도 방출하지 않음.
        
        observableNumbersNever
            .do(onSubscribe: { print("Subscribed")} )// 구독하고 있는걸 알 수 있다
            .subscribe(onNext: { Void in
                print(Void)
            },onError: { Error in
            },  onCompleted: {
                print("Complete")
            }).disposed(by: disposeBag)
        
        let observable = Observable<Int>.create { (observer) in
            observer.onNext(1)
            observer.onNext(2)
            observer.onNext(3)
            //            observer.onError(ObserverbleError.invalid) // error를 방출하면 onCompleted는 호출되지 않는다.
            observer.onCompleted()
            return Disposables.create()
        }
        
        observable
            .do { number in print(number * 10) } // 구독전에 확인하는 용도?, Observable의 데이터에는 영향을 주지 않는다.
            .subscribe { event in
                print(event)
            }.disposed(by: disposeBag)
    }
    
    func makeURLSession(reqeust: URLRequest) -> Observable<Data> { // url session + Rx
        return Observable<Data>.create { completion in
            let task = URLSession.shared.dataTask(with: reqeust) { data, response, error in
                if let error = error {
                    completion.onError(error)
                }
                
                if let data = data {
                    completion.onNext(data)
                }
                
                completion.onCompleted()
            }
            
            task.resume()
            
            return Disposables.create()
        }
    }
}

enum ObserverbleError: Error {
    case invalid
}
```
