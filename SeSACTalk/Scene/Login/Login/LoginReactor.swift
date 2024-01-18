//
//  LoginReactor.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/8/24.
//

import Foundation
import ReactorKit

final class LoginReactor: Reactor {
    var initialState: State = State(
        kakaoLoginSuccess: "",
        loginSuccess: false,
        indicator: false,
        workspace: (nil, false)
    )
    
    
    enum Action {
        case kakaoLogin
        case requestKakaoComplete(oauth: String)
        case fetchWorkspace
    }
    
    enum Mutation {
        case kakaoSuccess(oauth: String)
        case msg(msg: String)
        case kakaoRequestComplete
        case showIndicator(show: Bool)
        case fetchWorkspace(data: WorkSpace?)
    }
    
    struct State {
        var kakaoLoginSuccess: String
        var loginSuccess: Bool
        var msg: String?
        var indicator: Bool
        var workspace: (WorkSpace?, Bool)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .kakaoLogin:
            KakaoLoginManager.shared.requestLogin()
            return KakaoLoginManager.shared.loginRequest
                .map { (result) -> Mutation in
                    switch result {
                    case.success(let oauth):
                        print("kakao success")
                        return Mutation.kakaoSuccess(oauth: oauth)
                    case .failure(let error):
                        print("kakao fail")
                        return Mutation.msg(msg: error.localizedDescription)
                    }
                }
        case .requestKakaoComplete(let oauth):
            return Observable.concat([
                requestLoginComplete(oauth: oauth)
            ])
        case .fetchWorkspace:
            return Observable.concat([
                Observable.just(Mutation.showIndicator(show: true)),
                requestFetchWorkspace(),
                Observable.just(Mutation.showIndicator(show: false))
            ])
            
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
        case .showIndicator(show: let show):
            newState.indicator = show
        case .fetchWorkspace(data: let data):
            newState.workspace = (data, true)
        }
        return newState
    }
        
}

extension LoginReactor {
    private func requestLoginComplete(oauth: String) -> Observable<Mutation> {
        let oauthRequest = KakaoLoginRequestDTO(oauthToken: oauth, deviceToken: nil)
        return UsersAPIManager.shared.request(api: .kakaoLogin(data: oauthRequest), responseType: JoinResponseDTO.self)
            .asObservable()
            .map { result -> Mutation in
                switch result {
                case .success(let response):
                    if let response = response {
                        UserDefaultsManager.setToken(token: response.token)
                        UserDefaultsManager.nickName = response.nickname
                        UserDefaultsManager.setUserInfo(id: response.user_id, nickName: response.nickname)
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
    
    private func requestFetchWorkspace() -> Observable<Mutation> {
        return LoginCompletedManager.shared.workSpaceTransition()
            .asObservable()
            .map { result -> Mutation in
                switch result {
                case .success(let data):
                    return Mutation.fetchWorkspace(data: data)
                case .failure(let failure):
                    return Mutation.msg(msg: failure.localizedDescription)
                    
                }
                
            }
    }
    
}
