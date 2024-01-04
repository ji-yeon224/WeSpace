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
    }
    
    struct Output {
        let checkButtonEnable: BehaviorRelay<Bool>
    }
    
    func transform(input: Input) -> Output {
        let checkButtonEnable = BehaviorRelay(value: false)
        let nickNameValid = BehaviorRelay(value: false)
        let phoneValid = BehaviorRelay(value: false)
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
                nickNameValid.accept(valid)
            }
            .disposed(by: disposeBag)
        
        input.phoneValue
            .bind(with: self) { owner, value in
                phoneValid.accept(value.isValidPhone())
            }
            .disposed(by: disposeBag)
        
        
        return Output(
            checkButtonEnable: checkButtonEnable
        )
    }
    
    
    
}
