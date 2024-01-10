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
        msg: "",
        completeCreate: false
    )
    
    
    enum Action {
        case nameInput(name: String)
        case completeButtonTap(name: String, description: String?, image: SelectImage)
    }
    
    enum Mutation {
        case buttonEnable(enable: Bool)
        case msg(msg: String)
        case requestCreate(req: Bool)
    }
    
    struct State {
        var buttonEnable: Bool
        var msg: String
        var completeCreate: Bool
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .nameInput(let name):
            let value = name.count >= 1 && name.count <= 30
            return Observable.just(Mutation.buttonEnable(enable: value))
        case .completeButtonTap(let name, let des, let img):
            return validCheck(name: name, des: des, img: img)
            
        }
        // 유효성 체크,
    }
    
    private func validCheck(name: String, des: String?, img: SelectImage) -> Observable<Mutation> {
        if img.img == nil {
            return Observable.of(.msg(msg: WorkspaceToastMessage.makeNoImage.message))
        }
        if name.count >= 1 && name.count <= 30 {
            return Observable.of(.msg(msg: WorkspaceToastMessage.makeNameInvalid.message))
        }
        return Observable.of(.requestCreate(req: true))
        
    }
    
   
    
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .buttonEnable(let enable):
            newState.buttonEnable = enable
        case .msg(let msg):
            newState.msg = msg
        case .requestCreate(req: let req):
            newState.completeCreate = req
        }
        return newState
    }
    
    
}
