//
//  EmailLoginViewModel.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/6/24.
//

import Foundation
import RxSwift
import RxCocoa

final class EmailLoginViewModel {
    private let disposeBag = DisposeBag()
    
    struct Input {
        let emailText: ControlProperty<String>
        let passwordText: ControlProperty<String>
        let loginButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let loginButtonEnable: BehaviorRelay<Bool>
        let validationError: PublishRelay<[LoginInputValue]>
        let msg: PublishRelay<String>
    }
    
    func transform(input: Input) -> Output {
        
        let loginButtonEnable = BehaviorRelay(value: false)
        let validationErrors = PublishRelay<[LoginInputValue]>()
        let msg = PublishRelay<String>()
        
        let emailInput = BehaviorRelay(value: false), passInput = BehaviorRelay(value: false)
        let loginRequest = PublishRelay<Bool>()
        
        var email: String?, password: String?
        
        input.emailText
            .bind { value in
                emailInput.accept(!value.isEmpty)
                email = value
            }
            .disposed(by: disposeBag)
        
        input.passwordText
            .bind { value in
                passInput.accept(!value.isEmpty)
                password = value
            }
            .disposed(by: disposeBag)
        
        // 로그인 버튼 활성화 여부
        Observable.combineLatest(emailInput, passInput) { email, password in
            return email && password
        }
        .bind { value in
            loginButtonEnable.accept(value)
        }
        .disposed(by: disposeBag)
        
        var invalidInputs: [LoginInputValue] = []
        input.loginButtonTap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                invalidInputs.removeAll()
                if let email = email, let password = password {
                    if !email.isValidEmail() { invalidInputs.append(.email) }
                    if !password.isValidPassword() { invalidInputs.append(.password)}
                    
                    if invalidInputs.count > 0 { // error
                        validationErrors.accept(invalidInputs)
                        msg.accept(owner.loginInvalidMsg(input: invalidInputs[0]))
                    } else { // login request
                        loginRequest.accept(true)
                    }
                    
                }
                
            }
            .disposed(by: disposeBag)
        
        loginRequest
            .bind { value in
                print("login request \(value)")
            }
        
        return Output(
            loginButtonEnable: loginButtonEnable,
            validationError: validationErrors,
            msg: msg
        )
    }
    
    private func loginInvalidMsg(input: LoginInputValue) -> String {
        switch input {
        case .email:
            LoginToastMessage.invalidEmail.message
        case .password:
            LoginToastMessage.invalidPassword.message
        }
    }
}
