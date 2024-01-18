//
//  ChangeManagerViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/18/24.
//

import UIKit
import ReactorKit

final class ChangeManagerViewController: BaseViewController, View {
    
    var disposeBag = DisposeBag()
    var workspace: WorkSpace?
    private var items: [User]?
    
    weak var delegate: ChangeManageDelegate?
    
    private let mainView = ChangeManagerView()
    private let requestMember = PublishSubject<Void>()
    private let noMemberAlert = PublishSubject<Void>()
    private let requestChange = PublishSubject<Int>()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "워크스페이스 관리자 변경"
        self.reactor = ChangeManagerReactor()
        requestMember.onNext(())
        

    }
    
    func bind(reactor: ChangeManagerReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
        bindEvent()
    }
    
    private func bindAction(reactor: ChangeManagerReactor) {
        requestMember
            .map { Reactor.Action.requestMember(id: self.workspace?.workspaceId) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        requestChange
            .map { Reactor.Action.requestChange(wsId: self.workspace?.workspaceId, userId: $0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: ChangeManagerReactor) {
        reactor.state
            .map { $0.memberInfo }
            .filter{ $0 != .none }
            .distinctUntilChanged()
            .bind(with: self) { owner, value in
                if let value = value, !value.isEmpty {
                    owner.items = value
                    
                } else {
                    owner.showPopUp(title: Text.noMemberTitle, message: Text.noMemberMessage,rightActionTitle: "확인", rightActionCompletion:  {
                        owner.dismiss(animated: true)
                    })
                }
                owner.updateSnapShot(data: owner.items ?? [])
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.loginRequest }
            .filter { $0 == true }
            .distinctUntilChanged()
            .bind(with: self) { owner, _ in
                let vc = OnBoardingViewController()
                let nav = UINavigationController(rootViewController: vc)
                owner.view.window?.rootViewController = nav
                owner.view.window?.makeKeyAndVisible()
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.msg }
            .filter { $0.count > 0 }
            .distinctUntilChanged()
            .bind(with: self) { owner, value in
                owner.showToastMessage(message: value, position: .bottom)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.successChange }
            .filter { $0 != .none }
            .distinctUntilChanged()
            .bind(with: self) { owner, value in
                if let value = value {
                    NotificationCenter.default.post(name: .resetWS, object: nil, userInfo: [UserInfo.workspace: value])
                    owner.delegate?.completeChanageManager(data: value)
                    owner.dismiss(animated: true)
                }
                
            }
            .disposed(by: disposeBag)
    }
    
    private func updateSnapShot(data: [User]) {
        var snapshot = NSDiffableDataSourceSnapshot<String, User>()
        snapshot.appendSections([""])
        snapshot.appendItems(data)
        mainView.dataSource.apply(snapshot)
    }
    
    private func bindEvent() {
        
        mainView.collectionView.rx.itemSelected
            .bind(with: self) { owner, indexPath in
                let user = owner.items?[indexPath.item]
                
                if let user = user {
                    let title = Text.changeManagerTitle.replacingOccurrences(of: "{name}", with: user.nickname)
                    
                    owner.showPopUp(title: title, message: Text.changeManagerMessage, align: .left, leftActionTitle: "취소", rightActionTitle: "확인") {
                        
                    } rightActionCompletion: {
                        
                        owner.requestChange.onNext(user.userId)
                    }
                }
                
                

            }
            .disposed(by: disposeBag)
        
    }
    
    
    
}
