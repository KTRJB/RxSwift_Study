//
//  Book.swift
//  YetonBooks
//
//  Created by 이예은 on 2023/03/19.
//

import Foundation

// MARK: - Welcome1
struct Book: Decodable {
    let documents: [BookInfo]
}

// MARK: - Document
struct BookInfo: Decodable {
    let authors: [String]
    let price: Int
    let thumbnail: String
    let title: String
    let url: String
    let datetime: String
}
