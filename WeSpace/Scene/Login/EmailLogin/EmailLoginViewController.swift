//
//  EmailLoginViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/6/24.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

final class EmailLoginViewController: BaseViewController, View {
    
    private let mainView = EmailLoginView()
    var disposeBag = DisposeBag()
    weak var delegate: EmailLoginCompleteDelegate?
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "이메일 로그인"
        self.reactor = EmailLoginReactor()
    }
    
    override func configure() {
        super.configure()
        configNav()
    }
    
    func bind(reactor: EmailLoginReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: EmailLoginReactor) {
        
        Observable.combineLatest(mainView.emailInput.textfield.rx.text.orEmpty, mainView.passwordInput.textfield.rx.text.orEmpty) { email, password in
            return (email, password)
        }
        .map { Reactor.Action.inputValue(email: $0.0, password: $0.1)}
        .observe(on: MainScheduler.asyncInstance)
        .bind(to: reactor.action)
        .disposed(by: disposeBag)
        
        let input = Observable.combineLatest(mainView.emailInput.textfield.rx.text.orEmpty, mainView.passwordInput.textfield .rx.text.orEmpty)
        
        mainView.loginButton.rx.tap
            .withLatestFrom(input) { _, value in
                return value
            }
            .map { Reactor.Action.loginButtonTapped(email: $0.0, password: $0.1) }
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.loginButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.view.endEditing(true)
            }
            .disposed(by: disposeBag)
        
    }
    
    private func bindState(reactor: EmailLoginReactor) {
        reactor.state
            .map { $0.buttonEnable }
            .distinctUntilChanged()
            .bind(with: self) { owner, value in
                owner.mainView.setButtonValid(valid: value)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.msg }
            .filter({ value in
                value != nil
            })
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self) { owner, value in
                if let value = value, !value.isEmpty {
                    print(value)
                    owner.showToastMessage(message: value, position: .top)
                }
                
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.validationError }
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self) { owner, value in
                owner.mainView.setEmailValidColor(valid: !value.contains(.email))
                owner.mainView.setPasswordValidColor(valid: !value.contains(.password))
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.loginSuccess }
            .filter {
                $0 == true
            }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .map { _ in Reactor.Action.fetchWorkspace }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.showIndicator }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self) { owner, value in
                owner.showIndicator(show: value)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.workSpace }
            .filter {
                $0.1 == true
            }
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self) { owner, data in
                owner.dismiss(animated: false)
                owner.delegate?.completeLogin(workspace: data.0)
            }
            .disposed(by: disposeBag)
    }
    
    private func transitionHomeView(vc: UIViewController) {
//        let nav = UINavigationController(rootViewController: vc)
        view.window?.rootViewController = vc
        view.window?.makeKeyAndVisible()
    }
    
}

extension EmailLoginViewController {
    func configNav() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Constants.Image.xmark, style: .plain, target: self, action: #selector(xButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = Constants.Color.black
    }
    @objc private func xButtonTapped() {
        dismiss(animated: true)
    }
}
