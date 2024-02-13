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
    private var disposeBag = DisposeBag()
    
    var initialState: State = State(
        msg: "",
        loginRequest: false,
        memberInfo: nil,
        dmList: [],
        dmInfo: (nil, []),
        myInfo: nil,
        userInfo: nil
    )
    
    
    enum Action {
        case requestMemberList(wsId: Int?)
        case requestDmList(wsId: Int?)
        case enterDmRoom(wsId: Int?, roomId: Int?, userId: Int)
        case requestMyInfo
        case selectUserCell(wsId: Int?, user: User)
    }
    
    enum Mutation {
        case msg(msg: String)
        case loginRequest
        case memberInfo(data: [User])
        case dmList(data: [DMsRoom])
        case dmInfo(data: DmDTO?, dmChat: [DmChat])
        case myInfo(data: User)
        case userInfo (data: User?)
    }
    
    struct State {
        var msg: String
        var loginRequest: Bool
        var memberInfo: [User]?
        var dmList: [DMsRoom]
        var dmInfo: (DmDTO?, [DmChat])
        var myInfo: User?
        var userInfo: User?
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
                return .concat(
                    requestUserInfo(userId: userId),
                    requestDmInfo(wsId: wsId, roomId: roomId, userId: userId)
                    
                )
            } else {
                return .just(.msg(msg: WorkspaceToastMessage.loadError.message))
            }
        case .requestMyInfo:
            return requestMyInfo()
        case .selectUserCell(let wsId, let user):
            if let wsId = wsId {
                if let dmData = dmRepository.searchDmRoom(userId: user.userId) {
                    return .concat(
                        requestUserInfo(userId: user.userId),
                        requestDmInfo(wsId: wsId, roomId: dmData.roomId, userId: user.userId)
                    )
                } else {
                    return requestDmChat(wsId: wsId, userId: user.userId)
                    
                }
            }
            else {
                return .just(.msg(msg: DmToastMessage.otherError.message))
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
        case .myInfo(let data):
            newState.myInfo = data
        case .userInfo(let data):
            newState.userInfo = data
        }
        
        return newState
    }
    
}

extension DmListReactor {
    
    private func requestUserInfo(userId: Int) -> Observable<Mutation> {
        return UsersAPIManager.shared.request(api: .otherUser(userId: userId), responseType: UserResDTO.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let response):
                    if let response = response {
                        return .concat(
                            .just(.userInfo(data: response.toDomain()))
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
    
    
    private func requestDmList(wsId: Int) -> Observable<Mutation> {
        return DMsAPIManager.shared.request(api: .fetchDM(id: wsId), resonseType: DMsRoomResDTO.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let response):
                    if let response = response {
                        let data = response.map { $0.toDomain() }
                        let req = data.map {
                            return ($0, self.dmRepository.fetchDmCursorDate(wsId: $0.workspaceID, roomId: $0.roomID))
                        }
                        return self.requestUnreadCnt(data: req)
                            .map {
                                return .dmList(data: $0)
                            }
                       
                    }
                    return .just(.msg(msg: DmToastMessage.otherError.message))
                case .failure(let error):
                    if let error = DmError(rawValue: error.errorCode) {
                        return .just(.msg(msg: error.localizedDescription))
                    } else if let error = CommonError(rawValue: error.localizedDescription) {
                        return .just(.msg(msg: error.localizedDescription))
                    } else {
                        return .just(.loginRequest)
                    }
                }
                
            }
    }
    
    private func requestUnreadCnt(data: [(DMsRoom, String?)]) -> Observable<[DMsRoom]> {
        
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
                case .failure(_):
                    completion(nil)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func requestDmChat(wsId: Int, userId: Int) -> Observable<Mutation> {
        DMsAPIManager.shared.request(api: .fetchDmChat(wsId: wsId, userId: userId, date: nil), resonseType: DmChatListResDTO.self)
            .asObservable()
            .withUnretained(self)
            .flatMap { (owner, result) -> Observable<Mutation> in
                switch result {
                case .success(let response):
                    if let response = response {
                        return .concat(
                            owner.requestUserInfo(userId: userId),
                            owner.requestDmInfo(wsId: wsId, roomId: response.room_id, userId: userId)
                        )
                    }
                    return .just(.msg(msg: DmToastMessage.loadFailDm.message))
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
}
