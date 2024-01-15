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
        completeCreate: (nil, false)
    )
    
    
    enum Action {
        case nameInput(name: String)
        case completeButtonTap(name: String, description: String?, image: SelectImage)
    }
    
    enum Mutation {
        case buttonEnable(enable: Bool)
        case msg(msg: String)
        case successCreate(data: WorkspaceDto)
    }
    
    struct State {
        var buttonEnable: Bool
        var msg: String
        var completeCreate: (WorkSpace?, Bool)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .nameInput(let name):
            let value = name.count >= 1 && name.count <= 30
            return Observable.just(Mutation.buttonEnable(enable: value))
        case .completeButtonTap(let name, let des, let img):
            return validCheck(name: name, des: des, img: img)
            
        }
        
    }
    
   
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .buttonEnable(let enable):
            newState.buttonEnable = enable
        case .msg(let msg):
            newState.msg = msg
        case .successCreate(data: let data):
            newState.completeCreate = (data.toDomain(), true)
        }
        return newState
    }
    
    
}

extension MakeViewReactor {
    private func validCheck(name: String, des: String?, img: SelectImage) -> Observable<Mutation> {
        if img.img == nil {
            return Observable.of(.msg(msg: WorkspaceToastMessage.makeNoImage.message))
        }
        if name.count < 1 || name.count > 30 {
            return Observable.of(.msg(msg: WorkspaceToastMessage.makeNameInvalid.message))
        }
        return requestCreateWS(name: name, des: des, img: img)
        
    }
    
    private func requestCreateWS(name: String, des: String?, img: SelectImage) -> Observable<Mutation> {
        if let img = img.img {
            if let imgData = img.imageToData() {
                let data = WsCreateReqDTO(name: name, description: des, image: imgData)
                return WorkspacesAPIManager.shared.request(api: .create(data: data), resonseType: WorkspaceDto.self)
                    .asObservable()
                    .map { result -> Mutation in
                        switch result {
                        case .success(let response):
                            if let response = response {
                                return .successCreate(data: response)
                            }
                            else {
                                return .msg(msg: CommonError.E99.rawValue)
                            }
                            
                        case .failure(let error):
                            if let error = WSCreateError(rawValue: error.errorCode) {
                                return .msg(msg: error.localizedDescription)
                            } else if let error = CommonError(rawValue: error.errorCode) {
                                return .msg(msg: error.localizedDescription)
                            } else {
                                return .msg(msg: CommonError.E99.rawValue)
                            }
                        }
                        
                    }
                    
            }
            else {
                return Observable.of(.msg(msg: "이미지 용량을 확인해주세요."))
            }
            
        }
        else {
            return Observable.of(.msg(msg: WorkspaceToastMessage.makeNoImage.message))
        }
        
        
    }
    
    
    
}
