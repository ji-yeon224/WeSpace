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
    }
    
    func transform(input: Input) -> Output {
        let checkButtonEnable = BehaviorRelay(value: false)
        let joinButtonEnable = BehaviorRelay(value: false)
        
        var email: String?
        let emailValid = BehaviorRelay(value: false)
        let nickNameValid: BehaviorRelay<(String?, Bool)> = BehaviorRelay(value: (nil, false))
        let phoneValid = BehaviorRelay(value: false)
        let passValid: BehaviorRelay<(String?, Bool)> = BehaviorRelay(value: (nil, false))
        let checkValid = BehaviorRelay(value: false)
        
        var emailInput = BehaviorRelay(value: false), nickInput = BehaviorRelay(value: false), passInput = BehaviorRelay(value: false), checkInput = BehaviorRelay(value: false)
        
        input.emailValue
            .bind(with: self) { owner, value in
                emailInput.accept(!value.isEmpty)
                if value.isValidEmail() {
                    checkButtonEnable.accept(true)
                } else {
                    checkButtonEnable.accept(false)
                    emailValid.accept(false)
                }
                    
            }
            .disposed(by: disposeBag)
        
        input.emailButtonTap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map {
                print("check")
                email = $0
                return $0
            }
            .flatMap { email in
                
                UsersAPIManager.shared.request(api: .validation(email: EmailValidationRequest(email: email)), responseType: EmptyResponse.self)
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let response):
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
        
        
//        input.joinButtonTap
//            .throttle(.seconds(1), scheduler: MainScheduler.instance)
//            .bind { _ in
//                print("tap")
//            }
        
//        Observable.combineLatest(emailValid, nickNameValid, passValid, checkValid) { email, nick, password, check in
//            return email && nick.1 && password.1 && check
//        }
//        .bind(onNext: { value in
//            joinButtonEnable.accept(value)
//        })
//        .disposed(by: disposeBag)
        
        
        
        return Output(
            checkButtonEnable: checkButtonEnable,
            joinButtonEnable: joinButtonEnable
        )
    }
    
    
    
}
