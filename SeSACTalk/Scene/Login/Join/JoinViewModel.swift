//
//  JoinViewModel.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/4/24.
//

import Foundation
import RxSwift
import RxCocoa

final class JoinViewModel {
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let emailValue: ControlProperty<String>
        let nickNameValue: ControlProperty<String>
        let phoneValue: ControlProperty<String>
        let pwValue: ControlProperty<String>
        let checkValue: ControlProperty<String>
        let emailButtonTap: PublishRelay<String>
        let joinButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let checkButtonEnable: BehaviorRelay<Bool>
        let joinButtonEnable: BehaviorRelay<Bool>
        let validationErrors: PublishRelay<[JoinInputValue]>
        let msg: PublishRelay<String>
    }
    
    func transform(input: Input) -> Output {
        let checkButtonEnable = BehaviorRelay(value: false)
        let joinButtonEnable = BehaviorRelay(value: false)
        let validationErrors = PublishRelay<[JoinInputValue]>()
        let msg = PublishRelay<String>()
        
        let emailCheckRequest = PublishRelay<String>()
        let joinRequest = PublishRelay<Bool>()
        
        var email: String?, nickName: String?, phone: String?, password: String?
        let emailValid = BehaviorRelay(value: false)
        let nickNameValid: BehaviorRelay<(String?, Bool)> = BehaviorRelay(value: (nil, false))
        let phoneValid = BehaviorRelay(value: false)
        let passValid: BehaviorRelay<(String?, Bool)> = BehaviorRelay(value: (nil, false))
        let checkValid = BehaviorRelay(value: false)
        
        let emailInput = BehaviorRelay(value: false), nickInput = BehaviorRelay(value: false), passInput = BehaviorRelay(value: false), checkInput = BehaviorRelay(value: false)
        
        
        input.emailValue
            .bind(with: self) { owner, value in
                let bool = !value.isEmpty
                emailInput.accept(bool)
                checkButtonEnable.accept(bool)
                if email != value && emailValid.value {
                    emailValid.accept(false)
                } else if email == value && !emailValid.value{
                    emailValid.accept(true)
                }
                
            }
            .disposed(by: disposeBag)
        
        input.emailButtonTap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, value in
                if emailValid.value {
                    msg.accept(JoinToastMessage.alreadyValid.message)
                } else {
                    if value.isValidEmail() {
                        msg.accept(JoinToastMessage.validEmail.message)
                        emailCheckRequest.accept(value)
                    } else {
                        msg.accept(JoinToastMessage.emailValidationError.message)
                    }
                }
                
            }
            .disposed(by: disposeBag)
        
        
        emailCheckRequest
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map {
                email = $0
                return $0
            }
            .flatMap { email in
                
                UsersAPIManager.shared.request(api: .validation(email: EmailValidationRequest(email: email)), responseType: EmptyResponse.self)
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(_):
                    print("[Valid Email]")
                    emailValid.accept(true)
                case .failure(let error):
                    emailValid.accept(false)
                    email = nil
                    if let error = EmailError(rawValue: error.errorCode) {
                        print(error.localizedDescription)
                    } else if let error = CommonError(rawValue: error.errorCode) {
                        print(error.localizedDescription)
                    } else {
                        print(CommonError.E99.localizedDescription)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.nickNameValue
            .bind(with: self) { owner, value in
                nickInput.accept(!value.isEmpty)
                let valid = 1...30 ~= value.count
                nickNameValid.accept((value, valid))
            }
            .disposed(by: disposeBag)
        
        input.phoneValue
            .bind(with: self) { owner, value in
                phoneValid.accept(value.isValidPhone())
            }
            .disposed(by: disposeBag)
        
        input.pwValue
            .bind(onNext: { value in
                passInput.accept(!value.isEmpty)
                if value.isValidPassword() {
                    passValid.accept((value, true))
                } else {
                    passValid.accept((nil, false))
                }
            })
            .disposed(by: disposeBag)
        
        input.checkValue
            .bind { value in
                if password != value && checkValid.value {
                    checkValid.accept(false)
                }
            }
            .disposed(by: disposeBag)
        
        Observable.combineLatest(input.checkValue, passValid) { check, password in
            checkInput.accept(!check.isEmpty)
            return password.1 && check == password.0
        }
        .bind { value in
            checkValid.accept(value)
        }
        .disposed(by: disposeBag)
        
        
        Observable.combineLatest(emailInput, nickInput, passInput, checkInput) { email, nick, pass, check in
            return email && nick && pass && check
        }
        .bind { value in
            joinButtonEnable.accept(value)
        }
        .disposed(by: disposeBag)
        
        var invalidInputs: [JoinInputValue] = []
        input.joinButtonTap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .bind(with: self, onNext: { owner, _ in
                invalidInputs.removeAll()
                if !emailValid.value { invalidInputs.append(.email)}
                if !nickNameValid.value.1 { invalidInputs.append(.nickname)}
                if !phoneValid.value { invalidInputs.append(.phone)}
                if !passValid.value.1 { invalidInputs.append(.password)}
                if !checkValid.value { invalidInputs.append(.check)}
                
                if invalidInputs.count == 0 {
                    joinRequest.accept(true)
                } else {
                    msg.accept(owner.joinInvalidMsg(input: invalidInputs[0]))
                    validationErrors.accept(invalidInputs)
                }
            })
            .disposed(by: disposeBag)
        
        joinRequest
            .bind { value in
                print("join go")
            }
            .disposed(by: disposeBag)
        
        return Output(
            checkButtonEnable: checkButtonEnable,
            joinButtonEnable: joinButtonEnable,
            validationErrors: validationErrors,
            msg: msg
        )
    }
    
    private func joinInvalidMsg(input: JoinInputValue) -> String {
        switch input {
        case .email:
            return JoinToastMessage.notCheckEmail.message
        case .nickname:
            return JoinToastMessage.nickConditionError.message
        case .phone:
            return JoinToastMessage.phoneValidError.message
        case .password:
            return JoinToastMessage.passwordValidError.message
        case .check:
            return JoinToastMessage.notEqualPassword.message
        }
    }
    
}
