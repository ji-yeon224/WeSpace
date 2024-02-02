//
//  HomeReactor.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/12/24.
//

import Foundation
import ReactorKit

final class HomeReactor: Reactor {
    
    private let channelRepository = ChannelRepository()
    
    var initialState: State = State(
        channelItem: [],
        workspaceItem: nil,
        loginRequest: false,
        message: "",
        dmRoomItems: [],
        allWorkspace: [],
        chatInfo: (nil, []),
        userInfo: [:]
    )
    
    
    
    enum Action {
        case requestChannelInfo(id: Int?)
        case requestDMsInfo(id: Int?)
        case requestAllWorkspace
        case searchChannelDB(wsId: Int?, chInfo: Channel?)
    }
    
    enum Mutation {
        case channelInfo(channels: [ChannelResDTO])
        case msg(msg: String)
        case loginRequest
        case dmsInfo(dms: DMsRoomResDTO)
        case fetchAllWorkspace(data: [WorkspaceDto])
        case chatInfo(chInfo: ChannelDTO?, chatItems: [ChannelMessage])
        case userInfo(data: [Int: User])
    }
    
    struct State {
        var channelItem: [WorkspaceItem]
        var workspaceItem: WorkSpace?
        var loginRequest: Bool
        var message: String
        var dmRoomItems: [WorkspaceItem]
        var allWorkspace: [WorkSpace]
        var chatInfo: (ChannelDTO?, [ChannelMessage])
        var userInfo: [Int: User]
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestChannelInfo(let id):
            if let id = id {
                return requestMyChannels(id: id)
            } else {
                return Observable.of(Mutation.msg(msg: "ARGUMENT ERROR"))
            }
            
        case .requestDMsInfo(id: let id):
            if let id = id {
                return reqeustDMRoomInfo(id: id)
            } else {
                return Observable.of(Mutation.msg(msg: "ARGUMENT ERROR"))
            }
            
        case .requestAllWorkspace:
            return requestAllWorkspace()
        case .searchChannelDB(let wsId, let chInfo):
            
            if let wsId = wsId, let chInfo = chInfo {
                return .concat(
                    requestChannelInfo(wsId: wsId, chInfo: chInfo),
                    fetchChannelMembers(wsId: wsId, name: chInfo.name)
                )
            } else {
                return Observable.of(Mutation.msg(msg: "ARGUMENT ERROR"))
            }
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .channelInfo(let channels):
            newState.channelItem = channels.map {
                return WorkspaceItem(title: "", subItems: [], item: $0.toDomain())
            }
        case .msg(let msg):
            newState.message = msg
        case .loginRequest:
            newState.loginRequest = true
        case .dmsInfo(dms: let dms):
            newState.dmRoomItems = dms.map {
                return WorkspaceItem(title: "'", subItems: [], item: $0.toDomain())
            }
        case .fetchAllWorkspace(data: let data):
            newState.allWorkspace = data.map{
                $0.toDomain()
            }
        case .chatInfo(let chInfo, let chatItems):
            newState.chatInfo = (chInfo, chatItems)
        case .userInfo(let data):
            newState.userInfo = data
        }
        
        return newState
    }
    
}

extension HomeReactor {
    
    
    private func requestChannelInfo(wsId: Int, chInfo: Channel) -> Observable<Mutation> {
        if let channelInfo = searchChannelDB(wsId: wsId, chId: chInfo.channelID, name: chInfo.name) {
            
            // 이름 다르면 이름 수정
            if chInfo.name != channelInfo.name {
                updateChannelInfo(channel: channelInfo, name: chInfo.name)
            }
            debugPrint("채널 정보 가져옴...")
            let item = getChatItems(channelData: channelInfo)
            return .concat(
                self.fetchChannelMembers(wsId: wsId, name: chInfo.name),
                .just(.chatInfo(chInfo: channelInfo, chatItems: item)),
                .just(.chatInfo(chInfo: nil, chatItems: []))
            )
        } else {
            return .just(.msg(msg: ChannelToastMessage.loadFailChat.message))
        }
    }
    
    
    private func fetchChannelMembers(wsId: Int, name: String) -> Observable<Mutation> {
        return ChannelsAPIManager.shared.request(api: .member(name: name, wsId: wsId), responseType: MemberResDTO.self)
            .asObservable()
            .map { result -> Mutation in
                switch result {
                case .success(let response):
                    if let response = response {
                        var data: [Int:User] = [:]
                        response.forEach {
                            data[$0.user_id] = $0.toDomain()
                        }
                        return .userInfo(data: data)
                    }
                    return .msg(msg: ChannelToastMessage.loadFailChat.message)
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
    
    private func updateChannelInfo(channel: ChannelDTO, name: String) {
        do {
            try channelRepository.updateChannelInfo(data: channel, name: name)
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    private func searchChannelDB(wsId: Int, chId: Int, name: String) -> ChannelDTO? {
        let data = channelRepository.searchChannel(wsId: wsId, chId: chId)
//        print(data)
        if data.isEmpty {
            let channelInfo = ChannelDTO(workspaceId: wsId, channelId: chId, name: name)
            // 저장
            do {
                try channelRepository.create(object: channelInfo)
                return channelInfo
            } catch {
                debugPrint("channel ", error.localizedDescription)
                return nil
            }
        } else {
            return data.first
        }
    }
    
    
    private func getChatItems(channelData: ChannelDTO) -> [ChannelMessage] {
        var data: [ChannelMessage] = []
        channelData.chatItem.forEach {
            data.append($0.toDomain())
        }
        print(#function, data.count)
        return data
    }
    
    private func requestAllWorkspace() -> Observable<Mutation> {
        return WorkspacesAPIManager.shared.request(api: .fetchAll, resonseType: AllWorkspaceReDTO.self)
            .asObservable()
            .map { result -> Mutation in
                switch result {
                case .success(let value):
                    return Mutation.fetchAllWorkspace(data: value ?? [])
                case .failure(let error):
                    return Mutation.msg(msg: error.localizedDescription)
                }
                
            }
    }
    
    private func reqeustDMRoomInfo(id: Int) -> Observable<Mutation> {
        
        return DMsAPIManager.shared.request(api: .fetchDM(id: id), resonseType: DMsRoomResDTO.self)
            .asObservable()
            .map { result -> Mutation in
                switch result {
                case .success(let response):
                    if let response = response {
                        return Mutation.dmsInfo(dms: response)
                    } else { return Mutation.msg(msg: "오류가 발생하였습니다.")}
                case .failure(let error):
                    if let error = WorkspaceError(rawValue: error.errorCode) {
                        return Mutation.msg(msg: error.localizedDescription)
                    } else if let error = CommonError(rawValue: error.errorCode) {
                        return Mutation.msg(msg: error.localizedDescription)
                    } else {
                        return Mutation.loginRequest
                    }
                }
                
            }
        
    }
    
    private func requestMyChannels(id: Int) -> Observable<Mutation> {
        return ChannelsAPIManager.shared.request(api: .myChannel(id: id), responseType: ChannelsItemResDTO.self)
            .asObservable()
            .map { result -> Mutation in
                switch result {
                case .success(let response):
                    if let response = response {
                        return Mutation.channelInfo(channels: response)
                    } else {
                        return Mutation.msg(msg: "오류가 발생하였습니다.")
                    }
                case .failure(let error):
                    if let error = WorkspaceError(rawValue: error.errorCode) {
                        return Mutation.msg(msg: error.localizedDescription)
                    } else if let error = CommonError(rawValue: error.errorCode) {
                        return Mutation.msg(msg: error.localizedDescription)
                    } else {
                        return Mutation.loginRequest
                    }
                }
                
            }
    }
}
