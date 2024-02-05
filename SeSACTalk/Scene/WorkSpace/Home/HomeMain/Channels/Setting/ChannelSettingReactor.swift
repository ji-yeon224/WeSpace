//
//  ChannelSettingReactor.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/4/24.
//

import Foundation
import ReactorKit

final class ChannelSettingReactor: Reactor {
    var initialState: State = State(
        memberInfo: [],
        channelInfo: nil,
        msg: "",
        exitSuccess: [],
        successDelete: false
    )
    
    private let channelRepository = ChannelRepository()
    
    
    enum Action {
        case requestChannelInfo(wsId: Int?, name: String?)
        case requestExitChannel(wsId: Int?, name: String?, chId: Int?)
        case requestDeleteChannel(wsId: Int?, name: String?, chId: Int?)
    }
    
    enum Mutation {
        case memberInfo(data: [User])
        case channelInfo(data: Channel)
        case msg(msg: String)
        case exitSuccess(data: [Channel])
        case successDelete
    }
    
    struct State {
        var memberInfo: [User]
        var channelInfo: Channel?
        var msg: String
        var exitSuccess: [Channel]
        var successDelete: Bool
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestChannelInfo(let wsId, let name):
            if let wsId = wsId, let name = name {
                return requestChannelInfo(wsId: wsId, name: name)
            } else {
                return .just(.msg(msg: ChannelToastMessage.otherError.message))
            }
        case .requestExitChannel(let wsId, let name, let chId):
            if let wsId = wsId, let name = name, let chId = chId {
                return requestExitChannel(wsId: wsId, name: name, chId: chId)
            } else {
                return .just(.msg(msg: ChannelToastMessage.otherError.message))
            }
        case .requestDeleteChannel(let wsId, let name, let chId):
            if let wsId = wsId, let name = name, let chId = chId {
                return requestDeleteChannel(wsId: wsId, name: name, chId: chId)
            }
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .memberInfo(let data):
            newState.memberInfo = data
        case .channelInfo(let data):
            newState.channelInfo = data
        case .msg(let msg):
            newState.msg = msg
        case .exitSuccess(let data):
            newState.exitSuccess = data
        case .successDelete:
            newState.successDelete = true
        }
        return newState
    }
    
    
    
}

extension ChannelSettingReactor {
    
    private func requestDeleteChannel(wsId: Int, name: String, chId: Int) -> Observable<Mutation> {
        return ChannelsAPIManager.shared.request(api: .delete(wsId: wsId, name: name), responseType: EmptyResponse.self)
            .asObservable()
            .map { result -> Mutation in
                
                switch result {
                case .success(_):
                    self.deleteToDB(wsId: wsId, chId: chId)
                    print("delete success")
                    return .successDelete
                case .failure(let error):
                    var msg = CommonError.E99.localizedDescription
                    if let error = ChannelError(rawValue: error.errorCode) {
                        msg = error.exitErrorDescription ?? ""
                    } else if let error = CommonError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    }
                    return .msg(msg: msg)
                }
                
            }
        
    }
    
    private func requestExitChannel(wsId: Int, name: String, chId: Int) -> Observable<Mutation> {
        return ChannelsAPIManager.shared.request(api: .exit(wsId: wsId, name: name), responseType: ChannelsItemResDTO.self)
            .asObservable()
            .map { result -> Mutation in
                switch result {
                case .success(let response):
                    self.deleteToDB(wsId: wsId, chId: chId)
                    if let response = response {
                        return .exitSuccess(data:  response.map { $0.toDomain() })
                    } else {
                        return .msg(msg: ChannelToastMessage.otherError.message)
                    }
                    
                case .failure(let error):
                    var msg = CommonError.E99.localizedDescription
                    if let error = ChannelError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    } else if let error = CommonError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    }
                    return .msg(msg: msg)
                }
                
            }
    }
    
    private func deleteToDB(wsId: Int, chId: Int) {
        if let channelDto = channelRepository.searchChannel(wsId: wsId, chId: chId).first {
            do {
                try channelRepository.delete(object: channelDto)
            } catch {
                debugPrint("[DB DELETE ERROR] ", error.localizedDescription)
            }
        }
        
    }
    
    
    private func requestChannelInfo(wsId: Int, name: String) -> Observable<Mutation> {
        return ChannelsAPIManager.shared.request(api: .oneChannel(wsId: wsId, name: name), responseType: ChannelResDTO.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let response):
                    
                    if let response = response {
                        let channelInfo = response.toDomain()
                        let memberInfo = response.toUserDomain()
                        return .concat(
                            .just(.channelInfo(data: channelInfo)),
                            .just(.memberInfo(data: memberInfo))
                        )
                    } else {
                        return .just(.msg(msg: ChannelToastMessage.otherError.message))
                    }
                    
                    
                case .failure(let error):
                    var msg = CommonError.E99.localizedDescription
                    if let error = ChannelError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    } else if let error = CommonError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    }
                    return .just(.msg(msg: msg))
                }
                
            }
    }
}
