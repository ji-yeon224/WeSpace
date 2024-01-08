//
//  EmailLoginReactor.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/8/24.
//

import Foundation
import ReactorKit

final class EmailLoginReactor: Reactor {
    var initialState: State = State(buttonEnable: false, msg: nil, validationError: [], loginSuccess: false, showIndicator: false)
    
    private var invalidInputs: [LoginInputValue] = []
    
    enum Action {
        
        case inputValue(email: String, password: String)
        case loginButtonTapped(email: String, password: String)
    }
    
    enum Mutation {
        case buttonEnableCheck(isEnable: Bool)
        case invalidInput(invaild: [LoginInputValue])
        case loginSuccess
        case msg(msg: String)
        case showIndicator(show: Bool)
    }
    
    struct State {
        var buttonEnable: Bool
        var msg: String?
        var validationError: [LoginInputValue]
        var loginSuccess: Bool
        var showIndicator: Bool
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .inputValue(let email, let password):
            return Observable.just(Mutation.buttonEnableCheck(isEnable: email.count > 0 && password.count > 0))
        case .loginButtonTapped(let email, let password):
            invalidInputs.removeAll()
            if !email.isValidEmail() { invalidInputs.append(.email) }
            if !password.isValidPassword() { invalidInputs.append(.password) }
            if invalidInputs.count > 0 { // error
                return Observable.concat([
                    Observable.just(Mutation.invalidInput(invaild: invalidInputs)),
                    Observable.just(Mutation.msg(msg: loginInvalidMsg(input: invalidInputs[0]))),
                    Observable.just(Mutation.msg(msg: ""))
                ])
            }else {
                let data = EmailLoginRequestDTO(email: email, password: password, deviceToken: nil)
                return Observable.concat([
                    Observable.just(Mutation.showIndicator(show: true)),
                    reqeustLogin(data: data),
                    Observable.just(Mutation.showIndicator(show: false))
                    
                ])
                    
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .buttonEnableCheck(let isEnable):
            newState.buttonEnable = isEnable
        case .invalidInput(let invalid):
            newState.validationError = invalid
        case .loginSuccess:
            newState.loginSuccess = true
        case .msg(let msg):
            newState.msg = msg
        case .showIndicator(let show):
            newState.showIndicator = show
        }
        
        return newState
    }
    
    private func reqeustLogin(data: EmailLoginRequestDTO) -> Observable<Mutation> {
        
        return UsersAPIManager.shared.request(api: .emailLogin(data: data), responseType: EmailLoginResponseDTO.self)
            .asObservable()
            .map { result -> Mutation in
                switch result {
                case .success(let response):
                    if let result = response {
                        let token = Token(accessToken: result.accessToken, refreshToken: result.refreshToken)
                        UserDefaultsManager.setToken(token: token)
                        UserDefaultsManager.nickName = result.nickname
                        
                    }
                    return Mutation.loginSuccess
                case .failure(let error):
                    var errorMsg: String = ""
                    if let error = LoginError(rawValue: error.errorCode) {
                        errorMsg = error.localizedDescription
                    } else if let error = CommonError(rawValue: error.errorCode) {
                        errorMsg = LoginToastMessage.other.message
                    } else {
                        errorMsg = LoginToastMessage.other.message
                    }
                    
                    return Mutation.msg(msg: errorMsg)
                }
            }
    }
    
    private func loginInvalidMsg(input: LoginInputValue) -> String {
        switch input {
        case .email:
            LoginToastMessage.invalidEmail.message
        case .password:
            LoginToastMessage.invalidPassword.message
        }
    }
}
