//
//  ChangeCHManagerViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/5/24.
//

import UIKit
import ReactorKit

final class ChangeCHManagerViewController: BaseViewController {
    
    private let mainView = ChangeManagerView()
    var disposeBag = DisposeBag()
    var channel: Channel?
    private var items: [User]?
    private var requestMemberList = PublishSubject<Void>()
    private var requestChangeManager = PublishSubject<Int>()
    
    weak var delegate: ChannelCHManagerDelegate?
    
    override func loadView() {
        self.view = mainView
        
    }
    
    deinit {
        print("ChangeCHMAnager Deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestMemberList.onNext(())
    }
    
    override func configure() {
        super.configure()
        title = "채널 관리자 변경"
        configNav()
        self.reactor = ChangeCHManagerReactor()
    }
    
    
    private func updateSnapShot(data: [User]) {
        var snapshot = NSDiffableDataSourceSnapshot<String, User>()
        snapshot.appendSections([""])
        snapshot.appendItems(data)
        mainView.dataSource.apply(snapshot)
    }
}

extension ChangeCHManagerViewController: View {
    func bind(reactor: ChangeCHManagerReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
        bindEvent()
    }
    
    private func bindAction(reactor: ChangeCHManagerReactor) {
        
        requestMemberList
            .map { Reactor.Action.requestMemberList(wsId: self.channel?.workspaceID, name: self.channel?.name)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        requestChangeManager
            .map { Reactor.Action.requestChangeManager(wsId: self.channel?.workspaceID, name: self.channel?.name, userId: $0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
            
        
        
    }
    private func bindState(reactor: ChangeCHManagerReactor) {
        
        reactor.state
            .map { $0.memberList }
            .distinctUntilChanged()
            .filter { $0 != .none }
            .asDriver(onErrorJustReturn: [])
            .drive(with: self) { owner, value in
                if let value = value {
                    if value.count <= 0 {
                        owner.showPopUp(title: Text.cannotChangeTitle, message: Text.cannotChangeMsg, okTitle: "확인", okCompletion:  {
                            owner.dismiss(animated: true)
                        })
                    } else {
                        owner.items = value
                        owner.updateSnapShot(data: value)
                    }
                }
                
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.changeInfo }
            .distinctUntilChanged()
            .filter { $0 != .none }
            .bind(with: self) { owner, value in
                if let value = value {
                    print("SUCCESS - CHANGEVIEW")
                    owner.delegate?.successChangeCHMAnager(data: value)
                    owner.dismiss(animated: true)
                }
                
            }
            .disposed(by: disposeBag)
        
        
    }
    private func bindEvent() {
        mainView.collectionView.rx.itemSelected
            .asDriver()
            .drive(with: self) { owner, indexpath in
                if let user = owner.items?[indexpath.item] {
                    let title = Text.changeCHManagerTitle.replacingOccurrences(of: "{name}", with: user.nickname)
                    owner.showPopUp(title: title, message: Text.changeCHManagerMessage, align: .left, cancelTitle: "취소", okTitle: "확인") { } okCompletion: {
                        owner.requestChangeManager.onNext(user.userId)
                    }

                }
                
            }
            .disposed(by: disposeBag)
    }
}


extension ChangeCHManagerViewController {
    private func configNav() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Constants.Image.xmark, style: .plain, target: self, action: #selector(xButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = Constants.Color.black
    }
    @objc private func xButtonTapped() {
        dismiss(animated: true)
    }
}
