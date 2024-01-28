//
//  ChatReactor.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/24/24.
//

import Foundation
import ReactorKit

final class ChatReactor: Reactor {
    
    var channelRecord: ChannelDTO?
    
    var initialState: State = State(
        msg: "",
        loginRequest: false,
        sendSuccess: nil,
        channelRecord: nil,
        fetchChatSuccess: []
    )
    
    
    enum Action {
        case fetchChannel(wsId: Int, chId: Int)
        case sendRequest(channel: ChannelDTO?, id: Int?, content: String?, files: [SelectImage])
        case requestUncheckedMsg(date: String?, wsId: Int?, name: String?)
    }
    
    enum Mutation {
        case msg(msg: String)
        case loginRequest(login: Bool)
        case sendSuccess(data: ChannelMessage)
        case fetchChannelRecord(data: ChannelDTO)
        case fetchChatSuccess(data: [ChannelMessage])
    }
    
    struct State {
        var msg: String
        var loginRequest: Bool
        var sendSuccess: ChannelMessage?
        var channelRecord: ChannelDTO?
        var fetchChatSuccess: [ChannelMessage]
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchChannel(let wsId, let chId):
            if let item = ChannelRepository().searchChannel(wsId: wsId, chId: chId).first {
                return .just(.fetchChannelRecord(data: item))
            }
            return .just(.msg(msg: ChannelToastMessage.otherError.message))
            
        case .sendRequest(let channel, let id, let content, let files):
            if let channel = channel, let id = id {
                let imgs = files.map {
                    return $0.img?.imageToData()
                }
                let data = ChannelChatReqDTO(content: content, files: imgs)
                return requestSendMsg(channel: channel, id: id, data: data)
            } else {
                debugPrint("[data binding error]")
                return .just(.msg(msg: ChannelToastMessage.otherError.message))
            }
        case .requestUncheckedMsg(let date, let wsId, let name):
            if let wsId = wsId, let name = name {
                return requestUnckeckedMsg(date: date, wsId: wsId, name: name)
            } else {
                debugPrint("[data binding error]")
                return .just(.msg(msg: ChannelToastMessage.otherError.message))
            }
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .msg(let msg):
            newState.msg = msg
        case .loginRequest(let login):
            newState.loginRequest = login
        case .sendSuccess(let data):
            newState.sendSuccess = data
        case .fetchChannelRecord(let data):
            newState.channelRecord = data
        case .fetchChatSuccess(let data):
            newState.fetchChatSuccess = data
        }
        return newState
    }
    
    
}

extension ChatReactor {
    
    private func requestUnckeckedMsg(date: String?, wsId: Int, name: String) -> Observable<Mutation> {
        
        return ChannelsAPIManager.shared.request(api: .fetchMsg(date: date, name: name, wsId: wsId), responseType: ChannelChatResDTO.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                
                switch result {
                case .success(let response):
                    if let response = response, let channelRecord = self.channelRecord {
                        debugPrint("SUCCESS FETCH MSG", response.count)
                        let chatData = response.map { $0.toDomain() }
                        let uncheckMsg = self.saveChatItems(wsId: wsId, data: channelRecord, chat: chatData)
                        return .just(.fetchChatSuccess(data: uncheckMsg))
//                        if self.saveChatItems(wsId: wsId, data: channelRecord, chat: chatData) {
//                            return .just(.fetchChatSuccess(data: chatData))
//                        } else {
//                            return .just(.msg(msg: ChannelToastMessage.loadFailChat.message))
//                        }
                    }
                    return .just(.msg(msg: ChannelToastMessage.loadFailChat.message))
                case .failure(let error):
                    var msg = CommonError.E99.localizedDescription
                    if let error = ChannelChatError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    } else if let error = CommonError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    } else {
                        return .just(.loginRequest(login: true))
                    }
                    return .just(.msg(msg: msg))
                }
                
            }
        
    }
    
    private func requestSendMsg(channel: ChannelDTO, id: Int, data: ChannelChatReqDTO) -> Observable<Mutation> {
        if data.content == nil && data.files == nil {
            return .just(Mutation.msg(msg: "No Data"))
        }
        
        return ChannelsAPIManager.shared.request(api: .sendMsg(name: channel.name, id: id, data: data), responseType: ChannelMessageDTO.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let response):
                    if let response = response {
                        debugPrint("SUCCESS SEND MSG")
                        let data = response.toDomain()
                        
                        if let sendData = self.saveChatItems(wsId: id, data: channel, chat: [data]).first {
                            print(sendData)
                            return .just(.sendSuccess(data: sendData))
                        }
                        return .just(.msg(msg: ChannelToastMessage.otherError.message))
                        
//                        if self.saveChatItems(wsId: id, data: channel, chat: [data]) {
//
//                        } else {
//                            return .just(.msg(msg: ChannelToastMessage.otherError.message))
//                        }
                    }
                    return .just(.msg(msg: ChannelToastMessage.otherError.message))
                    
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    var msg = CommonError.E99.localizedDescription
                    if let error = ChannelChatError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    } else if let error = CommonError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    } else {
                        return .just(.loginRequest(login: true))
                    }
                    return .just(.msg(msg: msg))
                    
                }
                
            }
        
        
    }
    
    private func saveChatItems(wsId: Int, data: ChannelDTO, chat: [ChannelMessage]) -> [ChannelMessage] {
        
        let chatRecords = chat.map { $0.toRecord() }
        var channelMsgWithImg: [ChannelMessage] = []
        channelMsgWithImg = chat.map {
            var data = $0
            
            let fileName = saveImage(id: wsId, channelId: $0.channelID, files: $0.files, chatId: $0.chatID)
//                data.urls?.append(contentsOf: fileName)
            data.setUrls(urls: fileName)
            return data
        }
        do {
            try ChannelRepository().updateChatItems(data: data, chat: chatRecords)
            
            
            print(channelMsgWithImg)
            debugPrint("[SAVE CHAT ITEMS SUCCESS]")
            return channelMsgWithImg
        } catch {
            print(error.localizedDescription)
            return chat
        }
    }
    
    private func saveImage(id: Int, channelId: Int, files:[String], chatId: Int) -> [String] {
        var imgUrls: [String] = []
        files.forEach { url in
            ImageDownloadManager.shared.getUIImage(with: url) { img in
                let fileName = ImageFileService.getFileName(type: .channel(wsId: id, channelId: channelId), fileURL: url)
                
                ChannelMsgRepository().saveImageToDocument(fileName: fileName, image: img)
                imgUrls.append(fileName)
                
            }
        }
        return imgUrls
    }
    
}

