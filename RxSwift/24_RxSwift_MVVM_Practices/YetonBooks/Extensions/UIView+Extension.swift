//
//  UIView+Extension.swift
//  MovieApp
//
//  Created by 이예은 on 2023/02/04.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }
}
