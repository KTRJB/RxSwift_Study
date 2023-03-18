//
//  MainViewController.swift
//  KakaoBookSearch
//
//  Created by 전민수 on 2023/03/18.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftyJSON

final class MainViewController: UIViewController {
    
    // MARK: Properties

    private let disposeBag = DisposeBag()
    private var books = [JSON]()

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "검색어를 입력하세요."

        return searchBar
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemGray6
        tableView.sectionHeaderHeight = 50

        return tableView
    }()

    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 5
        stackView.alignment = .fill

        return stackView
    }()

    private let priceSortButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("가격순", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black

        return button
    }()

    private let dateSortButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("최신순", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black

        return button
    }()

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        setupSubscription()
    }

    // MARK: - Methods

    private func configureUI() {
        setupBackgroundColor()
        setupSearchBarConstraints()
        setupTableViewConstraints()
        configureTableView()
    }

    private func setupBackgroundColor() {
        view.backgroundColor = .systemBackground
    }

    private func setupSearchBarConstraints() {
        view.addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupTableViewConstraints() {
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func configureTableView() {
        tableView.register(BookTableViewCell.self, forCellReuseIdentifier: "BookTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func setupSubscription() {
        setupSearchBarSubscription()
        setupSortButtonSubscription()
    }

    private func setupSearchBarSubscription() {
        searchBar.rx.text.orEmpty
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest { text in
                return ApiController.shared.search(text: text)
                    .catchAndReturn([])
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] result in
                self?.books = result
                self?.tableView.reloadData()
                self?.priceSortButton.backgroundColor = .black
                self?.dateSortButton.backgroundColor = .black
            })
            .disposed(by: disposeBag)
    }

    private func setupSortButtonSubscription() {
        priceSortButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                switch self?.priceSortButton.backgroundColor {
                case UIColor.red:
                    self?.books.reverse()
                    self?.priceSortButton.backgroundColor = .blue
                case UIColor.blue:
                    self?.books.reverse()
                    self?.priceSortButton.backgroundColor = .red
                default:
                    self?.books.sort { $0["price"].int ?? 0 < $1["price"].int ?? 0}
                    self?.priceSortButton.backgroundColor = .blue
                    self?.dateSortButton.backgroundColor = .black
                }

                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)

        dateSortButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                switch self?.dateSortButton.backgroundColor {
                case UIColor.red:
                    self?.books.reverse()
                    self?.dateSortButton.backgroundColor = .blue
                case UIColor.blue:
                    self?.books.reverse()
                    self?.dateSortButton.backgroundColor = .red
                default:
                    self?.books.sort { $0["datetime"].string ?? "" < $1["datetime"].string ?? ""}
                    self?.priceSortButton.backgroundColor = .black
                    self?.dateSortButton.backgroundColor = .blue
                }

                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Extension

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookTableViewCell", for: indexPath) as? BookTableViewCell else {
            return UITableViewCell()
        }

        let book = books[indexPath.row]

        cell.setup(from: book)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        let headerView = UIView()

        buttonStackView.addArrangedSubview(priceSortButton)
        buttonStackView.addArrangedSubview(dateSortButton)
        headerView.addSubview(buttonStackView)

        NSLayoutConstraint.activate([
            buttonStackView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            buttonStackView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            buttonStackView.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 0.9)
        ])

        return headerView
    }
}
