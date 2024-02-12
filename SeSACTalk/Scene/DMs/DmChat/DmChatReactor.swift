//
//  DmChatReactor.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/8/24.
//

import Foundation
import ReactorKit

final class DmChatReactor: Reactor {
    
    private let dmRepository = DmRepository()
    
    var initialState: State = State(
        msg: "", 
        loginReqeust: false,
        sendSuccess: nil,
        fetchChatSuccess: []
    )
    
    
    enum Action {
        case sendReqeust(dmInfo: DmDTO?, content: String?, files: [SelectImage])
        case requestUncheckedMsg(dmInfo: DmDTO?)
    }
    
    enum Mutation {
        case msg(msg: String)
        case loginRequest
        case sendSuccess(data: DmChat)
        case fetchChatSuccess(data: [DmChat])
    }
    
    struct State {
        var msg: String
        var loginReqeust: Bool
        var sendSuccess: DmChat?
        var fetchChatSuccess: [DmChat]
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .sendReqeust(let dmInfo, let content, let files):
            if let dmInfo = dmInfo {
                let imgs = files.map {
                    return $0.img?.imageToData()
                }
                let data = ChatReqDTO(content: content, files: imgs)
                return requestSendMsg(dmInfo: dmInfo, data: data)
            } else {
                debugPrint("[DATA BINDING ERROR]")
                return .just(.msg(msg: DmToastMessage.otherError.message))
            }
        case .requestUncheckedMsg(let dmInfo):
            if let dmInfo = dmInfo {
                return requestUncheckedMsg(dmInfo: dmInfo)
            } else {
                return .just(.msg(msg: DmToastMessage.loadFailDm.message))
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .msg(let msg):
            newState.msg = msg
        case .loginRequest:
            newState.loginReqeust = true
        case .sendSuccess(let data):
            newState.sendSuccess = data
        case .fetchChatSuccess(let data):
            newState.fetchChatSuccess = data
        }
        
        return newState
    }
    
    
}

extension DmChatReactor {
    
    private func requestUncheckedMsg(dmInfo: DmDTO) -> Observable<Mutation>{
        return DMsAPIManager.shared.request(api: .fetchDmChat(wsId: dmInfo.workspaceId, userId: dmInfo.userId, date: dmInfo.lastDate), resonseType: DmChatListResDTO.self)
            .asObservable()
            .withUnretained(self)
            .flatMap { (owner, result) -> Observable<Mutation> in
                switch result {
                case .success(let response):
                    if let response = response {
                        let chatData = response.chats.map { $0.toDomain() }
                        let uncheckedMsg = owner.saveDmChatItems(data: dmInfo, chat: chatData)
                        return .just(.fetchChatSuccess(data: uncheckedMsg))
                    }
                    return .just(.msg(msg: DmToastMessage.loadFailDm.message))
                case .failure(let error):
                    var msg = CommonError.E99.localizedDescription
                    if let error = DmError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    } else if let error = CommonError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    } else {
                        return .just(.loginRequest)
                    }
                    return .just(.msg(msg: msg))
                }
            }
    }
    
    
    private func requestSendMsg(dmInfo: DmDTO, data: ChatReqDTO) -> Observable<Mutation> {
        return DMsAPIManager.shared.request(api: .sendMsg(wsId: dmInfo.workspaceId, roomId: dmInfo.roomId, data: data), resonseType: DmChatResDTO.self)
            .asObservable()
            .withUnretained(self)
            .flatMap { (owner, result) -> Observable<Mutation> in
                switch result {
                case .success(let response):
                    if let response = response {
                        debugPrint("SUCCESS SEND DM")
                        let data = response.toDomain()
                        if let sendData = owner.saveDmChatItems(data: dmInfo, chat: [data]).first {
                            return .just(.sendSuccess(data: sendData))
                        }
                        return .just(.msg(msg: DmToastMessage.otherError.message))
                    }
                    return .just(.msg(msg: DmToastMessage.otherError.message))
                case .failure(let error):
                    var msg = CommonError.E99.localizedDescription
                    if let error = DmError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    } else if let error = CommonError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    } else {
                        
                        return .just(.loginRequest)
                    }
                    return .just(.msg(msg: msg))
                    
                }
                
            }
    }
    
    private func saveDmChatItems(data: DmDTO, chat: [DmChat]) -> [DmChat] {
        var imgStrings: [String] = []
        let recordList = chat.map {
            let urls: [String] = $0.files.map { url in
                ImageFileService.getFileName(type: .dm(wsId: data.workspaceId, roomId: data.roomId), fileURL: url)
            }
            imgStrings.append(contentsOf: urls)
            saveImage(files: $0.files, fileNames: urls)
            let record = $0.toRecord()
            record.setImgUrls(urls: urls)
            return record
        }
        
        // 이미지 저장 추가..
        do {
            try dmRepository.updateImgItems(data: data, img: imgStrings.map { return ImageDTO(url: $0)})
        } catch {
            debugPrint("ERROR SAVE DM ERROR ", error.localizedDescription)
        }
        
        do {
            print("!!")
            if let lastData = chat.last {
                print(lastData.createdAt)
                try dmRepository.updateDmLastDate(object: data, date: lastData.createdAt)
            }
        } catch {
            debugPrint("UPDATE DATE ERROR ", error.localizedDescription)
        }
        
        do {
            try dmRepository.updateDmChatItems(object: data, chat: recordList)
            return recordList.map { $0.toDomain() }
        } catch {
            debugPrint("SAVE DM CHAT ERROR ", error.localizedDescription)
            return chat
        }
        
    }
    
    private func saveImage(files:[String], fileNames: [String]) {
        
        for i in 0..<files.count {
            let file = files[i]
            ImageDownloadManager.shared.getUIImage(with: file) { [weak self] img in
                guard let self = self else { return }
                ImageFileManager.shared.saveImageToDocument(type: .dm, fileName: fileNames[i], image: img)
                
            }
        }
        
        
    }
    
}
