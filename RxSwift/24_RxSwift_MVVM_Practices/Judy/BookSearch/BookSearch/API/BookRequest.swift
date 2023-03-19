//
//  BookRequest.swift
//  BookSearch
//
//  Created by 김주영 on 2023/03/19.
//

import Foundation

struct BookRequest: Request {
    let baseURL: BaseURL
    let path: Path
    let httpMethod: HTTPMethod
    let headers: [String : String]?
    let query: [String : Any]?
    
    init(baseURL: BaseURL = .kakao,
         path: Path = .book,
         httpMethod: HTTPMethod = .get,
         headers: [String : String]? = [Authorization.header: Authorization.key],
         query: [String : Any]?) {
        self.baseURL = baseURL
        self.path = path
        self.httpMethod = httpMethod
        self.headers = headers
        self.query = query
    }
}

enum BaseURL: String {
    case kakao = "https://dapi.kakao.com"
}

enum Path: String {
    case book = "/v3/search/book"
}

enum HTTPMethod: String {
    case get = "GET"
}

enum Authorization {
    static let header = "Authorization"
    static let key = "KakaoAK" + " 790ef075d39cdc821124007fc1796766"
}

protocol Request {
    var baseURL: BaseURL { get }
    var path: Path { get }
    var httpMethod: HTTPMethod { get }
    var headers: [String: String]? { get }
    var query: [String: Any]? { get }
}

extension Request {
    var url: URL? {
        var urlComponents = URLComponents(string: baseURL.rawValue + path.rawValue)
        
        if let query = query {
            urlComponents?.queryItems = query.map { key, value in
                URLQueryItem(name: key, value: "\(value)")
            }
        }
        
        return urlComponents?.url
    }
    
    var request: URLRequest? {
        guard let url = url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        headers?.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
}
