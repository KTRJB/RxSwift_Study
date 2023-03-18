//
//  APIController.swift
//  KakaoBookSearch
//
//  Created by 전민수 on 2023/03/18.
//

import Foundation
import RxSwift
import SwiftyJSON

final class ApiController {
    
    // MARK: Properties

    static let shared = ApiController()
    private let apiKey = "7acfac7b2e2cade61375dcd6273776a2"

    // MARK: - Method

    func search(text: String) -> Observable<[JSON]> {
        let url = URL(string: "https://dapi.kakao.com/v3/search/book")!
        var request = URLRequest(url: url)

        let keyQueryItem = URLQueryItem(name: "target", value: "title")
        let searchQueryItem = URLQueryItem(name: "query", value: text)
        let sortQueryItem = URLQueryItem(name: "sort", value: "accuracy")
        let pageQueryItem = URLQueryItem(name: "page", value: "1")
        let sizeQueryItem = URLQueryItem(name: "size", value: "10")

        let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true)!

        urlComponents.queryItems = [
            searchQueryItem,
            sortQueryItem,
            pageQueryItem,
            sizeQueryItem,
            keyQueryItem
        ]

        request.url = urlComponents.url!
        request.httpMethod = "GET"
        request.setValue("application/x-www-form-urlencoded;charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("KakaoAK \(apiKey)", forHTTPHeaderField: "Authorization")

        return URLSession.shared.rx.json(request: request).map { json in
            return json["documents"].array ?? []
        }
    }
}
