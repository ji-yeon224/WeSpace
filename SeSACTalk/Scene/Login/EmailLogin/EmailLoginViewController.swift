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
//    private let viewModel = EmailLoginViewModel()
    var disposeBag = DisposeBag()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "이메일 로그인"
//        bind()
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
        .bind(to: reactor.action)
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
    }
    
//    func bind1() {
//        
//        let input = EmailLoginViewModel.Input(
//            emailText: mainView.emailTextField.rx.text.orEmpty,
//            passwordText: mainView.passwordTextField.rx.text.orEmpty,
//            loginButtonTap: mainView.loginButton.rx.tap
//        )
//        
//        let output = viewModel.transform(input: input)
//        
//        output.loginButtonEnable
//            .bind(with: self) { owner, value in
//                owner.mainView.setButtonValid(valid: value)
//            }
//            .disposed(by: disposeBag)
//        
//        output.msg
//            .bind(with: self) { owner, value in
//                owner.showToastMessage(message: value, position: .top)
//            }
//            .disposed(by: disposeBag)
//        
//        output.validationError
//            .bind(with: self) { owner, value in
//                owner.mainView.setEmailValidColor(valid: !value.contains(.email))
//                owner.mainView.setPasswordValidColor(valid: !value.contains(.password))
//            }
//            .disposed(by: disposeBag)
//        output.loginSuccess
//            .bind(with: self) { owner, _ in
//                let vc = HomeEmptyViewController()
//                let nav = UINavigationController(rootViewController: vc)
////                nav.setupLargeTitleBar()
//                owner.view.window?.rootViewController = nav
//                owner.view.window?.makeKeyAndVisible()
//            }
//            .disposed(by: disposeBag)
//    }
//    
    
}
