//
//  CustomTableViewCell.swift
//  RxSwift_KakaoBookSearchAPI
//
//  Created by Groot on 2023/03/17.
//

import UIKit
import RxSwift

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var wirterLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    private var url = ""
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bookImageView.translatesAutoresizingMaskIntoConstraints = false
        bookImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
        bookImageView.image = nil
        bookImageView.cancel(url: url)
        url = ""
    }
    
    func bind(item: Document) {
        url = item.thumbnail
        bookImageView.image(url: url, disposeBag: disposeBag)
        titleLabel.text = item.title
        priceLabel.text = item.salePrice.description
        wirterLabel.text = item.authors.joined(separator: ",")
    }

}
