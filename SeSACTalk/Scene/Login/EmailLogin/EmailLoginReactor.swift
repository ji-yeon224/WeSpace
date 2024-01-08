//
//  EmailLoginReactor.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/8/24.
//

import Foundation
import ReactorKit

final class EmailLoginReactor: Reactor {
    var initialState: State = State(buttonEnable: false, msg: nil, validationError: [], loginSuccess: false)
    
    
    enum Action {
        
        case inputValue(email: String, password: String)
        
    }
    
    enum Mutation {
        case buttonEnableCheck(isEnable: Bool)
    }
    
    struct State {
        var buttonEnable: Bool
        var msg: String?
        var validationError: [LoginInputValue]
        var loginSuccess: Bool
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .inputValue(let email, let password):
            return Observable.just(Mutation.buttonEnableCheck(isEnable: email.count > 0 && password.count > 0))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .buttonEnableCheck(let isEnable):
            newState.buttonEnable = isEnable
        }
        
        return newState
    }
    
}
