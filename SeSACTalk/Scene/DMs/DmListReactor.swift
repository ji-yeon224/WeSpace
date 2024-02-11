//
//  DmListReactor.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/8/24.
//

import Foundation
import ReactorKit

final class DmListReactor: Reactor {
    
    private let dmRepository = DmRepository()
    
    var initialState: State = State(
        msg: "",
        loginRequest: false,
        memberInfo: nil,
        dmList: [],
        dmInfo: (nil, [])
    )
    
    
    enum Action {
        case requestMemberList(wsId: Int?)
        case requestDmList(wsId: Int?)
        case enterDmRoom(wsId: Int?, roomId: Int?, userId: Int)
    }
    
    enum Mutation {
        case msg(msg: String)
        case loginRequest
        case memberInfo(data: [User])
        case dmList(data: [DMsRoom])
        case dmInfo(data: DmDTO, dmChat: [DmChat])
    }
    
    struct State {
        var msg: String
        var loginRequest: Bool
        var memberInfo: [User]?
        var dmList: [DMsRoom]
        var dmInfo: (DmDTO?, [DmChat])
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestMemberList(let wsId):
            if let wsId = wsId {
                return requestMemberList(wsId: wsId)
            } else {
                return .just(.msg(msg: WorkspaceToastMessage.loadError.message))
            }
        case .requestDmList(let wsId):
            if let wsId = wsId {
                return requestDmList(wsId: wsId)
            } else {
                return .just(.msg(msg: WorkspaceToastMessage.loadError.message))
            }
        case .enterDmRoom(let wsId, let roomId, let userId):
            if let wsId = wsId, let roomId = roomId {
                return requestDmInfo(wsId: wsId, roomId: roomId, userId: userId)
            } else {
                return .just(.msg(msg: WorkspaceToastMessage.loadError.message))
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .msg(let msg):
            newState.msg = msg
        case .loginRequest:
            newState.loginRequest = true
        case .memberInfo(let data):
            newState.memberInfo = data
        case .dmList(let data):
            newState.dmList = data
        case .dmInfo(let data, let dmChat):
            newState.dmInfo = (data, dmChat)
        }
        
        return newState
    }
    
}

extension DmListReactor {
    
    private func requestDmInfo(wsId: Int, roomId: Int, userId: Int) -> Observable<Mutation> {
        if let dmInfo = searchDmDB(wsId: wsId, roomId: roomId, userId: userId) {
            debugPrint("DM DATA")
            let chatItem = getDmChatItems(dmData: dmInfo)
            return .just(.dmInfo(data: dmInfo, dmChat: chatItem))
        } else {
            return .just(.msg(msg: DmToastMessage.loadFailDm.message))
        }
    }
    
    private func searchDmDB(wsId: Int, roomId: Int, userId: Int) -> DmDTO? {
        let data = dmRepository.searchDm(wsId: wsId, roomId: roomId)
        
        if data.isEmpty {
            let dmInfo = DmDTO(workspaceId: wsId, roomId: roomId, userId: userId)
            do {
                try dmRepository.create(object: dmInfo)
                return dmInfo
            } catch {
                debugPrint("DM ", error.localizedDescription)
                return nil
            }
        } else {
            return data.first
        }
        
    }
    
    private func getDmChatItems(dmData: DmDTO) -> [DmChat] {
        var data: [DmChat] = []
        dmData.dmItem.forEach {
            data.append($0.toDomain())
        }
        return data
    }
    
    
    private func requestDmList(wsId: Int) -> Observable<Mutation> {
        return DMsAPIManager.shared.request(api: .fetchDM(id: wsId), resonseType: DMsRoomResDTO.self)
            .asObservable()
            .map { result in
                switch result {
                case .success(let response):
                    if let response = response {
                        let error = response.map { $0.toDomain() }
                        return .dmList(data: error)
                    }
                    return .msg(msg: WorkspaceToastMessage.loadError.message)
                case .failure(let error):
                    if let error = DmError(rawValue: error.errorCode) {
                        return .msg(msg: error.localizedDescription)
                    } else if let error = CommonError(rawValue: error.localizedDescription) {
                        return .msg(msg: error.localizedDescription)
                    } else {
                        return .loginRequest
                    }
                }
                
            }
    }
    
//    private func requestLastDmChat(wsId: Int, userId: Int, date: String?) -> Observable<String> {
//        return DMsAPIManager.shared.request(api: .fetchDmChat(wsId: wsId, userId: userId, date: date), resonseType: DmChatListResDTO.self)
//            .asObservable()
//            .map { result -> Mutation in
//                switch result {
//                case .success(let response):
//                    
//                case .failure(let error):
//                    if let error = DmError(rawValue: error.errorCode) {
//                        return .msg(msg: error.localizedDescription)
//                    } else if let error = CommonError(rawValue: error.localizedDescription) {
//                        return .msg(msg: error.localizedDescription)
//                    } else {
//                        return .loginRequest
//                    }
//                }
//            }
//    }
    
    
    private func requestMemberList(wsId: Int) -> Observable<Mutation> {
        return WorkspacesAPIManager.shared.request(api: .member(id: wsId), resonseType: MemberResDTO.self)
            .asObservable()
            .map { result -> Mutation in
                switch result {
                case .success(let response):
                    if let response = response {
                        
                        let data = response.map { $0.toDomain()}.filter { $0.userId != UserDefaultsManager.userId }
                        return .memberInfo(data: data)
                    }
                    return .msg(msg: WorkspaceToastMessage.loadError.message)
                case .failure(let error):
                    print(error.errorCode)
                    if let error = WorkspaceError(rawValue: error.errorCode) {
                        return .msg(msg: error.localizedDescription)
                    } else if let error = CommonError(rawValue: error.errorCode) {
                        return .msg(msg: error.localizedDescription)
                    } else {
                        return .loginRequest
                    }
                    
                }
            }
    }
}
