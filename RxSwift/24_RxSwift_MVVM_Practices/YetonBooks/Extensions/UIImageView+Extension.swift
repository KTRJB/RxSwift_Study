//
//  UIImageView+Extension.swift
//  MovieApp
//
//  Created by 이예은 on 2023/02/05.
//

import UIKit
import OSLog

extension UIImageView {
    func setImage(with url: String) {
        if let cachedImage = ImageCacheManager.shared.loadCachedData(for: url) {
            self.image = cachedImage
        } else {
            ImageCacheManager.shared.setImage(url: url) { [weak self] image in
                guard let image = image else {
                    return
                }
                
                ImageCacheManager.shared.setCacheData(of: image, for: url)
                self?.image = image
            }
        }
    }
}
