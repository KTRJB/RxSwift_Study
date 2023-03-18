//
//  BookTableViewCell.swift
//  KakaoBookSearch
//
//  Created by 전민수 on 2023/03/18.
//

import UIKit
import RxSwift
import SwiftyJSON

final class BookTableViewCell: UITableViewCell {
    
    // MARK: Properties

    private var disposable = SingleAssignmentDisposable()

    private let bookImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    private let labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 5
        stackView.alignment = .fill

        return stackView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .left

        return label
    }()

    private let authorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .left

        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .left

        return label
    }()

    // MARK: - Initializer

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setAutoLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Cell Life Cycle

    override func prepareForReuse() {
        super.prepareForReuse()

        bookImageView.image = nil
        titleLabel.text = ""
        authorLabel.text = ""
        priceLabel.text = ""

        disposable.dispose()
        disposable = SingleAssignmentDisposable()
    }

    // MARK: - Methods

    func setup(from book: JSON) {
        let imageURL = book["thumbnail"].string ?? ""
        let title = book["title"].string ?? "제목 미정"
        let author = book["authors"].count > 1
            ? (book["authors"][0].string!) + " 외 \(book["authors"].count - 1)명"
            : book["authors"][0].string ?? "저자 미상"
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let price = numberFormatter.string(from: NSNumber(value: book["price"].int ?? 0)) ?? "0"

        downloadImage(from: imageURL)
        titleLabel.text = "제목: \(title)"
        authorLabel.text = "저자: \(author)"
        priceLabel.text = "가격: \(price)원"
    }

    private func downloadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            bookImageView.image = UIImage(named: "EmptyImage")

            return
        }
        let request = URLRequest(url: url)

        let subscription = URLSession.shared.rx.data(request: request)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] imageData in
                self?.bookImageView.image = UIImage(data: imageData)
            })

        disposable.setDisposable(subscription)
    }
}

// MARK: - Extensions

extension BookTableViewCell {
    private func setAutoLayout() {
        [titleLabel, authorLabel, priceLabel].forEach { labelStackView.addArrangedSubview($0) }
        [bookImageView, labelStackView].forEach { addSubview($0) }

        NSLayoutConstraint.activate([
            bookImageView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            bookImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            bookImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            bookImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.3),
            
            labelStackView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            labelStackView.leadingAnchor.constraint(equalTo: bookImageView.trailingAnchor, constant: 5),
            labelStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            labelStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
        ])
    }
}
