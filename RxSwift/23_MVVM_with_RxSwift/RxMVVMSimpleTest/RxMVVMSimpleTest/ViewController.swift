//
//  ViewController.swift
//  RxMVVMSimpleTest
//
//  Created by Groot on 2023/03/12.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

protocol ViewControllerBindable {
    // state (viewModel > view)
    var labelText: Driver<String?> { get }
    
    // action (view > viewModel)
    var upButtonTapped: PublishSubject<Void> { get }
    var downButtonTapped: PublishSubject<Void> { get }
    var actionOccurred: PublishSubject<ViewController.Action> { get }
}

class ViewController: UIViewController {
    
    enum Action {
        case up
        case down
    }
    
    private var disposeBag = DisposeBag()
    
    let upButton: UIButton
    let downButton: UIButton
    let label: UILabel
    
    func bind(_ viewModel: ViewControllerBindable) {
        self.disposeBag = DisposeBag()
        
        viewModel.labelText
            .drive(self.rx.text)
            .disposed(by: disposeBag)
        
        self.rx.actionOccured
            .bind(to: viewModel.actionOccurred)
            .disposed(by: disposeBag)
    }
    
    init() {
        self.upButton = UIButton().then{
            $0.setTitle("up", for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 30)
        }
        
        self.downButton = UIButton().then{
            $0.setTitle("down", for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 30)
        }
        
        self.label = UILabel().then {
            $0.font = .systemFont(ofSize: 30)
            $0.textColor = .blue
            $0.text = "Hello"
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    private func layout() {
        [upButton, downButton, label]
            .forEach { view.addSubview($0) }
        
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        upButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-50)
        }
        
        downButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(50)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
}

extension Reactive where Base: ViewController {
    var text: Binder<String?> {
        return Binder.init(base.label) { label, text in
            label.text = text
        }
    }
    
    var actionOccured: ControlEvent<Base.Action> {
        let source = Observable
            .merge(base.upButton.rx.tap.map { Base.Action.up },
                   base.downButton.rx.tap.map { Base.Action.down} )
            .take(until: deallocated)
        
        return ControlEvent(events: source)
    }
}
