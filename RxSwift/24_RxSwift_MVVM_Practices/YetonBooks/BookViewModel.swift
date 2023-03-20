//
//  BookViewModel.swift
//  YetonBooks
//
//  Created by 이예은 on 2023/03/19.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: - Input, Output
protocol MovieListViewModelInput {
    func viewDidLoad()
    func priceSortButtonDidTap(text: String?)
    func dateTimeSortButtonDidTap(text: String?)
}

protocol MovieListViewModelOutput {
    var model: [BookInfo]? { get set }
    var _model: BehaviorSubject<[BookInfo]?> { get set}
}

protocol MovieListViewModelInterface {
    var input: MovieListViewModelInput { get }
    var output: MovieListViewModelOutput { get }
}

class BookViewModel: MovieListViewModelInterface, MovieListViewModelInput {
    var input: MovieListViewModelInput { self }
    var output: MovieListViewModelOutput { self }
    
    var model: [BookInfo]? = nil
    var _model = BehaviorSubject<[BookInfo]?>(value: nil)
    
    let networkManager = SearchBookNetwork()
    let disposebag = DisposeBag()
}

extension BookViewModel: MovieListViewModelOutput {
    func viewDidLoad() {
        networkManager.searchBook(query: "미움 받을 용기")
            .subscribe { book in
                self.model = book.documents
                self._model.onNext(book.documents)
            }
            .disposed(by: disposebag)
    }
    
    func priceSortButtonDidTap(text: String?) {
        guard let text = text else {
            return
        }
        
        networkManager.searchBook(query: text)
            .subscribe { book in
                self.model = book.documents.sorted { $0.price < $1.price }
                self._model.onNext(book.documents.sorted { $0.price < $1.price })
            }
            .disposed(by: disposebag)
    }
    
    func dateTimeSortButtonDidTap(text: String?) {
        guard let text = text else {
            return
        }
        
        networkManager.searchBook(query: text)
            .subscribe { book in
                self.model = book.documents.sorted { $0.datetime < $1.datetime }
                self._model.onNext(book.documents.sorted { $0.datetime < $1.datetime })
            }
            .disposed(by: disposebag)
    }
}
