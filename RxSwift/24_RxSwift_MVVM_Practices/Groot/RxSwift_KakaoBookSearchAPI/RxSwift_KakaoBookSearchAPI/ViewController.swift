//
//  ViewController.swift
//  RxSwift_KakaoBookSearchAPI
//
//  Created by Groot on 2023/03/17.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var sortSegment: UISegmentedControl!
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    let disposeBag = DisposeBag()
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        loadingView.isHidden = true
    }
    
    enum Sort: Int {
        case date = 0
        case price = 1
    }
    
    func bind() {
        searchBar.rx.text
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(to: viewModel.searchBarText)
            .disposed(by: disposeBag)
        
        self.rx.actionOccured
            .bind(to: viewModel.sortDocument)
            .disposed(by: disposeBag)
        
        viewModel.isEndLoading
            .observe(on: MainScheduler.instance)
            .bind(to: self.rx.isLoading)
            .disposed(by: disposeBag)
        
        viewModel.documents
            .bind(to: resultTableView.rx.items(cellIdentifier: "CustomTableViewCell", cellType: CustomTableViewCell.self)) { _, item, cell in
                cell.bind(item: item)
            }.disposed(by: disposeBag)
    }
}

extension Reactive where Base: ViewController {
    var actionOccured: ControlEvent<Base.Sort> {
        let source = base.sortSegment.rx.selectedSegmentIndex
            .compactMap { Base.Sort(rawValue: $0) }
        
        return ControlEvent(events: source)
    }
    
    var isLoading: Binder<Bool> {
        return Binder(base.loadingView) { loadingView, result in
            loadingView.isHidden = result
        }
    }
}

