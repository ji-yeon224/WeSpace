//
//  EmailLoginViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/6/24.
//

import UIKit
import RxSwift
import RxCocoa

final class EmailLoginViewController: BaseViewController {
    
    private let mainView = EmailLoginView()
    private let viewModel = EmailLoginViewModel()
    private let disposeBag = DisposeBag()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "이메일 로그인"
        bind()
    }
    
    override func configure() {
        super.configure()
        
    }
    
    func bind() {
        
        let input = EmailLoginViewModel.Input(
            emailText: mainView.emailTextField.rx.text.orEmpty,
            passwordText: mainView.passwordTextField.rx.text.orEmpty,
            loginButtonTap: mainView.loginButton.rx.tap
        )
        
        let output = viewModel.transform(input: input)
        
        output.loginButtonEnable
            .bind(with: self) { owner, value in
                owner.mainView.setButtonValid(valid: value)
            }
            .disposed(by: disposeBag)
        
        output.msg
            .bind(with: self) { owner, value in
                owner.showToastMessage(message: value, position: .top)
            }
            .disposed(by: disposeBag)
        
        output.validationError
            .bind(with: self) { owner, value in
                owner.mainView.setEmailValidColor(valid: !value.contains(.email))
                owner.mainView.setPasswordValidColor(valid: !value.contains(.password))
            }
            .disposed(by: disposeBag)
        output.loginSuccess
            .bind(with: self) { owner, _ in
                let vc = InitialViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.setupBarAppearance()
                owner.view.window?.rootViewController = nav
                owner.view.window?.makeKeyAndVisible()
            }
            .disposed(by: disposeBag)
    }
    
    
}
