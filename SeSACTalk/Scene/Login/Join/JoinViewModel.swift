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
    }
    
    struct Output {
        let checkButtonEnable: BehaviorRelay<Bool>
    }
    
    func transform(input: Input) -> Output {
        let checkButtonEnable = BehaviorRelay(value: false)
        let nickNameValid: BehaviorRelay<(String?, Bool)> = BehaviorRelay(value: (nil, false))
        let phoneValid = BehaviorRelay(value: false)
        let passValid: BehaviorRelay<(String?, Bool)> = BehaviorRelay(value: (nil, false))
        let checkValid = BehaviorRelay(value: false)
        
        input.emailValue
            .bind(with: self) { owner, value in
                if value.isValidEmail() {
                    checkButtonEnable.accept(true)
                } else {
                    checkButtonEnable.accept(false)
                }
                    
            }
            .disposed(by: disposeBag)
        
        input.nickNameValue
            .bind(with: self) { owner, value in
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
            .bind(with: self) { owner, value in
                if value.isValidPassword() {
                    passValid.accept((value, true))
                } else {
                    passValid.accept((nil, false))
                }
            }
            .disposed(by: disposeBag)
        
        input.checkValue
            .bind(with: self) { owner, value in
                if passValid.value.1 && (value == passValid.value.0) {
                    checkValid.accept(true)
                    print("pwcheck true")
                }
            }
            .disposed(by: disposeBag)
        
        
        return Output(
            checkButtonEnable: checkButtonEnable
        )
    }
    
    
    
}
