//
//  APIManager.swift
//  BookSearch
//
//  Created by 김주영 on 2023/03/19.
//

import UIKit
import RxCocoa
import RxSwift

final class APIManager {
    static let shared = APIManager()
    private let session = URLSession.shared
    
    private init() { }
    
    func requestBookSearch(with query: String) -> Observable<BookList> {
        guard let request = BookRequest(query: ["query": query]).request else {
            return Observable.empty()
        }
        
        return session.rx.response(request: request)
            .filter { response, _ in
                200..<300 ~= response.statusCode
            }
            .map { _, data in
                try JSONDecoder().decode(BookList.self, from: data)
            }
    }
    
    func requestImage(with url: String) -> Observable<UIImage?> {
        guard let url = URL(string: url) else {
            return Observable<UIImage?>.just(nil)
        }
        let request = URLRequest(url: url)
        return session.rx.data(request: request)
            .map { UIImage(data: $0) }
    }
}

