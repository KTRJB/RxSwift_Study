//
//  SearchBookAPI.swift
//  YetonBooks
//
//  Created by 이예은 on 2023/03/19.
//

import Foundation

struct SearchBookAPI {
    static let scheme = "https"
    static let host = "dapi.kakao.com"
    static let path = "/v3/search/"
    
    func configureComponents(query: String) -> URLComponents {
        var components = URLComponents()
        components.scheme = SearchBookAPI.scheme
        components.host = SearchBookAPI.host
        components.path = SearchBookAPI.path + "book"
        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "sort", value: "accuracy"),
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "size", value: "20")
        ]
        
        return components
    }
    
    func configureRequest(query: String) -> URLRequest {
        var request = URLRequest(url: self.configureComponents(query: query).url!)
        request.httpMethod = "GET"
        request.setValue("KakaoAK d6dc4944217620ec1694d4865de94093", forHTTPHeaderField: "Authorization")
        
        return request
    }
}
