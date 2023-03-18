//
//  URLSession+Rx.swift
//  KakaoBookSearch
//
//  Created by 전민수 on 2023/03/18.
//

import Foundation
import RxSwift
import SwiftyJSON

private var internalCache = [String: Data]()

enum RxURLSessionError: Error {
    case unknown
    case invalidResponse(response: URLResponse)
    case requestFailed(response: HTTPURLResponse, data: Data?)
    case deserializationFailed
}

extension ObservableType where Element == (HTTPURLResponse, Data) {
    func cache() -> Observable<Element> {
        return self.do(onNext: { (response, data) in
            if let url = response.url?.absoluteString, 200..<300 ~= response.statusCode {
                internalCache[url] = data
            }
        })
    }
}

extension Reactive where Base: URLSession {
    private func response(request: URLRequest) -> Observable<(HTTPURLResponse, Data)> {
        return Observable.create { observer in
            let task = self.base.dataTask(with: request) { data, response, error in
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

            return Disposables.create(with: task.cancel)
        }
    }

    private func data(request: URLRequest) -> Observable<Data> {
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

    func json(request: URLRequest) -> Observable<JSON> {
        return data(request: request).map { data in
            return try JSON(data: data)
        }
    }
}
