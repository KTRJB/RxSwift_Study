/*
 * Copyright (c) 2016 Razeware LLC
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

import UIKit
import RxSwift
import RxRelay

class MainViewController: UIViewController {
    
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var buttonClear: UIButton!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var itemAdd: UIBarButtonItem!

    // MARK: 1. DisposeBag 구현하기

    // MARK: 2-1. UIImage 구독을 위한 객체 구현하기

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: 2-2. UIImage 구독 요청 설정하기
        // imagePreview에 보여질 이미지를 업데이트하는데
        // 이미지의 사이즈는 내부 정의 함수인 collage(size:) 사용


        // MARK: 4-1. '+', 'Save', 'Clear' 버튼 제약을 구독 요청 내 구현
        // 조건1: 저장 버튼은 이미지가 적어도 하나 이상 존재하고, 짝수개일때만 저장
        // 조건2: 초기화 버튼은 이미지가 적어도 하나 이상일 때만 작동
        // 조건3: 추가 버튼은 이미지가 6개까지만 들어갈 수 있도록 제한
        // 조건4: NavigationBar의 Title은 이미지가 하나 이상 존재할 때는 (갯수) photos, 아닐때는 Collage

    }

    // MARK: 4-2. '+', 'Save', 'Clear' 버튼 제약 내부 구현 함수(updateUI) 생성
    
    @IBAction func actionClear() {
        // MARK: 3-1. 'Clear' 버튼 클릭시 이미지를 초기화하는 기능 구현

    }
    
    @IBAction func actionSave() {
        // MARK: 7. 커스텀한 Observable 구독하기
        // PhotoWriter.save(_) observable은 새로운 asset ID를 방출하거나 에러를 방출

    }
    
    @IBAction func actionAdd() {
        // MARK: 3-2. '+' 버튼 클릭시 Image를 추가하는 기능 구현
        // 새로운 이미지는 "IMG_1907.jpg" 사용하기


        // MARK: 5. '+' 버튼 클릭시 PhotosViewController로 화면 전환
        // MARK 3번 수행 내용을 모두 주석처리 후 진행
        // 화면전환 구현 이후 PhotosViewController로 이동

        // MARK: 6-2. PhotosViewController에서 고른 이미지가 images에 적용되도록 구독 구현

    }
    
    func showMessage(_ title: String, description: String? = nil) {
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(
            title: "Close",
            style: .default,
            handler: { [weak self] _ in self?.dismiss(animated: true, completion: nil)}
        ))
        present(alert, animated: true, completion: nil)
    }
}
