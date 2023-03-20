//
//  UIColor+Extension.swift
//  MovieApp
//
//  Created by 이예은 on 2023/02/05.
//

import UIKit

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1.0) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: a)
    }
    
    static var boBackground: UIColor {
        return UIColor(r: 26, g: 26, b: 26)
    }
}

