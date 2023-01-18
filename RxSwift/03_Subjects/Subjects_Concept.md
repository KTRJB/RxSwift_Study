## Subjects

실제 사용하는 방식은 실시간으로 **Observable**에 수동으로 값을 수동으로 추가하고 subscriber에게 방출

> Subjects = Observable + Observer
> 

> 값을 넘겨주기도 하고 밖에서 주입할 수 있는 양방향성 **Observable**
> 

- Observable의 값을 외부에서 변경하고 싶을 때
- Observable처럼 값을 받을 수 있고, 밖에서 값을 통제할 수도 있다
- 종류 : **PublishSubject**, **BehaviorSubject**, **AsyncSubject**, **ReplaySubject**
<br>

## PublishSubject

```swift
let subject = PublishSubject<String>()

subject.onNext("Is anyone listening?")

let subscriptionOne = subject
     .subscribe(onNext: { (string) in
         print(string)
})

subject.on(.next("1"))		//Print: 1

subject.onNext("2")		//Print: 2
```

- 데이터가 생기면 데이터를 그대로 방출
- `.on(.next(_:))`  새로운 `.next` 이벤트를 subject에 삽입 = `.onNext(_:)`와 동일
- 다른 subscriber가 또 subscribe할 수 있음
- subscribe하고 있는 모든 subscriber에게 다 보내줌

![image](https://user-images.githubusercontent.com/102353787/213176547-22a0a651-c4f2-42f3-9d39-441a5b56b0f8.png)


- 구독한 이후의 이벤트만 방출
    - 따라서 어떤 정보가 추가되었을 때 구독하지 않았다면 그 값을 얻을 수 없음
- 시간에 민감한 데이터를 모델링할 때 사용
- `.completed` 또는 `.error` 와 같은 종료 이벤트를 받으면 새 subscriber에겐 종료 이벤트를 방출
<br>

## **BehaviorSubjects**

- 초기값을 가지고 있음
- 누군가 subscribe하자마자 초기값을 보내줌
- 새로운 subscribe가 되면 변경된 가장 최근 값을 보내줌

![image](https://user-images.githubusercontent.com/102353787/213176670-2060fbed-579e-4c95-a4f3-10a343c06e15.png)

```swift
let subject = BehaviorSubject(value: "Initial value")

subject.onNext("X")

subject
     .subscribe{
         print(label: "1)", event: $0)
     }
     .disposed(by: disposeBag)

subject.onError(MyError.anError)

subject
     .subscribe {
         print(label: "2)", event: $0)
     }
     .disposed(by: disposeBag)
```

- 뷰를 가장 최신의 데이터로 미리 채울 때 적합 ex) 데이터를 가져오는 동안 최신 값으로 화면 표시
<br>

## ReplaySubject

- 한 명의 subscriber만 있을 때는 **PublishSubject**와 동일
- observer의 subscribe 시점과 관계 없이 모든 데이터를 방출(버퍼 사이즈를 정한 경우 버퍼 크기만큼)

![image](https://user-images.githubusercontent.com/102353787/213176832-6ad73e76-8d3d-4cda-9b2f-248d548fbd51.png)

- 버퍼처럼 메모리가 가지고 있기 때문에 이미지나 array 같이 큰 값을 가지는 것은 메모리에 엄청난 부하

```swift
let subject = ReplaySubject<String>.create(bufferSize: 2)

subject.onNext("1")
subject.onNext("2")

subject.onNext("3")

subject
     .subscribe {
         print(label: "1)", event: $0)
     }
     .disposed(by: disposeBag)

subject
     .subscribe {
        print(label: "2)", event: $0)
     }
     .disposed(by: disposeBag
```

- `error`로 종료해도 버퍼가 살아있어 이후 구독자에게 이벤트를 재방출할 수 있어 바로 dispose를 해줘야 함 → 에러 이벤트만 받게 함
- 최근 몇개의 값을 보여주고 싶을 때 사용 ex) 최근 검색어 보여주기
<br>

## **Variables**

- Observable의 현재값(**currentValue**)이 궁금할 때
- `BehaviorSubject`를 래핑하고, 이들의 현재값을 상태(**State**)로 보유 → 현재값을 `value`프로퍼티로 알 수 있음
- `.onNext(_:)`로 값을 추가하지 않음
- Subject와 다르게 에러가 발생하지 않음을 보장 = `.error` 이벤트를 추가할 수 없음
- 또한 할당 해제 시 자동적으로 종료되어 수동으로 `.completed` 할 수 없음

```swift
let variable = Variable("Initial value") // 초기값을 가짐
let disposeBag = DisposeBag()

variable.value = "New initial value" // 새로운 값 추가

variable.asObservable()   // asObservable로 구독
     .subscribe {
         print(label: "1)", event: $0)
     }
     .disposed(by: disposeBag)

variable.value = "1"

variable.asObservable()
     .subscribe {
         print(label: "2)", event: $0)
     }      
.disposed(by: disposeBag)

variable.value = "2"
```

- 업데이트 구독없이 그냥 현재값을 확인하고 싶을 때 일회성으로 적용될 수 있다
<br>

## AsyncSubject

- 누가 subscribe 해도 값을 안 보내줌
- completed 되는 시점에 모든 subscriber에게 가장 최근 값을 보내주고 completed

![image](https://user-images.githubusercontent.com/102353787/213176724-aa5a2e08-40a9-455c-be69-2953aa8d093e.png)

- 가장 마지막 값 = 가장 최신의 값만 필요할 때 사용
