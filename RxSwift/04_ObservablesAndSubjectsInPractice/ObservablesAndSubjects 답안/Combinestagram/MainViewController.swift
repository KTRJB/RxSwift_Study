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

    private let bag = DisposeBag()

    // MARK: 2-1. UIImage 구독을 위한 객체 구현하기

    // relay를 이용하여 객체를 구현함은 구독을 위하여 ObservableType이 필요한데
    // error, complete을 통해서 완전종료가 필요치 않고
    // 즉, dispose되기 전까지 계속 작동해야하고
    // PublishRelay, BehaviorRelay 중에서는 구독 이전 발생한 이벤트를
    // 인지하느냐, 그렇지 않느냐의 차이인데, 별 차이는 없지만 이전에 저장한 UIImage 배열을
    // 필요로 할수 있지 않을까 생각에 BehaviorRelay로 구현

    private let images = BehaviorRelay<[UIImage]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: 2-2. UIImage 구독 요청 설정하기
        // imagePreview에 보여질 이미지를 업데이트하는데
        // 이미지의 사이즈는 내부 정의 함수인 collage(size:) 사용

        images
            .asObservable()
            .subscribe(
                onNext: { [weak self] photos in
                    guard let preview = self?.imagePreview else { return }

                    preview.image = UIImage.collage(
                        images: photos,
                        size: preview.frame.size
                    )
                })
            .disposed(by: bag)

        // MARK: 4-1. '+', 'Save', 'Clear' 버튼 제약을 구독 요청 내 구현
        // 조건1: 저장 버튼은 이미지가 적어도 하나 이상 존재하고, 짝수개일때만 저장
        // 조건2: 초기화 버튼은 이미지가 적어도 하나 이상일 때만 작동
        // 조건3: 추가 버튼은 이미지가 6개까지만 들어갈 수 있도록 제한
        // 조건4: NavigationBar의 Title은 이미지가 하나 이상 존재할 때는 (갯수) photos, 아닐때는 Collage

        images
            .asObservable()
            .subscribe(
                onNext: { [weak self] photos in
                    self?.updateUI(photos: photos)
                })
            .disposed(by: bag)
    }

    // MARK: 4-2. '+', 'Save', 'Clear' 버튼 제약 내부 구현 함수(updateUI) 생성

    private func updateUI(photos: [UIImage]) {
        buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0
        buttonClear.isEnabled = photos.count > 0
        itemAdd.isEnabled = photos.count < 6
        title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
    }
    
    @IBAction func actionClear() {
        // MARK: 3-1. 'Clear' 버튼 클릭시 이미지를 초기화하는 기능 구현

        images.accept([])
    }
    
    @IBAction func actionSave() {
        // MARK: 7. 커스텀한 Observable 구독하기
        // PhotoWriter.save(_) observable은 새로운 asset ID를 방출하거나 에러를 방출

        guard let image = imagePreview.image else { return }
        
        PhotoWriter.save(image)
            .asSingle()
            .subscribe(
                onSuccess: { [weak self] id in
                    self?.showMessage("Saved with id: \(id)")
                    self?.actionClear()
                },
                onFailure: { [weak self] error in
                    self?.showMessage("Error", description: error.localizedDescription)
                }
            )
            .disposed(by: bag)
    }
    
    @IBAction func actionAdd() {
        // MARK: 3-2. '+' 버튼 클릭시 Image를 추가하는 기능 구현
        // 새로운 이미지는 "IMG_1907.jpg" 사용하기

        //        let newImages = images.value + [UIImage(named: "IMG_1907.jpg")!]
        //        images.accept(newImages)

        // MARK: 5. '+' 버튼 클릭시 PhotosViewController로 화면 전환
        // MARK 3번 수행 내용을 모두 주석처리 후 진행
        // 화면전환 구현 이후 PhotosViewController로 이동

        let photosViewController = storyboard!.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController

        // MARK: 6-2. PhotosViewController에서 고른 이미지가 images에 적용되도록 구독 구현

        photosViewController.selectedPhotos
            .subscribe(
                onNext: { [weak self] newImage in
                    guard let images = self?.images else { return }

                    images.accept(images.value + [newImage])
                },
                onDisposed: {
                    print("completed photo selection")
                }
            )
            .disposed(by: photosViewController.bag)

        navigationController!.pushViewController(photosViewController, animated: true)
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
