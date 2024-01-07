//
//  LoginReactor.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/8/24.
//

import Foundation
import ReactorKit

final class LoginReactor: Reactor {
    var initialState: State = State(kakaoLoginSuccess: "", loginSuccess: false)
    
    
    enum Action {
        case kakaoLogin
        case requestKakaoComplete(oauth: String)
    }
    
    enum Mutation {
        case kakaoSuccess(oauth: String)
        case msg(msg: String)
        case kakaoRequestComplete
    }
    
    struct State {
        var kakaoLoginSuccess: String
        var loginSuccess: Bool
        var msg: String?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .kakaoLogin:
            KakaoLoginManager.shared.requestLogin()
            return KakaoLoginManager.shared.loginRequest
                .map { (result) -> Mutation in
                    switch result {
                    case.success(let oauth):
                        print("kakao success", oauth)
                        return Mutation.kakaoSuccess(oauth: oauth)
                    case .failure(let error):
                        print("kakao fail")
                        return Mutation.msg(msg: error.localizedDescription)
                    }
                }
        case .requestKakaoComplete(let oauth):
            return Observable.just(KakaoLoginRequestDTO(oauthToken: oauth, deviceToken: nil))
                .flatMap {
                    UsersAPIManager.shared.request(api: .kakaoLogin(data: $0), responseType: JoinResponseDTO.self)
                }
                .map { result -> Mutation in
                    switch result {
                    case .success(let response):
                        if let response = response {
                            UserDefaultsManager.setToken(token: response.token)
                            UserDefaultsManager.nickName = response.nickname
                        }
                        return Mutation.kakaoRequestComplete
                    case .failure(let error):
                        let code = error.errorCode
                        var errorMsg = CommonError.E99.localizedDescription
                        if let error = LoginError(rawValue: code) {
                            errorMsg = error.localizedDescription
                        } else if let error = CommonError(rawValue: code) {
                            errorMsg = error.localizedDescription
                        }
                        return Mutation.msg(msg: errorMsg)
                    }
                }
            
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .kakaoSuccess(let oauth):
            newState.kakaoLoginSuccess = oauth
        case .msg(let msg):
            newState.msg = msg
        case .kakaoRequestComplete:
            newState.loginSuccess = true
        }
        return newState
    }
        
}
