//
//  Model.swift
//  RxSwift_KakaoBookSearchAPI
//
//  Created by Groot on 2023/03/17.
//

import Foundation

struct SearchResult: Decodable {
    let meta: Meta
    let documents: [Document]
}

struct Meta: Decodable {
    let isEnd: Bool
    let pageableCount: Int
    let totalCount: Int
    
    private enum CodingKeys: String, CodingKey {
        case isEnd = "is_end"
        case pageableCount = "pageable_count"
        case totalCount = "total_count"
    }
}

struct Document: Decodable {
    let title: String
    let authors: [String]
    let contents: String
    let _datetime: String
    var dateTime: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-mm-dd"
        
        return formatter.date(from: String(_datetime.prefix(10))) ?? Date()
    }
    
    let salePrice: Int
    let thumbnail: String
    
    private enum CodingKeys: String, CodingKey {
        case title
        case authors
        case contents
        case _datetime = "datetime"
        case salePrice = "sale_price"
        case thumbnail
    }
}
