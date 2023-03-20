//
//  MainViewController.swift
//  YetonBooks
//
//  Created by 이예은 on 2023/02/04.
//

import UIKit
import RxSwift
import RxCocoa

class MainViewController: UIViewController {
    let searchBar = UISearchBar()
    var sortButtonDidTap = PublishSubject<Void>()
    let networkManager = SearchBookNetwork()
    let viewModel: BookViewModel
    var disposeBag = DisposeBag()
    
    init(viewModel: BookViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 130
        tableView.backgroundColor = .boBackground
        tableView.register(BookCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var filterButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "rectangle.grid.1x2"), style: .done, target: nil, action: nil)
        button.tintColor = .white
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.input.viewDidLoad()
        setUpNavigationBar()
        setUpView()
        bind()
    }
    
    func bind() {
        viewModel.output._model
            .subscribe(onNext: { book in
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            })
            .disposed(by: disposeBag)
        
        searchBar
            .rx.text
            .orEmpty
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .filter { !$0.isEmpty }
            .flatMapLatest { text in
                return SearchBookNetwork().searchBook(query: text)
            }
            .observeOn(MainScheduler.instance) // observe 왜쓰더라..
            .subscribe(onNext: { [weak self] result in
                self?.viewModel.output._model.onNext(result.documents)
                self?.viewModel.model = result.documents
            })
            .disposed(by: disposeBag)
        
        filterButton
            .rx.tap
            .bind(to: sortButtonDidTap)
            .disposed(by: disposeBag)
        
        sortButtonDidTap
            .subscribe(onNext: { event in
                let actionSheet = UIAlertController(title: "", message: "정렬 방법을 선택해주세요.", preferredStyle: .actionSheet)
                
                actionSheet.addAction(UIAlertAction(title: "가격 순 정렬", style: .default, handler: {(ACTION:UIAlertAction) in
                    self.viewModel.input.priceSortButtonDidTap(text: self.searchBar.text)
                }))
                
                actionSheet.addAction(UIAlertAction(title: "출판일 순 정렬", style: .default, handler: {(ACTION:UIAlertAction) in
                    self.viewModel.input.dateTimeSortButtonDidTap(text: self.searchBar.text)
                }))
                
                actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
                
                self.present(actionSheet, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    func setUpNavigationBar() {
        searchBar.placeholder = "Search User"
        searchBar.searchTextField.textColor = .white
        self.navigationItem.titleView = searchBar
        
        navigationItem.title = "Yeton Books"
        navigationItem.setRightBarButton(filterButton, animated: true)
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let backButton = UIBarButtonItem(title: "목록", style: .plain, target: self, action: nil)
        backButton.tintColor = .white
        self.navigationItem.backBarButtonItem = backButton
    }
    
    func setUpView() {
        view.backgroundColor = .boBackground
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let model = viewModel.model else {
            return 1
        }
        return model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell =
                tableView.dequeueReusableCell(BookCell.self, for: indexPath) else {
            return UITableViewCell()
        }
        
        cell.setup(book: viewModel.model?[indexPath.row], index: indexPath.row)
        return cell
    }
}
