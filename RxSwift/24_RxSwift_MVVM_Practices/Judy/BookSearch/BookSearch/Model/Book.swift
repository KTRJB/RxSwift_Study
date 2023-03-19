//
//  Book.swift
//  BookSearch
//
//  Created by 김주영 on 2023/03/19.
//

import Foundation

struct BookList: Decodable {
    let documents: [Book]
}

struct Book: Decodable {
    let title: String
    let authors: [String]
    let price: Int
    let thumbnail: String
    let datetime: String
}
