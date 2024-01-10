//
//  MakeViewReactor.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/10/24.
//

import Foundation
import ReactorKit

final class MakeViewReactor: Reactor {
    var initialState: State = State(
        buttonEnable: false,
        msg: ""
    )
    
    
    enum Action {
        case nameInput(name: String)
    }
    
    enum Mutation {
        case buttonEnable(enable: Bool)
        case msg(msg: String)
    }
    
    struct State {
        var buttonEnable: Bool
        var msg: String
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .nameInput(let name):
            let value = name.count >= 1 && name.count <= 30
            return Observable.just(Mutation.buttonEnable(enable: value))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .buttonEnable(let enable):
            newState.buttonEnable = enable
        case .msg(let msg):
            newState.msg = msg
        }
        return newState
    }
    
}
