//
//  BookCell.swift
//  BookApp
//
//  Created by 이예은 on 2023/02/04.
//

import UIKit
import Combine

class BookCell: UITableViewCell {
    // MARK: - Views
    private lazy var backgroundStackView: UIStackView = {
        let stackView = UIStackView(axis: .horizontal, alignment: .center, distribution: .fill, spacing: 20)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20)
        stackView.addArrangedSubviews(sequenceLabel, bookInfoView, bookImageView)
        return stackView
    }()
    
    private lazy var sequenceLabel: UILabel = {
        let label = UILabel()
        label.text = "1"
        label.font = .preferredFont(for: .title2, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.widthAnchor.constraint(equalToConstant: 30).isActive = true
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    private lazy var bookInfoView: UIStackView = {
        let stackView = UIStackView(axis: .vertical, alignment: .fill, distribution: .fill, spacing: 20)
        stackView.addArrangedSubviews(titleLabel, bookOtherView)
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "아몬드"
        label.numberOfLines = 4
        label.font = .preferredFont(for: .body, weight: .semibold)
        label.textColor = .white
        return label
    }()
    
    private lazy var bookOtherView: UIStackView = {
        let stackView = UIStackView(axis: .vertical, alignment: .fill, distribution: .fill, spacing: 2)
        stackView.addArrangedSubviews(writerLabel, priceLabel)
        return stackView
    }()
    
    private lazy var writerLabel: UILabel = {
        let label = UILabel()
        label.text = "김혜란"
        label.font = .preferredFont(for: .footnote, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.text = "23000원"
        label.font = .preferredFont(for: .footnote, weight: .regular)
        label.textColor = .white
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    private lazy var bookImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.widthAnchor.constraint(equalToConstant: 90).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 110).isActive = true
        imageView.backgroundColor = .darkGray
        return imageView
    }()
    
    // MARK: - override
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setup(book: BookInfo?, index: Int) {
        guard let book = book else {
            return
        }
        
        sequenceLabel.text = "\(index + 1)"
        bookImageView.setImage(with: book.thumbnail)
        titleLabel.text = book.title
        writerLabel.text = book.authors.first ?? "작가 미상"
        priceLabel.text = "\(String(describing: book.price))"
        
    }
}

// MARK: - Private Actions
private extension BookCell {
    func configure() {
        selectionStyle = .none
        contentView.backgroundColor = .boBackground
        contentView.addSubviews(backgroundStackView)
        
        NSLayoutConstraint.activate([
            backgroundStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func reset() {
        sequenceLabel.text = nil
        titleLabel.text = nil
        writerLabel.text = nil
        priceLabel.text = nil
        bookImageView.image = nil
    }
}


