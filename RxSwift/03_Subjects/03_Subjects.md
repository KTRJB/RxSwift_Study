```swift
import UIKit
import RxSwift
import RxRelay

class ViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        testPublishSubject()
//        testBehaviorSubject()
//        testReplaySubject()
//        testAsyncSubject()
        example_BehaviorRelay()
    }
    
    private func testPublishSubject() {
        let subject = PublishSubject<String>()
        subject.onNext("Is anyone listening?")
        
        let subscriptionOne = subject
            .subscribe(onNext: { (string) in
                print(string)
            })
        subject.on(.next("1"))  //One -  1
        subject.onNext("2") //One -  2
        
        // 1
        let subscriptionTwo = subject
            .subscribe({ (event) in
                print("2)", event.element ?? event)
            })
        
        // 2
        subject.onNext("3") // One - 3, 2) 3
        
        // 3
        subscriptionOne.dispose()
        subject.onNext("4") // 2) 4
        
        // 4
        subject.onCompleted()   // 2) completed
        
        // 5
        subject.onNext("5")
        
        // 6
        subscriptionTwo.dispose()
        
        let disposeBag = DisposeBag()
        
        // 7
        subject
            .subscribe {
                print("3)", $0.element ?? $0)   // 3) complete
            }
            .disposed(by: disposeBag)
        
        subject.onNext("?")
    }
    
    private func testBehaviorSubject() {
        let subject = BehaviorSubject(value: "Initial value")

        subject
             .subscribe{ event in
                 print("1)", event.element ?? event)    // 1) Initial value
             }
             .disposed(by: disposeBag)

        subject.onNext("X") // 1) X
        
        

        subject
             .subscribe { event in
                 print("2)", event.element ?? event)    // 2) X
             }
             .disposed(by: disposeBag)
        
        subject.onError(MyError.anError) //1) error,  2) error
    }
    
    private func testReplaySubject() {
        let subject = ReplaySubject<String>.create(bufferSize: 2)

        subject.onNext("1")
        subject.onNext("2")
        subject.onNext("3")
        
        subject
             .subscribe { event in
                 print("1)", event.element ?? event)    // 1) 2, 1) 3
             }
             .disposed(by: disposeBag)

        subject
             .subscribe { event in
                 print("2)", event.element ?? event)    // 2) 2, 2) 3
             }
             .disposed(by: disposeBag)
        
        subject.onNext("4") // 1) 4, 2) 4
        
        subject.onError(MyError.anError)    // 1) error, 2) error
//        subject.dispose()
        
        subject
            .subscribe { event in
                print("3)", event.element ?? event) // 3) 3, 3) 4, 3) error
            }
            .disposed(by: disposeBag)
    }
    
    private func testAsyncSubject() {
        let subject = AsyncSubject<Int>()
        
        subject.onNext(1)
        
        subject
            .subscribe { event in
                print("1)", event.element ?? event)
            }
            .disposed(by: disposeBag)
        
        subject.onNext(2)
        
        subject
            .subscribe { event in
                print("2)", event.element ?? event)
            }
            .disposed(by: disposeBag)
        
        subject.onNext(3)
        
        subject.onCompleted()   // 1) 3, 2) 3, 1) completed, 2) completed
    }
    
    func example_BehaviorRelay() {
        let behaviorRelay = BehaviorRelay(value: "Initial Value")
        let disposeBag = DisposeBag()
        
        behaviorRelay.accept("New Initial Value")
        
        behaviorRelay
            .subscribe { event in
                print("1)", event.element ?? event)   // 1) New Initial Value
            }
            .disposed(by: disposeBag)
        
        behaviorRelay.accept("1")   // 1) 1
        behaviorRelay
            .subscribe { event in
                print("2)", event.element ?? event) // 2) 1
            }
            .disposed(by: disposeBag)
        
        behaviorRelay.accept("2")   // 1) 2, 2) 2
    }
}

enum MyError: Error {
    case anError
}
```
