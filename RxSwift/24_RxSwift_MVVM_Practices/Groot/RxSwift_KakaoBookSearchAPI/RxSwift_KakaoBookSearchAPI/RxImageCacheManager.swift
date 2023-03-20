//
//  RxImageCacheManager.swift
//  RxSwift_KakaoBookSearchAPI
//
//  Created by Groot on 2023/03/18.
//

import UIKit
import RxSwift
import RxCocoa

typealias rxImage = RxImageCacheManager

final class RxImageCacheManager {
    static let shared = RxImageCacheManager()
    
    private init () {}
    
    func request(url: String) -> Observable<UIImage> {
        return Observable<UIImage>.create { observer in
            Task {
                let image = try await ImageCacheManager.shared.image(key: url)
                observer.onNext(image ?? UIImage())
                observer.onCompleted()
            }
            
            return Disposables.create()
        }.observe(on: MainScheduler.instance)
    }
    
    func cancel(url: String) {
        Task {
            await ImageCacheManager.shared.cancel(url: url)
        }
    }
    
    func cancelAll() {
        Task {
            await ImageCacheManager.shared.cancelAll()
        }
    }
}

fileprivate actor ImageCacheManager {
    static let shared = ImageCacheManager()
    private var cacheManager = NSCache<NSString, UIImage>()
    private var tasks: [String: Task<UIImage?, Error>] = [:]
    
    private init() {}
    
    func image(key: String) async throws -> UIImage? {
        if let cachedImage = cacheManager.object(forKey: NSString(string: key)) {
            return cachedImage
        }
        
        guard let url = URL(string: key) else { throw ImageCacheError.invalidURL }
        
        if tasks[key] != nil {
            return try await tasks[key]?.value
        }
        
        let task = Task {
            try await requestImage(url: url)
        }
        
        tasks[key] = task
        defer { tasks[key] = nil }
        
        guard let image = try await task.value else { return nil }
        
        if let oldImage = cacheManager.object(forKey: NSString(string: key)) {
            return oldImage
        }
        
        cacheManager.setObject(image, forKey: NSString(string: key))
        
        return image
    }
    
    private func requestImage(url: URL) async throws -> UIImage? {
        guard !Task.isCancelled else { return nil }
        
        let task: (data: Data, response: URLResponse) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = task.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ImageCacheError.invalidResponse
        }
        
        guard let image = UIImage(data: task.data) else {
            throw ImageCacheError.invalidImage
        }
        
        return image
    }
    
    func cancel(url: String) {
        tasks[url]?.cancel()
        tasks[url] = nil
    }
    
    func cancelAll() {
        tasks.forEach { $0.value.cancel() }
        tasks.removeAll()
    }
}

enum ImageCacheError: Error {
    case invalidURL
    case invalidResponse
    case invalidImage
}

extension UIImageView  {
    func image(url: String, disposeBag: DisposeBag) {        
        rxImage.shared.request(url: url)
            .subscribe(onNext: { image in
                self.image = image
            }).disposed(by: disposeBag)
    }
    
    func cancel(url: String) {
        Task {
            await ImageCacheManager.shared.cancel(url: url)
        }
    }
}
