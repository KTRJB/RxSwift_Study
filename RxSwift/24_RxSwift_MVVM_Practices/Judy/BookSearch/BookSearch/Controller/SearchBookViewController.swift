//
//  ViewController.swift
//  BookSearch
//
//  Created by 김주영 on 2023/03/19.
//

import UIKit
import RxCocoa
import RxSwift

final class SearchBookViewController: UIViewController {
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var bookListTableView: UITableView!
    
    private var bookList = BehaviorRelay<[Book]>(value: [])
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    private func bind() {
        let searchInput = searchBar.rx.controlEvent(.editingChanged)
            .asObservable()
            .compactMap {
                self.searchBar.text
            }
            .filter {
                $0.isEmpty == false
            }
        
        let search = searchInput.flatMap {
                APIManager.shared.requestBookSearch(with: $0)
                .catchAndReturn(BookList(documents: []))
            }
            .map { $0.documents }
        
        search.observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                self.bookList.accept($0)
                self.bookListTableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        Observable.from([searchInput.map { _ in true },
                         search.map { _ in false }])
        .merge()
        .asDriver(onErrorJustReturn: false)
        .drive(indicatorView.rx.isAnimating)
        .disposed(by: disposeBag)
        
        sortButton.rx.tap
            .subscribe(onNext: {
                self.sortBookList()
            })
            .disposed(by: disposeBag)
        
        //            .bind(to: bookListTableView.rx.items(cellIdentifier: "BookTableViewCell",
        //                                                 cellType: BookTableViewCell.self)) { _, book, cell in
        //                cell.configure(with: book)
        //            }.disposed(by: disposeBag)
    }
    
    private func sortBookList() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "가격 낮은순", style: .default) { _ in
            let sorted = self.bookList.value.sorted(by: { $0.price < $1.price })
            self.bookList.accept(sorted)
            DispatchQueue.main.async {
                self.bookListTableView.reloadData()
            }
        })

        alert.addAction(UIAlertAction(title: "최신 제작순", style: .default) { _ in
            let sorted = self.bookList.value.sorted(by: { $0.datetime.toDate > $1.datetime.toDate })
            self.bookList.accept(sorted)
            DispatchQueue.main.async {
                self.bookListTableView.reloadData()
            }
        })

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        present(alert, animated: true)
    }
}


extension SearchBookViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookList.value.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookTableViewCell",
                                                       for: indexPath) as? BookTableViewCell else {
            return UITableViewCell() }

        cell.configure(with: bookList.value[indexPath.row])
        return cell
    }
}

