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
        
    }
    
    func bind(reactor: EmailLoginReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: EmailLoginReactor) {
        
        Observable.combineLatest(mainView.emailTextField.rx.text.orEmpty, mainView.passwordTextField.rx.text.orEmpty) { email, password in
            return (email, password)
        }
        .map { Reactor.Action.inputValue(email: $0.0, password: $0.1)}
        .observe(on: MainScheduler.asyncInstance)
        .bind(to: reactor.action)
        .disposed(by: disposeBag)
        
        let input = Observable.combineLatest(mainView.emailTextField.rx.text.orEmpty, mainView.passwordTextField.rx.text.orEmpty)
        
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
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self, onNext: { owner, value in
                if value {
                    owner.transitionHomeView()
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.showIndicator }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self) { owner, value in
                owner.showIndicator(show: value)
            }
            .disposed(by: disposeBag)
    }
    
    private func transitionHomeView() {
        let vc = HomeEmptyViewController()
        let nav = UINavigationController(rootViewController: vc)
//                nav.setupLargeTitleBar()
        view.window?.rootViewController = nav
        view.window?.makeKeyAndVisible()
    }
    
}
