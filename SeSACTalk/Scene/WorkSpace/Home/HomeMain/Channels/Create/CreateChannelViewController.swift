//
//  CreateChannelViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/21/24.
//

import UIKit
import ReactorKit

final class CreateChannelViewController: BaseViewController {
    
    private let mainView = CreateChannelView()
    private var workspace: WorkSpace?
    private let requestCreate = PublishSubject<String>()
    var createComplete: (() -> Void)?
    
    var disposeBag = DisposeBag()
    
    init(workspace: WorkSpace?) {
        super.init(nibName: nil, bundle: nil)
        self.workspace = workspace
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = mainView
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reactor = CreateChannelReactor()
    }
    
    override func configure() {
        super.configure()
        title = "채널 생성"
        configNav()
    }
    
}

extension CreateChannelViewController: View {
    
    func bind(reactor: CreateChannelReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
        bindEvent()
    }
    
    private func bindAction(reactor: CreateChannelReactor) {
        
        let input = Observable.combineLatest(mainView.nameForm.textfield.rx.text.orEmpty, mainView.descriptionForm.textfield.rx.text.orEmpty)
        
        mainView.createButton.rx.tap
            .withLatestFrom(input) { _, value in
                return value
            }
            .map { Reactor.Action.requestCreate(id: self.workspace?.workspaceId, name: $0.0, desc: $0.1)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        
            
    }
    
    private func bindState(reactor: CreateChannelReactor) {
        reactor.state
            .map { $0.msg }
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .bind(with: self) { owner, value in
                owner.showToastMessage(message: value, position: .top)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.successCreate }
            .filter { $0 == true }
            .distinctUntilChanged()
            .bind(with: self) { owner, _ in
                owner.createComplete?()
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.showIndicator }
            .distinctUntilChanged()
            .bind(with: self) { owner, value in
                owner.showIndicator(show: value)
            }
            .disposed(by: disposeBag)
        
    }
    
    private func bindEvent() {
        mainView.nameForm.textfield.rx.text.orEmpty
            .asDriver()
            .drive(with: self) { owner, value in
                let empty = value.isEmpty
                owner.mainView.createButton.isEnabled = !empty
                let color: UIColor = empty ? .inactive : .brand
                owner.mainView.createButton.backgroundColor = color
            }
            .disposed(by: disposeBag)
    }
    
}

extension CreateChannelViewController {
    func configNav() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Constants.Image.xmark, style: .plain, target: self, action: #selector(xButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = Constants.Color.black
    }
    @objc private func xButtonTapped() {
        dismiss(animated: true)
    }
}

