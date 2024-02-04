//
//  CreateChannelReactor.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/21/24.
//

import Foundation
import ReactorKit

final class CreateChannelReactor: Reactor {
    var initialState: State = State(successCreate: false, successEdit: nil, msg: "", loginRequest: false)
    
    private var channelRepository = ChannelRepository()
    enum Action {
        case requestCreate(id: Int?, name: String, desc: String?)
        case requestEdit(id: Int?, name: String?, updateData: CreateChannelReqDTO)
    }
    
    enum Mutation {
        case successCreate
        case successEdit(data: Channel)
        case msg(msg: String)
        case loginRequest
    }
    
    struct State {
        var successCreate: Bool
        var successEdit: Channel?
        var msg: String
        var loginRequest: Bool
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestCreate(let id, let name, let desc):
            if let id = id {
                return requestCreate(id: id, data: CreateChannelReqDTO(name: name, description: desc))
            }
            return .just(.msg(msg: ChannelToastMessage.otherError.message))
        case .requestEdit(let id, let name, let updateData):
            if let id = id, let name = name {
                return requestEdit(id: id, name: name, data: updateData)
            }
            return .just(.msg(msg: ChannelToastMessage.otherError.message))
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .successCreate:
            newState.successCreate = true
        case .successEdit(let data):
            newState.successEdit = data
        case .msg(let msg):
            newState.msg = msg
        case .loginRequest:
            newState.loginRequest = true
        }
        return newState
    }
    
}

extension CreateChannelReactor {
    
    private func requestEdit(id: Int, name: String, data: CreateChannelReqDTO) -> Observable<Mutation> {
        return ChannelsAPIManager.shared.request(api: .edit(id: id, name: name, data: data), responseType: ChannelResDTO.self)
            .asObservable()
            .map { result -> Mutation in
                switch result {
                case .success(let response):
                    if let response = response {
                        let data = response.toDomain()
                        
                        if self.updateDB(data: data) {
                            return .successEdit(data: data)
                        }
                        return .msg(msg: ChannelToastMessage.otherError.message)
                        
                    }
                    return .msg(msg: ChannelToastMessage.otherError.message)
                    
                case .failure(let error):
                    debugPrint("[EDIT INFO ERROR] ")
                    var msg = CommonError.E99.localizedDescription
                    if let error = ChannelCreateError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    } else if let error = CommonError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    } else {
                        return .loginRequest
                    }
                    return .msg(msg: msg)
                }
            }
    }
    
    private func updateDB(data: Channel) -> Bool {
        if let channelDto = channelRepository.searchChannel(wsId: data.workspaceID, chId: data.channelID).first {
            do {
                try channelRepository.updateChannelInfo(data: channelDto, name: data.name)
                NotificationCenter.default.post(name: .refreshChannel, object: nil)
                return true
            } catch {
                debugPrint("[UPDATE DB ERROR] ", error.localizedDescription)
                return false
            }
        }
        return false
    }
    
    private func requestCreate(id: Int, data: CreateChannelReqDTO) -> Observable<Mutation> {
        
        return ChannelsAPIManager.shared.request(api: .create(id: id, data: data), responseType: ChannelResDTO.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                
                switch result {
                case .success(_):
                    return .of(Mutation.successCreate)
                    
                    
                case .failure(let error):
                    var msg = CommonError.E99.localizedDescription
                    if let error = ChannelCreateError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    } else if let error = CommonError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    } else {
                        return .of(Mutation.loginRequest)
                    }
                    return .of(Mutation.msg(msg: msg))
                }
                
            }
        
    }
}
