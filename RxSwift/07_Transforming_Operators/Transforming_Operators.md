```swift
import UIKit
import RxSwift
import RxRelay

class ViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        challenges()
    }
    
    func toArray() {
        let disposeBag = DisposeBag()
        
        Observable.of("A", "B", "C")
            .toArray()
            .subscribe {
                print($0)
            }
            .disposed(by: disposeBag)
        
        // Prints:["A", "B", "C"]
    }
    
    func map() {
        let disposeBag = DisposeBag()
             
        Observable.of(1, 2, 3, 4, 5, 6)
            .enumerated()
            .map { index, interger in
                index > 2 ? interger * 2 : interger
            }
            .subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
    }
    
    func flatMap() {
        let yeton = Student(score: BehaviorSubject(value: 80))
        let groot = Student(score: BehaviorSubject(value: 90))
             
        let student = PublishSubject<Student>()
             
        student
            .flatMap {
                $0.score
            }
            .subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
             
        student.onNext(yeton)    // Printed: 80
             
        yeton.score.onNext(85)   // Printed: 80 85
             
        student.onNext(groot)   // Printed: 80 85 90
             
        yeton.score.onNext(95)   // Printed: 80 85 90 95
             
        groot.score.onNext(100) // Printed: 80 85 90 95 100
    }
    
    func flatMapLatest() {
        let yeton = Student(score: BehaviorSubject(value: 80))
        let groot = Student(score: BehaviorSubject(value: 90))
            
        let student = PublishSubject<Student>()
             
        student
            .flatMapLatest {
                $0.score
            }
            .subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
             
        student.onNext(yeton)    // Printed: 80
             
        yeton.score.onNext(85)   // Printed: 80 85
             
        student.onNext(groot)   // Printed: 80 85 90
             
        yeton.score.onNext(95)
             
        groot.score.onNext(100) // Printed: 80 85 90 100
    }
    
    func materializeAnddematerialize() {
        let disposeBag = DisposeBag()
        
        let yeton = Student(score: BehaviorSubject(value: 80))
        let groot = Student(score: BehaviorSubject(value: 100))
        
        let student = BehaviorSubject(value: yeton)
        
        let studentScore = student
            .flatMapLatest {
                $0.score.materialize()
            }
        
        studentScore
            .filter {
                guard $0.error == nil else {
                    print($0.error!)
                    return false
                }

                return true
            }
            .dematerialize()
            .subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
        
        yeton.score.onNext(85)
        yeton.score.onError(MyError.anError)
        yeton.score.onNext(90)
        
        student.onNext(groot)
    }
    
    // 클로저들
    let contacts = [
      "603-555-1212": "Florent",
      "212-555-1212": "Junior",
      "408-555-1212": "Marin",
      "617-555-1212": "Scott"
    ]
    
    let convert: (String) -> Int? = { value in
      if let number = Int(value),
        number < 10 {
        return number
      }

      let convert: [String: Int] = [
        "abc": 2, "def": 3, "ghi": 4,
        "jkl": 5, "mno": 6, "pqrs": 7,
        "tuv": 8, "wxyz": 9
      ]

      var converted: Int? = nil

      convert.keys.forEach {
        if $0.contains(value.lowercased()) {
          converted = convert[$0]
        }
      }

      return converted
    }
    
    let format: ([Int]) -> String = {
      var phone = $0.map(String.init).joined()

      phone.insert("-", at: phone.index(
        phone.startIndex,
        offsetBy: 3)
      )

      phone.insert("-", at: phone.index(
        phone.startIndex,
        offsetBy: 7)
      )

      return phone
    }

    lazy var dial: (String) -> String = {
        if let contact = self.contacts[$0] {
        return "Dialing \(contact) (\($0))..."
      } else {
        return "Contact not found"
      }
    }
    
    func challenges() {
        let disposeBag = DisposeBag()
        let subject = PublishSubject<String>()
        
        subject.map(convert)
            .flatMap {
                $0 == nil ? Observable.empty() : Observable.just($0!)
            }.skip(while: { $0 == 0 })
            .take(10)
            .toArray()
            .map(format)
            .map(dial)
            .subscribe({
                print($0)
            })
            .disposed(by: disposeBag)
        
        subject.onNext("")
        subject.onNext("0")
        subject.onNext("408")
        subject.onNext("6")
        subject.onNext("")
        subject.onNext("0")
        subject.onNext("3")


        "KJL1A1B".forEach {
            subject.onNext("\($0)")
        }

        subject.onNext("9")
    }
}

enum MyError: Error {
    case anError
}

struct Student {
    var score: BehaviorSubject<Int>
}
```
