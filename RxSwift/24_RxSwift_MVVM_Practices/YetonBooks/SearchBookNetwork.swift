//
//  SearchBookNetwork.swift
//  YetonBooks
//
//  Created by 이예은 on 2023/03/19.
//

import RxSwift
import Foundation


enum SearchNetworkError: Error {
    case invalidURL
    case invalidJson
    case networkError
}

class SearchBookNetwork {
    private let session: URLSession
    let api = SearchBookAPI()
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func searchBook(query: String) -> Single<Book> {
        let request = api.configureRequest(query: query)
        
        return session.rx.response(request: request)
            .filter { response, _ in
                200..<300 ~= response.statusCode
            }
            .map { _, data in
                try JSONDecoder().decode(Book.self, from: data)
            }
            .asSingle()
    }
}
