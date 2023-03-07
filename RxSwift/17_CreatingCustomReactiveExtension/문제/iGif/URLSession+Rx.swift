/*
 * Copyright (c) 2014-2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import RxSwift
import SwiftyJSON
import UIKit

// MARK: - B-3-1. 캐싱을 위한 딕셔너리 구현

public enum RxURLSessionError: Error {
    case unknown
    case invalidResponse(response: URLResponse)
    case requestFailed(response: HTTPURLResponse, data: Data?)
    case deserializationFailed
}

// MARK: - B-3-2. Data Observable 캐싱을 위한 extension 구현

// MARK: - B-1. URLSession을 Rx로 확장

    // MARK: - B-2-1. response 함수 구현
    // URLRequest를 통해 HTTPURLResponse와 Data를 Observable 형태로 반환

            // MARK: - B-2-2. 콜백과 Task 내부 구현


            // MARK: - B-2-3. 비동기작업으로 인한 리소스 낭비 방지


    // MARK: - B-2-4. response 함수를 활용하여 각각의 Type 인스턴스를 반환하는 함수 구현
    // 구현 Type: Data, String, JSON, UIImage

        // MARK: - B-3-3. cache 적용

        // url.absoluteString => 절대주소 (urlString과 동일)
