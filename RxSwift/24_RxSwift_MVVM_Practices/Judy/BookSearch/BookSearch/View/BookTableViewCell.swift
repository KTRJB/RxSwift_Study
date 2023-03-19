//
//  BookTableViewCell.swift
//  BookSearch
//
//  Created by 김주영 on 2023/03/19.
//

import UIKit
import RxSwift

final class BookTableViewCell: UITableViewCell {
    @IBOutlet weak var bookTitleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    private let disposeBag = DisposeBag()
    
    func configure(with data: Book) {
        bookTitleLabel.text = data.title
        authorLabel.text = data.authors.joined(separator: ", ")
        priceLabel.text = data.price.decimal
        dateLabel.text = " • " + data.datetime.toDate.toString
        setupImage(with: data.thumbnail)
    }
    
    private func setupImage(with url: String) {
        let image = APIManager.shared.requestImage(with: url)
        
        image.asDriver(onErrorJustReturn: nil)
            .drive(bookImageView.rx.image)
            .disposed(by: disposeBag)
    }
}
