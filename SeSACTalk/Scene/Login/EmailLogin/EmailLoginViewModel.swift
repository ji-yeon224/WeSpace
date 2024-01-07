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
        let loginSuccess: PublishRelay<Bool>
    }
    
    func transform(input: Input) -> Output {
        
        let loginButtonEnable = BehaviorRelay(value: false)
        let validationErrors = PublishRelay<[LoginInputValue]>()
        let msg = PublishRelay<String>()
        let loginSuccess = PublishRelay<Bool>()
        
        let emailInput = BehaviorRelay(value: false), passInput = BehaviorRelay(value: false)
        let loginRequest = PublishRelay<EmailLoginRequestDTO>()
        
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
                        let data = EmailLoginRequestDTO(email: email, password: password, deviceToken: nil)
                        loginRequest.accept(data)
                    }
                    
                }
                
            }
            .disposed(by: disposeBag)
        
        loginRequest
            .flatMap {
                UsersAPIManager.shared.request(api: .emailLogin(data: $0), responseType: EmailLoginResponseDTO.self)
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let result):
                    print("[LOGIN SUCCESS]")
                    if let result = result {
                        let token = Token(accessToken: result.accessToken, refreshToken: result.refreshToken)
                        UserDefaultsManager.setToken(token: token)
                        UserDefaultsManager.nickName = result.nickname
                        loginSuccess.accept(true)
                    }
                   
                case .failure(let error):
                    var errorMsg: String = ""
                    if let error = LoginError(rawValue: error.errorCode) {
                        errorMsg = error.localizedDescription
                    } else if let error = CommonError(rawValue: error.errorCode) {
                        print(error.localizedDescription)
                        errorMsg = LoginToastMessage.other.message
                    } else {
                        errorMsg = LoginToastMessage.other.message
                    }
                    msg.accept(errorMsg)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            loginButtonEnable: loginButtonEnable,
            validationError: validationErrors,
            msg: msg,
            loginSuccess: loginSuccess
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
