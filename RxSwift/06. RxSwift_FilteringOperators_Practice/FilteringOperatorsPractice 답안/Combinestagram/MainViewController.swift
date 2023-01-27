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

    private let bag = DisposeBag()
    private let images = BehaviorRelay<[UIImage]>(value: [])
    private var imageCache = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()

        images
            // MARK: 7. subscribe 부하 줄이기
            // 0.5초 간격 내에서의 사용자가 탭한 이미지만을 가져오도록 설정
            // 버튼이 여러번 탭 되었을 때의 리소스를 줄이기

            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] photos in
                    guard let preview = self?.imagePreview else { return }

                    preview.image = UIImage.collage(
                        images: photos,
                        size: preview.frame.size
                    )
                })
            .disposed(by: bag)

        images
            .subscribe(
                onNext: { [weak self] photos in
                    self?.updateUI(photos: photos)
                })
            .disposed(by: bag)
    }

    private func updateUI(photos: [UIImage]) {
        buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0
        buttonClear.isEnabled = photos.count > 0
        itemAdd.isEnabled = photos.count < 6
        title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
    }

    @IBAction func actionClear() {
        images.accept([])

        // MARK: 2-3. 2-2 문제에서 발생한 이미지 캐시 초기화 기능 구현

        imageCache = []
    }

    @IBAction func actionSave() {
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
        let photosViewController = storyboard!.instantiateViewController(
            withIdentifier: "PhotosViewController") as! PhotosViewController

        // MARK: 0. photosViewController.selectedPhotos 구독 공유

        let newPhotos = photosViewController.selectedPhotos
            .share()



        newPhotos
            // MARK: 3. 조건에 부합하는 요소 선택
            // 현재 updateUI(photos:) 함수때문에 이미지가 6개를 초과한 경우
            // 추가할 수 없도록 처리를 해놓았으나
            // PhotoVC에서는 여전히 사진이 추가될 가능성 존재
            // 이에 따라 최대 6개의 이미지만을 취할 수 있도록 연산자 설정

            .take(while: { [weak self] _ in
                return (self?.images.value.count ?? 0) < 6
            })
            // MARK: 2-1. 필터링 - 가로길이가 세로길이보다 긴 이미지만 필터링

            .filter { newImage in
                return newImage.size.width > newImage.size.height
            }

            // MARK: 2-2. 필터링 - 동일한 사진이 중복 추가되지 않도록 필터링
            // 이미지 구분을 위하여 데이터의 해시나 URL asset을 저장해도 좋지만
            // 여기에서는 간단하게 이미지의 byte 길이를 이용하여 구현
            // 이미지 byte를 담기위한 새로운 프로퍼티 추가 가능

            .filter { [weak self] newImage in
                let len = newImage.pngData()?.count ?? 0

                guard self?.imageCache.contains(len) == false else {
                    return false
                }

                self?.imageCache.append(len)
                return true
            }
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

        // MARK: 1. PhotoVC에서 사진 선택 이후 MainVC의 좌측 네비게이션 버튼에 미리보기 이미지 설정
        // 미리 구현된 updateNavigationIcon() 함수를 이용하여 네비게이션 버튼 이미지 설정
        // 해당 미리보기 아이콘은 MainVC로 돌아올때만, 즉 한 번만 업데이트하도록 설정

        newPhotos
            .ignoreElements()
            .subscribe(onCompleted: { [weak self] in
                self?.updateNavigationIcon()
            })
            .disposed(by: photosViewController.bag)

        navigationController!.pushViewController(photosViewController, animated: true)
    }

    private func updateNavigationIcon() {
        let icon = imagePreview.image?
            .scaled(CGSize(width: 22, height: 22))
            .withRenderingMode(.alwaysOriginal)

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: icon,
                                                           style: .done, target: nil, action: nil)
    }

    func showMessage(_ title: String, description: String? = nil) {
        // MARK: 6-1. Alert을 Observable화 후, extension으로 별도 구현

        alert(title: title, text: description)
            .subscribe()
            .disposed(by: bag)
    }
}
