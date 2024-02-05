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
    
    override func loadView() {
        self.view = mainView
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let user = [
//            User(userId: 1, email: "aa", nickname: "aa", profileImage: nil),
//            User(userId: 2, email: "bb", nickname: "bb", profileImage: nil),
//            User(userId: 3, email: "cc", nickname: "cc", profileImage: nil)
//        
//        ]
//        updateSnapShot(data: user)
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
    }
    
    private func bindAction(reactor: ChangeCHManagerReactor) {
        
        requestMemberList
            .map { Reactor.Action.requestMemberList(wsId: self.channel?.workspaceID, name: self.channel?.name)}
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
                        
                        owner.updateSnapShot(data: value)
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
