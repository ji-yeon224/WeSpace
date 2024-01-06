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
        let kakaoLogin: ControlEvent<Void>
    }
    
    struct Output {
        let loginSuccess: PublishRelay<Bool>
        let msg: PublishRelay<String>
    }
    
    func transform(input: Input) -> Output {
        
        let requestKakao = PublishRelay<KakaoLoginRequestDTO>()
        
        let msg = PublishRelay<String>()
        let loginSuccess = PublishRelay<Bool>()
        
        input.kakaoLogin
            .bind {
                KakaoLoginManager.shared.requestLogin()
            }
            .disposed(by: disposeBag)
        
        KakaoLoginManager.shared.loginRequest
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let oauth):
                    print(oauth)
                    requestKakao.accept(KakaoLoginRequestDTO(oauthToken: oauth, deviceToken: nil))
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: KakaoLoginManager.shared.disposeBag)
        
        requestKakao
            .flatMap {
                UsersAPIManager.shared.request(api: .kakaoLogin(data: $0), responseType: JoinResponseDTO.self)
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let response):
                    if let data = response?.toDomain() {
                        UserDefaultsManager.accessToken = data.accessToken
                        UserDefaultsManager.refreshToken = data.refreshToken
                        UserDefaultsManager.nickName = data.nickname
                    }
                    loginSuccess.accept(true)
                    
                case .failure(let error):
                    let code = error.errorCode
                    var errorMsg = CommonError.E99.localizedDescription
                    if let error = LoginError(rawValue: code) {
                        errorMsg = error.localizedDescription
                    } else if let error = CommonError(rawValue: code) {
                        errorMsg = error.localizedDescription
                    }
                    
                    msg.accept(errorMsg)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            loginSuccess: loginSuccess,
            msg: msg
        )
    }
}
