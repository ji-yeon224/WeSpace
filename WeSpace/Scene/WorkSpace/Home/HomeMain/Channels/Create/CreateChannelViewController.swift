//
//  CreateChannelViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/21/24.
//

import UIKit
import ReactorKit
import RxCocoa

final class CreateChannelViewController: BaseViewController {
    
    private let mainView = CreateChannelView()
//    private var workspace: WorkSpace?
    private let requestCreate = PublishSubject<String>()
    
    private var nameChange = BehaviorRelay<Bool>(value: false)
    private var descChange = BehaviorRelay<Bool>(value: false)
    
    var createComplete: (() -> Void)?
    var updateComplete: ((Channel) -> Void)?
    
    var mode: CreateType = .create
    var wsId: Int?
    var channel: Channel?
    
    var disposeBag = DisposeBag()
    
    init(wsId: Int, channel: Channel? = nil, mode: CreateType = .create) {
        super.init(nibName: nil, bundle: nil)
//        self.workspace = workspace
        self.wsId = wsId
        self.mode = mode
        self.channel = channel
    }
    
    deinit {
        print("CreateChannelVC deinit")
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
        switch mode {
        case .create:
            title = "채널 생성"
        case .edit:
            title = "채널 편집"
            configEditData()
        }
        
        configNav()
    }
    
    private func configEditData() {
        guard let channel = channel else { return }
        mainView.nameForm.textfield.text = channel.name
        if let description = channel.description {
            mainView.descriptionForm.textfield.text = description
        }
        mainView.createButton.setTitle("완료", for: .normal)
    }
    
}

extension CreateChannelViewController: View {
    
    func bind(reactor: CreateChannelReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
        switch mode {
        case .create:
            createBindEvent()
        case .edit:
            editBindEvent()
        }
    }
    
    private func bindAction(reactor: CreateChannelReactor) {
        
        let input = Observable.combineLatest(mainView.nameForm.textfield.rx.text.orEmpty, mainView.descriptionForm.textfield.rx.text.orEmpty)
        
        mainView.createButton.rx.tap
            .withLatestFrom(input) { _, value in
                return value
            }
            .map {
                if self.mode == .create {
                    return Reactor.Action.requestCreate(id: self.wsId, name: $0.0, desc: $0.1)
                } else {
                    let data = CreateChannelReqDTO(name: $0.0, description: $0.1)
                    return Reactor.Action.requestEdit(id: self.wsId, name: self.channel?.name, updateData: data)
                }
                
            }
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
            .map { $0.successEdit }
            .filter { $0 != .none }
            .distinctUntilChanged()
            .bind(with: self) { owner, value in
                if let value = value {
                    owner.updateComplete?(value)
                }
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
    }
    
    private func createBindEvent() {
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
    
    private func editBindEvent() {
        mainView.descriptionForm.textfield.rx.text.orEmpty
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
            .drive(with: self) { owner, value in
                let empty = value.isEmpty || value == owner.channel?.description
                owner.descChange.accept(!empty)
            }
            .disposed(by: disposeBag)
        
        mainView.nameForm.textfield.rx.text.orEmpty
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
            .drive(with: self) { owner, value in
                let empty = value.isEmpty || value == owner.channel?.name
                owner.nameChange.accept(!empty)
            }
            .disposed(by: disposeBag)
        
        Observable.combineLatest(nameChange, descChange) { name, desc in
            return name || desc
        }
        .distinctUntilChanged()
        .asDriver(onErrorJustReturn: false)
        .drive(with: self) { owner, change in
            owner.mainView.createButton.isEnabled = change
            let color: UIColor = change ? .brand : .inactive
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

