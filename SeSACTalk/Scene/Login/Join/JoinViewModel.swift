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
        let emailValid: ControlProperty<String>
    }
    
    struct Output {
        let checkButtonEnable: BehaviorRelay<Bool>
    }
    
    func transform(input: Input) -> Output {
        let checkButtonEnable = BehaviorRelay(value: false)
        
        input.emailValid
            .bind(with: self) { owner, value in
                if value.contains("@") && value.contains(".com") {
                    checkButtonEnable.accept(true)
                } else {
                    checkButtonEnable.accept(false)
                }
                    
            }
            .disposed(by: disposeBag)
        
        
        return Output(
            checkButtonEnable: checkButtonEnable
        )
    }
    
    
    
}
