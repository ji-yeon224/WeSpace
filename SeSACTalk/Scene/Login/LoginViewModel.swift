//
//  LoginViewModel.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/6/24.
//

import Foundation
import RxSwift
import RxCocoa

final class LoginViewModel {
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let kakaoLoginRequest: ControlEvent<Void>
    }
    
    struct Output {
        
    }
    
    func transform(input: Input) {
        
        
        
        input.kakaoLoginRequest
            .bind {
                KakaoLoginManager.shared.requestLogin()
            }
            .disposed(by: disposeBag)
        
        KakaoLoginManager.shared.loginRequest
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let oauth):
                    print(oauth)
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: KakaoLoginManager.shared.disposeBag)
        
    }
}
