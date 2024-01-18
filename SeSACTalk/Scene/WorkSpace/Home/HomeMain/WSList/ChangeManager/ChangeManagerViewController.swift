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
    
    
    private let mainView = ChangeManagerView()
    private let requestMember = PublishSubject<Void>()
    private let noMemberAlert = PublishSubject<Void>()
    
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
                    owner.showPopUp(title: Text.noMemberTitle, message: Text.noMemberMessage, rightActionTitle: "확인", rightActionCompletion:  {
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
                
                let title = Text.changeManagerTitle.replacingOccurrences(of: "{name}", with: user?.nickname ?? "user")
                
                owner.showPopUp(title: title, message: Text.changeManagerMessage, leftActionTitle: "확인", rightActionTitle: "취소") {
                    
                } rightActionCompletion: {
                    
                }

            }
            .disposed(by: disposeBag)
        
    }
    
    
    
}
