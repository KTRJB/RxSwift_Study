//
//  NSObject+Extension.swift
//  MovieApp
//
//  Created by 이예은 on 2023/02/04.
//

import Foundation

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
}
