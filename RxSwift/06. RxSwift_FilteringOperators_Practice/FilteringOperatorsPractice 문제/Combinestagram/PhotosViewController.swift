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
import Photos
import RxSwift

class PhotosViewController: UICollectionViewController {

    let bag = DisposeBag()
    private let selectedPhotosSubject = PublishSubject<UIImage>()
    var selectedPhotos: Observable<UIImage> {
        return selectedPhotosSubject.asObservable()
    }

    private lazy var photos = PhotosViewController.loadPhotos()
    private lazy var imageManager = PHCachingImageManager()

    private lazy var thumbnailSize: CGSize = {
        let cellSize = (self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        return CGSize(width: cellSize.width * UIScreen.main.scale,
                      height: cellSize.height * UIScreen.main.scale)
    }()

    static func loadPhotos() -> PHFetchResult<PHAsset> {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        return PHAsset.fetchAssets(with: allPhotosOptions)
    }

    // MARK: View Controller
    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: 5-1. 사진 라이브러리 접근 허용시 사진 로드
        // collectionView의 데이터를 reload할때는 MainScheduler에서 진행할 수 있으나
        // 일단은 추후에 다시 다루기로하고 GCD 사용
        // 사진 라이브러리 접근 허용 경우는 총 2가지
        // 1) 최초 실행시 false -> 사용자의 접근 허용 선택으로 인한 true -> completed
        // 2) 이미 허용한 상태로 true -> completed
        let authorized = PHPhotoLibrary.authroized
            .share()

        authorized
            .skip(while: { $0 == false })
            .take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.photos = PhotosViewController.loadPhotos()
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            })
            .disposed(by: bag)


        // MARK: 5-2. 사진 라이브러리 접근 거부시 에러 메시지 표시
        // 사진 라이브러리 접근 거부 경우는 총 2가지이나 결국 sequence 요소는 동일 (같은 코드 경로)
        // 1) 최초 실행시 false -> 사용자의 접근 거부 선택으로 인한 false -> completed
        // 2) 이후에도 계속 접근 거부로 false -> false -> completed
        // errorMessage 함수를 사용하여 에러메시지를 표시하되,
        // 구체적인 구현은 다음 스텝에서 이어서 진행

        authorized
            .skip(1)
            .takeLast(1)
            .filter({ $0 == false })
            .subscribe(onNext: { [weak self] _ in
                guard let errorMessage = self?.errorMessage else { return }
                DispatchQueue.main.async(execute: errorMessage)
            })
            .disposed(by: bag)

    }



    private func errorMessage() {
        // MARK: 6-2. Alert 자동 완료 기능 설정
        // alert title = "No access to Camera Roll"
        // alert text = "You can grant access to Combinestagram from the Settings app"
        // 5초 이후 자동 완료 기능 실행
        // alert 창을 dismiss 이후, mainVC로 복귀

        alert(title: "No access to Camera Roll", text: "You can grant access to Combinestagram from the Settings app")
            .take(for: .seconds(5), scheduler: MainScheduler.instance)
            .subscribe(onCompleted: { [weak self] in
                self?.dismiss(animated: true)
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: bag)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        selectedPhotosSubject.onCompleted()
    }

    // MARK: UICollectionView

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let asset = photos.object(at: indexPath.item)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoCell

        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.imageView.image = image
            }
        })

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = photos.object(at: indexPath.item)

        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell {
            cell.flash()
        }

        imageManager.requestImage(for: asset, targetSize: view.frame.size, contentMode: .aspectFill, options: nil, resultHandler: { [weak self] image, info in
            guard let image = image, let info = info else { return }

            if let isThumbnail = info[PHImageResultIsDegradedKey as NSString] as? Bool, !isThumbnail {
                self?.selectedPhotosSubject.onNext(image)
            }

        })
    }
}
