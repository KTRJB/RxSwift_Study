# Scheduler
> ❗️사용자 지정 스케줄러(커스텀 스케줄러)의 내용은 다루지 않습니다. RxSwift, RxCocoa 및 RxBlocking에서 제공하는 스케줄러 및 이니셜라이저는 일반적으로 99%의 경우를 다룰 수 있으니 항상 내장된 스케줄러를 사용하십시오.

<br>

## **What is a scheduler?**

S**cheduler** 

> 프로세스가 발생하는 context
> 
- **context**: thread, dispatch queue 또는 OperationQueueScheduler에서 사용되는 Operation

<img src="https://user-images.githubusercontent.com/102353787/222945607-90b8729c-e511-469b-af9c-0337221f830d.png" width="500"/>


캐시 연산자를 이용할 때 Observable은 서버에 요청하고 데이터를 캐시에 저장하는 연산을 처리합니다. 그런 다음 데이터는 다른 스케줄러의 모든 구독자에게 전달되고 대부분 main thread인 MainScheduler에 위치하므로 UI 업데이트가 가능합니다.
<br>

## **Demystifying the scheduler**

**스케줄러**는 GCD의 dispatch queue와 유사하게 작동할 뿐 **스레드**와 동일하게 관련된다는 것은 오해입니다.

<img src="https://user-images.githubusercontent.com/102353787/222945612-48e60bc3-bcc3-4ae5-ac13-592460a79114.png" width="500"/>
<br>

## Scheduler Operator

경우에 따라 실행되는 스케줄러를 변경해야 할 수 있습니다. 


<img src="https://user-images.githubusercontent.com/102353787/222945644-b75516e4-a26c-4f4a-9e35-63f28688b876.png" width="500"/>

<img src="https://user-images.githubusercontent.com/102353787/222945651-179d8cb9-50ab-450c-abfd-16bfcfec0a85.png" width="500"/>


### **subscribeOn**

- `SubscribeOn`은 시퀀스를 어느 Scheduler에서 방출할 것인지를 결정합니다. 즉, 시퀀스의 시작점이 될 Scheduler를 결정할 수 있습니다.
- 해당 연산자가 호출되는 위치와 상관없이 Observable이 작동을 시작할 스레드를 지정

```swift
let fruit = Observable<String>.create { observer in
    observer.onNext("[apple]")
    sleep(2)
    observer.onNext("[pineapple]")
    sleep(2)
    observer.onNext("[strawberry]")
    return Disposables.create()
}

let globalScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global())

fruit
    .subscribeOn(globalScheduler)
    .subscribe(onNext: {
			print($0)
		})
    .disposed(by: db)
```
<br>

### O**bserveOn**

- `ObserveOn`은 시퀀스를 어느 Scheduler에서 observe할 것인지를 결정합니다. 각각의 Operator 동작을 다른 스케줄러에서 처리하고 싶을 때 사용할 수 있습니다.
- 해당 연산자 아래부터 사용할 스레드에 영향을 미칩니다

<img src="https://user-images.githubusercontent.com/102353787/222945662-901ad45f-a44e-4c3c-a8d4-31e844b88e83.png" width="500"/>


```swift
sequence1
  .observeOn(backgroundScheduler)
  .map { n in
      print("This is performed on the background scheduler")
  }
  .observeOn(MainScheduler.instance)
  .map { n in
      print("This is performed on the main scheduler")
  }
```
<br>

**subscribeOn은 Sequence가 생성될 때(=subscribe()가 호출될 때)의 스케줄러를 지정**

```swift
Observable<Int>.create { observer in
    observer.onNext(1)
    observer.onNext(2)
    
    print("Hi \(Thread.isMainThread ? "Main" : "Background")")
    
    observer.onCompleted()
    return Disposables.create()
}
.observe(on: MainScheduler.instance)
.subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
.subscribe(onNext: { el in
    print("onNext \(el) \(Thread.isMainThread ? "Main" : "Background")")
}, onDisposed: {(
    print("dispose \(Thread.isMainThread ? "Main" : "Background")")
)})
.disposed(by: disposeBag)
```

1. `.observeOn()` 로 그 다음에 오는 subscribe 안의 스케줄러를 main 스케줄러로 지정해줌.
2. `.subscribeOn()` 로 observable이 생성되는 스케줄러를 background로 지정해줌.
3. Dispose과정 또한 `SubscribeOn`으로 지정된 Scheduler에서 수행
<br>

참고: [RxSwift-scheduler-제대로-알아보기](https://sweepty.medium.com/rxswift-scheduler-%EC%A0%9C%EB%8C%80%EB%A1%9C-%EC%95%8C%EC%95%84%EB%B3%B4%EA%B8%B0-f2e26aeb829d)

<br>

## S**cheduler의 종류**

### **MainScheduler**

- main thread 위에 위치
- 사용자 인터페이스의 변경 사항을 처리하고 우선순위가 높은 다른 작업 수행 시 사용
- 이 스케줄러를 통해 장기적인 실행이 되는 서버 요청 또는 무거운 작업은 피해야 합니다
- `MainSchedule.instance`는 **synchronous**하게, `MainSchedule.asyncInstance`는 **asynchronous**하게 이벤트가 전달

### **SerialDispatchQueueScheduler**

- 직렬(serial) DispatchQueue에서 작업을 추상화
- ObserveOn을 사용할 때 최적화 이점이 있음
- MainScheduler도 SerialDispatchQueueScheduler의 일종

### **ConcurrentDispatchQueueScheduler**

- **SerialDispatchQueueScheduler**와 유사하게 DispatchQueue에서 작업을 관리
- 직렬 큐 대신 동시 큐를 사용

### **OperationQueueScheduler**

- DispatchQueue가 아닌 OperationQueue를 통해 작업을 관리
- 더 많은 제어가 필요할 수 있지만 DispatchQueue로는 수행할 수 없는 작업을 수행할 수 있음

### **TestScheduler**

- 테스트용으로만 사용하는 것으로 실제 코드에서는 사용하면 안 됩니다.
- RxTest 라이브러리의 일부로 operator 테스트를 단순화
<br>

---

**참고**
[RxSwift: Reactive Programming with Swift, Chapter 15: Intro to Schedulers](https://www.kodeco.com/books/rxswift-reactive-programming-with-swift/v4.0/chapters/15-intro-to-schedulers)
[ReactiveX-Scheduler](https://reactivex.io/documentation/scheduler.html)
