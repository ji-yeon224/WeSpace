//
//  InviteViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/20/24.
//

import UIKit
import ReactorKit
final class InviteViewController: BaseViewController {
    
    private let mainView = InviteView()
    var disposeBag = DisposeBag()
    var workspace: WorkSpace?
    
    var complete: (() -> Void)?
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reactor = InviteReactor()
    }
    
    override func configure() {
        super.configure()
        title = "팀원 초대"
        configNav()
        mainView.emailForm.textfield.becomeFirstResponder()
    }
    
}

extension InviteViewController: View {
    func bind(reactor: InviteReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
        bindEvent()
    }
    
    private func bindAction(reactor: InviteReactor) {
        mainView.sendButton.rx.tap
            .debounce(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .withLatestFrom(mainView.emailForm.textfield.rx.text.orEmpty, resultSelector: { _, value in
                return value
            })
            .map { Reactor.Action.inviteRequest(id: self.workspace?.workspaceId, email: $0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: InviteReactor) {
        
        reactor.state
            .map { $0.msg }
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .bind(with: self) { owner, value in
                owner.showToastMessage(message: value, position: .top)
            }
            .disposed(by: disposeBag)
        reactor.state
            .map { $0.success }
            .filter { $0 == true }
            .bind(with: self) { owner, _ in
                owner.complete?()
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
    }
    private func bindEvent() {
        mainView.emailForm.textfield.rx.text.orEmpty
            .asDriver()
            .drive(with: self) { owner, value in
                let bool = value.isEmpty
                let color: UIColor = bool ? .inactive : .brand
                owner.mainView.sendButton.isEnabled = !bool
                owner.mainView.sendButton.backgroundColor = color
            }
            .disposed(by: disposeBag)
    }
}

extension InviteViewController {
    func configNav() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Constants.Image.xmark, style: .plain, target: self, action: #selector(xButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = Constants.Color.black
    }
    @objc private func xButtonTapped() {
        dismiss(animated: true)
    }
}
