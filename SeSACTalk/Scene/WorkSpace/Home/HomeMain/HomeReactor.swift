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
    private let dmRepository = DmRepository()
    private var disposeBag = DisposeBag()
    
    var initialState: State = State(
        channelItem: [],
        workspaceItem: nil,
        loginRequest: false,
        message: "",
        dmRoomItems: [],
        allWorkspace: [],
        chatInfo: (nil, []),
        userInfo: [:],
        myInfo: nil,
        dmInfo: (nil, []),
        dmUserInfo: nil
    )
    
    enum Action {
        case requestChannelInfo(id: Int?)
        case requestDMsInfo(id: Int?)
        case requestAllWorkspace
        case searchChannelDB(wsId: Int?, chInfo: Channel?)
        case requestMyInfo
        case requestDmRoomInfo(wsId: Int?, roomId: Int?, userId: Int)
    }
    
    enum Mutation {
        case channelInfo(channels: [Channel])
        case msg(msg: String)
        case loginRequest
        case dmsInfo(dms: [DMsRoom])
        case fetchAllWorkspace(data: [WorkspaceDto])
        case chatInfo(chInfo: ChannelDTO?, chatItems: [ChannelMessage])
        case userInfo(data: [Int: User])
        case myInfo(data: User)
        case dmInfo(data: DmDTO?, dmChat: [DmChat])
        case dmUserInfo (data: User?)
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
        var myInfo: User?
        var dmInfo: (DmDTO?, [DmChat])
        var dmUserInfo: User?
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
        case .requestMyInfo:
            return requestMyInfo()
        case .requestDmRoomInfo(let wsId, let roomId, let userId):
            if let wsId = wsId, let roomId = roomId {
                return .concat(
                    requestUserInfo(userId: userId),
                    requestDmInfo(wsId: wsId, roomId: roomId, userId: userId)
                )
            } else {
                return .just(.msg(msg: WorkspaceToastMessage.loadError.message))
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .channelInfo(let channels):
            newState.channelItem = channels.map {
                return WorkspaceItem(title: "", subItems: [], item: $0)
            }
        case .msg(let msg):
            newState.message = msg
        case .loginRequest:
            newState.loginRequest = true
        case .dmsInfo(dms: let dms):
            newState.dmRoomItems = dms.map {
                return WorkspaceItem(title: "'", subItems: [], item: $0)
            }
        case .fetchAllWorkspace(data: let data):
            newState.allWorkspace = data.map{
                $0.toDomain()
            }
        case .chatInfo(let chInfo, let chatItems):
            newState.chatInfo = (chInfo, chatItems)
        case .userInfo(let data):
            newState.userInfo = data
        case .myInfo(let data):
            newState.myInfo = data
        case .dmInfo(data: let data, let dmChat):
            newState.dmInfo = (data, dmChat)
        case .dmUserInfo(data: let data):
            newState.dmUserInfo = data
        }
        
        return newState
    }
    
}

extension HomeReactor {
    
    private func requestMyInfo() -> Observable<Mutation> {
        return UsersAPIManager.shared.request(api: .my, responseType: UserResDTO.self)
            .asObservable()
            .map { result -> Mutation in
                switch result {
                case .success(let response):
                    if let response = response {
                        return .myInfo(data: response.toDomain())
                    } else {
                        return .msg(msg: "정보를 가져오는데 실패하였습니다.")
                    }
                case .failure(_):
                    return .msg(msg: CommonError.E99.localizedDescription)
                    
                }
            
                
            }
    }
    
    
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
            data.append($0.toDomain(name: channelData.name))
        }
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
    
    
    
    private func requestMyChannels(id: Int) -> Observable<Mutation> {
        return ChannelsAPIManager.shared.request(api: .myChannel(id: id), responseType: ChannelsItemResDTO.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let response):
                    if let response = response {
                        let data = response.map { $0.toDomain() }
                        let req = data.map { return ($0, self.channelRepository.fetchChannelCursorDate(wsId: $0.workspaceID, chId: $0.channelID))}
                        return self.requestUnreadCnt(data: req)
                            .map { channels in
                                return .channelInfo(channels: channels)
                         }
                    } else {
                        return .just(Mutation.msg(msg: "오류가 발생하였습니다."))
                    }
                case .failure(let error):
                    if let error = ChannelError(rawValue: error.errorCode) {
                        return .just(Mutation.msg(msg: error.localizedDescription))
                    } else if let error = CommonError(rawValue: error.errorCode) {
                        return .just(Mutation.msg(msg: error.localizedDescription))
                    } else {
                        return .just(Mutation.loginRequest)
                    }
                }
            }
    }
    
    
    
    private func requestUnreadCnt(data: [(Channel, String?)]) -> Observable<[Channel]> {
        return Observable.create { observer in
            let group = DispatchGroup()
            var channelItems: [Channel] = []

            data.forEach {
                var channel = $0.0
                let last = $0.1
                group.enter()
                DispatchQueue.main.async {
                    self.reqeustUnreadChannel(wsId: channel.workspaceID, name: channel.name, after: last) { unreadCount in
                        channel.unread = unreadCount ?? 0
                        channelItems.append(channel)
                        group.leave()
                    }
                }
            }

            group.notify(queue: DispatchQueue.main) {
                observer.onNext(channelItems)
                observer.onCompleted()
            }

            return Disposables.create()
        }
    }
    
    private func reqeustUnreadChannel(wsId: Int, name: String, after: String?, completion: @escaping ((Int?) -> Void)) {
        
        var cnt = 0
        ChannelsAPIManager.shared.request(api: .unreads(wsId: wsId, name: name, after: after ?? nil), responseType: UnreadChannelCntResDTO.self)
            .asObservable()
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let response):
                    cnt = response?.count ?? 0
                    completion(cnt)
                    
                case .failure(_):
                    completion(nil)
                }
            }
            .disposed(by: disposeBag)
    }
    
    
}

// DM
extension HomeReactor {
    
    private func reqeustDMRoomInfo(id: Int) -> Observable<Mutation> {
        
        return DMsAPIManager.shared.request(api: .fetchDM(id: id), resonseType: DMsRoomResDTO.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let response):
                    if let response = response {
                        let data = response.map { $0.toDomain() }
                        let req = data.map {
                            return ($0, self.dmRepository.fetchDmCursorDate(wsId: $0.workspaceID, roomId: $0.roomID))
                        }
                        return self.requestUnreadDMCnt(data: req)
                            .map {
                                return .dmsInfo(dms: $0)
                            }
                        
                    }
                    return .just(.msg(msg: WorkspaceToastMessage.loadError.message))
                case .failure(let error):
                    if let error = WorkspaceError(rawValue: error.errorCode) {
                        return .just(.msg(msg: error.localizedDescription))
                    } else if let error = CommonError(rawValue: error.errorCode) {
                        return .just(.msg(msg: error.localizedDescription))
                    } else {
                        return .just(.loginRequest)
                    }
                }
                
            }
        
    }
    
    private func requestUnreadDMCnt(data: [(DMsRoom, String?)]) -> Observable<[DMsRoom]> {
        
        return Observable.create { observer in
            var dmItems: [DMsRoom] = []
            let group = DispatchGroup()
            
            data.forEach { value in
                var dmRoom = value.0
                let last = value.1
                group.enter()
                DispatchQueue.main.async {
                    self.requestUnreadDm(wsId: dmRoom.workspaceID, roomId: dmRoom.roomID, after: last) { cnt in
                        dmRoom.unread = cnt ?? 0
                        dmItems.append(dmRoom)
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: DispatchQueue.main) {
                observer.onNext(dmItems)
                observer.onCompleted()
            }
            
            
            return Disposables.create()
        }
    }
    
    private func requestUnreadDm(wsId: Int, roomId: Int, after: String?, completion: @escaping ((Int?) -> Void)) {
        var cnt = 0
        DMsAPIManager.shared.request(api: .unreads(wsId: wsId, roomId: roomId, after: after), resonseType: UnreadDmCntResDTO.self)
            .asObservable()
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let response):
                    cnt = response?.count ?? 0
                    completion(cnt)
                case .failure(let error):
                    completion(nil)
                }
            }
            .disposed(by: disposeBag)
    }
    
    
    private func requestUserInfo(userId: Int) -> Observable<Mutation> {
        return UsersAPIManager.shared.request(api: .otherUser(userId: userId), responseType: UserResDTO.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let response):
                    if let response = response {
                        return .concat(
                            .just(.dmUserInfo(data: response.toDomain()))
                        )
                    } else {
                        return .just(.msg(msg: "문제가 발생하였습니다."))
                    }
                case .failure(let error):
                    
                    if error.errorCode == "E03" {
                        return .just(.msg(msg: "알 수 없는 계정입니다."))
                    } else if let error = CommonError(rawValue: error.errorCode) {
                        return .just(.msg(msg: error.localizedDescription))
                    } else {
                        return .just(.loginRequest)
                    }
                }
            }
    }
    
    private func requestDmInfo(wsId: Int, roomId: Int, userId: Int) -> Observable<Mutation> {
        if let dmInfo = searchDmDB(wsId: wsId, roomId: roomId, userId: userId) {
            let chatItem = getDmChatItems(dmData: dmInfo)
            return .concat(
                .just(.dmInfo(data: dmInfo, dmChat: chatItem)),
                .just(.dmInfo(data: nil, dmChat: []))
            )
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
}
