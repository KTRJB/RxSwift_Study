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

import RxSwift
import SwiftyJSON
import UIKit

// MARK: - B-3-1. 캐싱을 위한 딕셔너리 구현

private var internalCache = [String: Data]()

public enum RxURLSessionError: Error {
    case unknown
    case invalidResponse(response: URLResponse)
    case requestFailed(response: HTTPURLResponse, data: Data?)
    case deserializationFailed
}

// MARK: - B-3-2. Data Observable 캐싱을 위한 extension 구현

extension ObservableType where Element == (HTTPURLResponse, Data) {
    func cache() -> Observable<Element> {
        return self.do(onNext: { (response, data) in
            if let url = response.url?.absoluteString, 200..<300 ~= response.statusCode {
                internalCache[url] = data
            }
        })
    }
}

// MARK: - B-1. URLSession을 Rx로 확장

extension Reactive where Base: URLSession {
    // MARK: - B-2-1. response 함수 구현
    // URLRequest를 통해 HTTPURLResponse와 Data를 Observable 형태로 반환

    func response(request: URLRequest) -> Observable<(HTTPURLResponse, Data)> {
        return Observable.create { observer in
            // MARK: - B-2-2. 콜백과 Task 내부 구현

            // Base는 접근하려는 객체, .rx는 인터페이스 의미
            let task = self.base.dataTask(with: request) { data, response, error in
                // MARK: - B-2-4. Data를 정상적으로 반환하는지 확인 후 데이터 반환

                guard let response = response, let data = data else {
                    observer.onError(error ?? RxURLSessionError.unknown)
                    return
                }

                guard let httpResposne = response as? HTTPURLResponse else {
                    observer.onError(RxURLSessionError.invalidResponse(response: response))
                    return
                }

                observer.onNext((httpResposne, data))
                observer.onCompleted()
            }
            task.resume()

            // MARK: - B-2-3. 비동기작업으로 인한 리소스 낭비 방지

            return Disposables.create(with: task.cancel)
            //       일반적인 옵저버블의 경우에는 비동기작업이 없으니 따로 취소하지 않아도 시퀀스가 취소되면 모든 작업이 종료되니까 따로 동작이 필요없는 빈 disposable을 반환해주어도 됨
            //       만약 비동기 작업이 존재한다면 시퀀스가 중단되어도 escaping으로 구성된 비동기 작업은 계속 실행되므로 별도의 조치 필요
            //
            ////            1) Disposables은 내부에 구현이 아무것도 없는 구조체이다.
            ////            2) Disposable의 구체타입들은 파일 내부에 Disposables 의 Extension을 각각 가지고 있다.
            ////            3) Disposables.create에서 아무것도 하지 않으면 NopDisposable 인스턴스가 만들어진다. 이 인스턴스의 dispose는 아무것도 하지 않는다.
            ////            4) Disposables.create에 클로저를 하나 전달하면 AnonymousDisposable 인스턴스가 만들어진다. 이 인스턴스의 dispose는 생성될 때 등록해둔 클로저를 실행한다.
                        ///(출처: https://jeonyeohun.tistory.com/365)
        }
    }

    // MARK: - B-2-4. response 함수를 활용하여 각각의 Type 인스턴스를 반환하는 함수 구현
    // 구현 Type: Data, String, JSON, UIImage

    func data(request: URLRequest) -> Observable<Data> {
        // MARK: - B-3-3. cache 적용

        // url.absoluteString => 절대주소 (urlString과 동일)
        if let url = request.url?.absoluteString, let data = internalCache[url] {
            return Observable.just(data)
        }

        return response(request: request).cache().map { response, data -> Data in
            if 200..<300 ~= response.statusCode {
                return data
            } else {
                throw RxURLSessionError.requestFailed(response: response, data: data)
            }
        }
    }

    func string(request: URLRequest) -> Observable<String> {
        return data(request: request).map { data in
            return String(data: data, encoding: .utf8) ?? ""
        }
    }

    func json(request: URLRequest) -> Observable<JSON> {
        return data(request: request).map { data in
            return try JSON(data: data)
        }
    }

    func image(request: URLRequest) -> Observable<UIImage> {
        return data(request: request).map { data in
            return UIImage(data: data) ?? UIImage()
        }
    }
}
