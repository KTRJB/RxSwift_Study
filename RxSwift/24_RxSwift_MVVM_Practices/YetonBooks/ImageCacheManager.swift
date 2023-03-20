//
//  ImageCacheManager.swift
//  YetonBooks
//
//  Created by 이예은 on 2023/03/20.
//

import UIKit

final class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private init() {}
    
    private let cache = NSCache<NSString, UIImage>()
    private var latestTask: URLSessionDataTask?
    private let session: URLSession = {
        let sessionConfiguration: URLSessionConfiguration = {
            let configuration = URLSessionConfiguration.default
            configuration.requestCachePolicy = .reloadIgnoringCacheData
            return configuration
        }()
        let session =  URLSession(configuration: sessionConfiguration)
        return session
    }()
    
    func loadCachedData(for key: String) -> UIImage? {
        let itemURL = NSString(string: key)
        return cache.object(forKey: itemURL)
    }
    
    func setCacheData(of image: UIImage, for key: String) {
        let itemURL = NSString(string: key)
        cache.setObject(image, forKey: itemURL)
    }
    
    func cancelDownloadTask() {
        guard latestTask != nil else {
            return
        }
        latestTask = nil
    }
    
    func setImage(url urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard urlString.contains("https"), let url = URL(string: urlString) else {
            return
        }
        latestTask = session.dataTask(with: url, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                if let data, let image = UIImage(data: data) {
                    completion(image)
                } else {
                    completion(nil)
                }
            }
        })
        latestTask?.resume()
    }
}
