## **1. toArray**

독립적인 Observable 요소를 Array로 묶는 방법
![image](https://user-images.githubusercontent.com/102353787/217702601-ff596024-b411-4fb5-bbe1-24ad4cb68e76.png)
- Observable이 종료될 때까지 차단하고 있다가 하나의 객체로 방출

```swift
let disposeBag = DisposeBag()
 	
Observable.of("A", "B", "C")
 		.toArray()
 		.subscribe(onNext: {
 			print($0)
 		})
 		.disposed(by: disposeBag)
 		
 	// Prints:["A", "B", "C"]
```
<br>

### **2. map**

각 항목에 함수를 적용하여 Observable이 방출하는 항목을 변환

![image](https://user-images.githubusercontent.com/102353787/217702711-a2d93860-f62c-4c4b-8bee-20973a3b6b29.png)
- Swift Library의 map과 동일하게 동작

```swift
let disposeBag = DisposeBag()
     
let formatter = NumberFormatter()
formatter.numberStyle = .spellOut
     
Observable<NSNumber>.of(123, 4, 56)
     .map {
         formatter.string(from: $0) ?? ""
     }
     .subscribe(onNext: {
         print($0)
     })
     .disposed(by: disposeBag)
```
<br>

### **enumerated**

- 이벤트 값을 index와 함께 받음

```swift
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
         
/* Prints:
	1 2 3 8 10 12
*/
```
<br>

## **내부의 Observable 변환하기**

- '만약 Observable' 속성을 갖는 Observable은 어떻게 사용할 수 있을까?

```swift
struct Student {
     var score: BehaviorSubject<Int>
 }

let student = PublishSubject<Student>()
```
<br>

### **1. flatMap**

****Observable이 방출하는 항목을 Observable로 변환한 다음 방출을 단일 Observable로 평탄화****

![image](https://user-images.githubusercontent.com/102353787/217703212-0cdba247-c79a-4fc7-a0d1-fb45357dc95c.png)
![image](https://user-images.githubusercontent.com/102353787/217702860-8214e1fe-5fab-47c7-9858-92095de8637b.png)
- 여러 Observable Sequence에서 방출한 값을 하나의 Observable Sequence로 병합 방출

 ⇒ Observable의 방출을 병합하여 병합된 결과를 자체 시퀀스로 방출

```swift
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
```
<br>

### **2. flatMapLatest**

- `flatMap`에서 가장 최신의 값만을 확인하고 싶을 때
- `flatMapLatest` = `map` + `switchLatest`
    - `switchLatest`: 가장 최근의 observable 에서 값을 생성하고 이전 observable을 구독 해제

![image](https://user-images.githubusercontent.com/102353787/217703047-c6ec9582-ded7-4cb1-912d-fc83b97eb7b1.png)
![image](https://user-images.githubusercontent.com/102353787/217703294-3accb553-c816-4e48-82f2-d42f96d8d679.png)
- 최근의 Observable로만 Observable Sequence만 생성

```swift
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
```

- • `flatMapLatest`는 네트워킹 조작에서 가장 흔하게 사용
- 단어 검색 시 이전 검색 결과 (s, sw, swi, swif로 검색한 값)는 무시하고 swift 검색만 실행
<br>

## **이벤트 관찰하기**

- `observable`을 `observable의 이벤트`로 변환

```swift
let disposeBag = DisposeBag()
        
        let yeton = Student(score: BehaviorSubject(value: 80))
        let groot = Student(score: BehaviorSubject(value: 100))
        
        let student = BehaviorSubject(value: yeton)
        
        let studentScore = student
            .flatMapLatest {
                $0.score //.materialize()
            }
        
        studentScore
            .subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
        
        yeton.score.onNext(85)
        yeton.score.onError(MyError.anError) // 종료
        yeton.score.onNext(90)
        
        student.onNext(groot)
```

- error가 방출되면 `studentScore` 도 종료됨
- `materialize` - 각각의 방출되는 이벤트를 이벤트의 observable로 만들 수 있다.
![image](https://user-images.githubusercontent.com/102353787/217703402-f957f397-a550-49a9-8c0f-8a677d5c16d4.png)
- event는 받을 수 있지만 요소들은 받을 수 없다.
- `dematerialize` - 기존의 모양으로 되돌려주는 역할

![image](https://user-images.githubusercontent.com/102353787/217703426-16cd2c7d-19f4-4ac3-8e53-a88ab21dc5fd.png)
      
