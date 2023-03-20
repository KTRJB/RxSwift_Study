//
//  ViewModel.swift
//  RxSwift_KakaoBookSearchAPI
//
//  Created by Groot on 2023/03/17.
//

import Foundation
import RxSwift
import RxCocoa

class ViewModel {
    let disposeBag = DisposeBag()
    let searchBarText = BehaviorRelay<String?>(value: nil)
    let sortDocument = PublishRelay<ViewController.Sort>()
    let isEndLoading = PublishRelay<Bool>()
    let _documents = BehaviorRelay<[Document]>(value: [])
    var documents: Observable<[Document]> {
        _documents.asObservable()
    }
    
    private var data = [Document]() {
        willSet {
            self._documents.accept(newValue)
        }
    }
    
    init() {
        self.searchBarText
            .skip(2)
            .filter { !$0!.isEmpty }
            .subscribe { text in
                self.isEndLoading.accept(false)
                self.search(title: text, pageNumber: 1)
            }.disposed(by: disposeBag)
        
        self.sortDocument
            .asObservable()
            .skip(1)
            .subscribe(onNext: { value in
                switch value {
                case .date:
                    self.data.sort { $0.dateTime > $1.dateTime }
                case .price:
                    self.data.sort { $0.salePrice > $1.salePrice }
                }
            }).disposed(by: disposeBag)
    }
    
    private func search(title: String?, pageNumber: Int) {
        let request = KakaoAPI.settingURL(serchTitle: title, page: pageNumber)
        
        URLSession.shared.rx.response(request: request)
            .map({ (response: HTTPURLResponse, data: Data) -> SearchResult? in
                if 200..<300 ~= response.statusCode {
                    return try JSONDecoder().decode(SearchResult.self, from: data)
                }
                
                return nil
            })
            .subscribe(onNext: { result in
                guard let result = result else { return }
                
                self.data = result.documents.sorted { $0.salePrice > $1.salePrice }
                self.isEndLoading.accept(true)
            }, onError: { error in
                print(error)
            }).disposed(by: disposeBag)
    }
}

enum KakaoAPI {
    private static let endpoint = "https://dapi.kakao.com/v3/search/book"
    private static let privateKey = "0c0aa993f7e79c1610542f4bfd6e1365"
    private static let headerKey = "Authorization"
    private static let headerValue = "KakaoAK " + privateKey
    
    static func settingURL(serchTitle: String?, page: Int? = 1) -> URLRequest {
        var url = URL(string: endpoint)!
        url.append(queryItems: [URLQueryItem(name: "target", value: "title")])
        url.append(queryItems: [URLQueryItem(name: "query", value: serchTitle)])
        url.append(queryItems: [URLQueryItem(name: "size", value: "50")])
        url.append(queryItems: [URLQueryItem(name: "page", value: page?.description)])
        
        var request = URLRequest(url: url)
        request.setValue(headerValue, forHTTPHeaderField: headerKey)
        
        return request
    }
}
