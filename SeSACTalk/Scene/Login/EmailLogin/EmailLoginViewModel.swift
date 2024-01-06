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
    }
    
    func transform(input: Input) -> Output {
        
        let loginButtonEnable = BehaviorRelay(value: false)
        let emailInput = BehaviorRelay(value: false), passInput = BehaviorRelay(value: false)
        
        input.emailText
            .bind { value in
                emailInput.accept(!value.isEmpty)
            }
            .disposed(by: disposeBag)
        
        input.passwordText
            .bind { value in
                passInput.accept(!value.isEmpty)
            }
            .disposed(by: disposeBag)
        
        Observable.combineLatest(emailInput, passInput) { email, password in
            return email && password
        }
        .bind { value in
            loginButtonEnable.accept(value)
        }
        .disposed(by: disposeBag)
        
        return Output(
            loginButtonEnable: loginButtonEnable
        )
    }
}
