//
//  SearchChannelReactor.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/30/24.
//

import Foundation
import ReactorKit

final class SearchChannelReactor: Reactor {
    var initialState: State = State(
        channelList: [],
        myChannelList: [:],
        msg: "",
        saveChannel: nil
    )
    
    private var channelRepository = ChannelRepository()
    
    
    enum Action {
        case requestChannelList(wsId: Int?)
        case requestMyChannels(wsId: Int?)
        case saveChannel(wsId: Int?, chId: Int, name: String)
    }
    
    enum Mutation {
        case channelList(data: ChannelsItemResDTO)
        case myChannelList(data: ChannelsItemResDTO)
        case msg(msg: String)
        case saveSuccess(data: ChannelDTO)
    }
    
    struct State {
        var channelList: [ChannelSectionModel]
        var myChannelList: [Int: Channel]
        var msg: String
        var saveChannel: ChannelDTO?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestChannelList(let wsId):
            if let wsId = wsId {
                return requestAllChannelList(wsId: wsId)
            }
            return .just(.msg(msg: ChannelToastMessage.otherError.message))
            
        case .requestMyChannels(let wsId):
            if let wsId = wsId {
                return requestMyChannelList(wsId: wsId)
            }
            return .just(.msg(msg: ChannelToastMessage.otherError.message))
        case .saveChannel(let wsId, let chId, let name):
            if let wsId = wsId {
                return searchChannelDB(wsId: wsId, chId: chId, name: name)
            }
            return .just(.msg(msg: ChannelToastMessage.otherError.message))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .channelList(let data):
            let items = data.map { $0.toDomain() }
            
            newState.channelList = [ChannelSectionModel(section: "", items: items)]
        case .myChannelList(let data):
            data.forEach {
                newState.myChannelList.updateValue($0.toDomain(), forKey: $0.channelID)
            }
        case .msg(let msg):
            newState.msg = msg
        case .saveSuccess(let data):
            newState.saveChannel = data
        }
        
        return newState
    }
    
    
}

extension SearchChannelReactor {
    
    private func searchChannelDB(wsId: Int, chId: Int, name: String) -> Observable<Mutation> {
        let data = channelRepository.searchChannel(wsId: wsId, chId: chId)
//        print(data)
        if data.isEmpty {
            let channelInfo = ChannelDTO(workspaceId: wsId, channelId: chId, name: name)
            // 저장
            do {
                try channelRepository.create(object: channelInfo)
                return .just(.saveSuccess(data: channelInfo))
            } catch {
                debugPrint("channel ", error.localizedDescription)
                return .just(.msg(msg: ChannelToastMessage.otherError.message))
            }
        } else {
            if let data = data.first {
                return .just(.saveSuccess(data: data))
            }
            return .just(.msg(msg: ChannelToastMessage.otherError.message))
        }
    }
    
    private func requestMyChannelList(wsId: Int) -> Observable<Mutation> {
        return ChannelsAPIManager.shared.request(api: .myChannel(id: wsId), responseType: ChannelsItemResDTO.self)
            .asObservable()
            .map { result -> Mutation in
                switch result {
                case .success(let response):
                    if let response = response {
                        return .myChannelList(data: response)
                    }
                    return .msg(msg: ChannelToastMessage.otherError.message)
                case .failure(let error):
                    return self.channelErrorCheck(error: error)
                }
                
            }
    }
    
    private func requestAllChannelList(wsId: Int) -> Observable<Mutation> {
        return ChannelsAPIManager.shared.request(api: .allChannel(wsId: wsId), responseType: ChannelsItemResDTO.self)
            .asObservable()
            .map { result -> Mutation in
                switch result {
                case .success(let response):
                    if let response = response {
                        return .channelList(data: response)
                    }
                    return .msg(msg: ChannelToastMessage.otherError.message)
                    
                    
                case .failure(let error):
                    return self.channelErrorCheck(error: error)
                        
                }
            }
    }
    
    
    private func channelErrorCheck(error: ErrorResponse) -> Mutation {
        if let error = ChannelError(rawValue: error.errorCode) {
            return .msg(msg: error.localizedDescription)
        } else if let error = CommonError(rawValue: error.errorCode) {
            return .msg(msg: error.localizedDescription)
        } else {
            return .msg(msg: CommonError.E99.localizedDescription)
        }
    }
    
}
